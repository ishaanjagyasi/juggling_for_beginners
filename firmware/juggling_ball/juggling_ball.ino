/* ------------------------------------------------------------------------
 * Juggling ball — Seeed XIAO nRF52840 Sense (LSM6DS3TR-C + BLE)
 *
 * Streams IMU data over BLE only while the ball is actually in play, and
 * goes quiet when it is resting in a hand or lying on the floor.
 *
 * Core physics: an accelerometer measures proper acceleration, so
 *   - resting (hand / floor / table) -> |a| == 1 g, very low variance
 *   - in flight (free fall)          -> |a| == 0 g
 *   - catch / bounce                 -> |a| spikes to several g
 * Flight is therefore the easy thing to detect, and "at rest" is the
 * 1 g + low-variance + low-gyro case.
 *
 * Toolchain: Arduino IDE
 *   Boards:  "Seeed nRF52 Boards" -> Seeed XIAO nRF52840 Sense
 *            (the non-mbed core, which uses Adafruit Bluefruit)
 *   Libs:    Seeed Arduino LSM6DS3
 * ------------------------------------------------------------------------ */

#include <Wire.h>
#include "LSM6DS3.h"
#include <bluefruit.h>
#include <Adafruit_LittleFS.h>
#include <InternalFileSystem.h>

using namespace Adafruit_LittleFS_Namespace;

// ---------------------------------------------------------------- identity
#define BALL_ID        1          // change per ball: 1, 2, 3 ...
#define FW_VERSION     1

// ---------------------------------------------------------------- timing
#define SAMPLE_HZ      200        // detection runs at this rate
#define SAMPLE_US      (1000000UL / SAMPLE_HZ)
#define STREAM_DECIM   2          // stream every Nth sample -> 100 Hz out
#define BATCH          8          // samples per BLE notification
#define WIN            40         // variance window, 40 @200Hz = 200 ms
#define HEARTBEAT_MS   1000       // while at rest, ping this often
#define FF_CONFIRM_MS  50         // free fall must last this long to count
                                  // (shorter dips happen when the hand drops
                                  //  away during a scoop)
#define BOUNCE_WIN_MS  80         // free fall starting this soon after an
                                  // impact means it bounced off the floor
#define SOFT_LAND_MS   60         // flight ended without a clear spike
#define BOUNCE_END_MS  1500       // bouncing/rolling with no new hop -> handled

// ---------------------------------------------------------------- BLE UUIDs
// 9a1e0000-7a4b-4f2b-8c1a-1f0d2b3c4d5e  (service)
//        01 stream   02 events   03 control
const uint8_t UUID_SVC[16]    = {0x5e,0x4d,0x3c,0x2b,0x0d,0x1f,0x1a,0x8c,
                                 0x2b,0x4f,0x4b,0x7a,0x00,0x00,0x1e,0x9a};
const uint8_t UUID_STREAM[16] = {0x5e,0x4d,0x3c,0x2b,0x0d,0x1f,0x1a,0x8c,
                                 0x2b,0x4f,0x4b,0x7a,0x01,0x00,0x1e,0x9a};
const uint8_t UUID_EVENT[16]  = {0x5e,0x4d,0x3c,0x2b,0x0d,0x1f,0x1a,0x8c,
                                 0x2b,0x4f,0x4b,0x7a,0x02,0x00,0x1e,0x9a};
const uint8_t UUID_CTRL[16]   = {0x5e,0x4d,0x3c,0x2b,0x0d,0x1f,0x1a,0x8c,
                                 0x2b,0x4f,0x4b,0x7a,0x03,0x00,0x1e,0x9a};

BLEService        svcBall(UUID_SVC);
BLECharacteristic chStream(UUID_STREAM);
BLECharacteristic chEvent(UUID_EVENT);
BLECharacteristic chCtrl(UUID_CTRL);

LSM6DS3 imu(I2C_MODE, 0x6A);

// ---------------------------------------------------------------- packets
enum State : uint8_t {
  ST_REST_HAND   = 0,
  ST_REST_GROUND = 1,
  ST_HANDLED     = 2,   // moving, held / carried / winding up
  ST_FLIGHT      = 3,
  ST_IMPACT      = 4,   // just hit something, deciding catch vs bounce
  ST_CALIB       = 5,
  ST_BOUNCING    = 6    // hit the floor, bouncing / rolling
};

enum EvType : uint8_t {
  EV_THROW       = 1,   // sent 50 ms into the flight
  EV_CATCH       = 2,   // v1 = flight time s, v2 = peak g   (~80 ms after catch)
  EV_LAND_GROUND = 3,   // v1 = flight time s, v2 = peak g   (on first bounce)
  EV_REST        = 4,   // v1 = 0 hand / 1 ground
  EV_PICKED_UP   = 5,
  EV_HEARTBEAT   = 6,
  EV_CAL         = 7,   // v1 = command, v2 = result
  EV_APEX        = 8    // v1 = flight time s, v2 = est. height m
};

struct __attribute__((packed)) StreamPkt {
  uint32_t t_ms;
  uint8_t  state;
  uint8_t  ballId;
  uint8_t  n;
  uint8_t  dt_ms;
  int16_t  s[BATCH][6];     // ax..az in mg, gx..gz in 0.1 deg/s
};                          // 8 + 96 = 104 bytes

struct __attribute__((packed)) EventPkt {
  uint32_t t_ms;
  uint8_t  type;
  uint8_t  state;
  uint8_t  ballId;
  uint8_t  flags;
  float    v1;
  float    v2;
};                          // 16 bytes

// ---------------------------------------------------------------- config
#define CFG_MAGIC 0x4A423031UL   // "JB01"
#define CFG_PATH  "/ball.cfg"

struct Config {
  uint32_t magic;
  uint16_t version;

  float gyroBias[3];     // deg/s, removed from every gyro sample
  float accelScale;      // multiplies |a| so that rest == 1.000 g

  float freefallG;       // |a| below this  -> free fall
  float impactG;         // |a| above this  -> impact
  float stillTolG;       // ||a| - 1| below this counts as still
  float stillVar;        // variance of |a| below this counts as still
  float stillW;          // |gyro| (deg/s) below this counts as still
  uint16_t holdMs;       // must stay still this long before declaring rest

  float peakSplitG;      // unused: catches and floor hits overlap in peak g.
                         // kept so calibration saved by older firmware loads
  float jitterSplit;     // rest variance below this looks like the floor
} cfg;

void cfgDefaults() {
  cfg.magic       = CFG_MAGIC;
  cfg.version     = FW_VERSION;
  cfg.gyroBias[0] = cfg.gyroBias[1] = cfg.gyroBias[2] = 0.0f;
  cfg.accelScale  = 1.0f;
  cfg.freefallG   = 0.35f;
  cfg.impactG     = 2.20f;
  cfg.stillTolG   = 0.08f;
  cfg.stillVar    = 0.0025f;   // ~0.05 g std dev
  cfg.stillW      = 12.0f;
  cfg.holdMs      = 250;
  cfg.peakSplitG  = 9.0f;
  cfg.jitterSplit = 1.0e-4f;
}

bool cfgLoad() {
  File f(InternalFS);
  if (!f.open(CFG_PATH, FILE_O_READ)) return false;
  Config tmp;
  int n = f.read((uint8_t*)&tmp, sizeof(tmp));
  f.close();
  if (n != (int)sizeof(tmp) || tmp.magic != CFG_MAGIC) return false;
  cfg = tmp;
  return true;
}

void cfgSave() {
  InternalFS.remove(CFG_PATH);
  File f(InternalFS);
  if (f.open(CFG_PATH, FILE_O_WRITE)) {
    f.write((uint8_t*)&cfg, sizeof(cfg));
    f.close();
  }
}

// ---------------------------------------------------------------- runtime
State    state       = ST_HANDLED;
uint32_t stateSince  = 0;
bool     forceStream = false;     // ctrl 0x10: stream no matter what

float    aBuf[WIN];               // |a| history for variance
uint8_t  aIdx = 0;
bool     aFull = false;
double   aSum = 0, aSum2 = 0;

uint32_t ffStart    = 0;          // millis() free fall began, 0 = not falling
uint32_t stillSince = 0;          // millis() when stillness began
uint8_t  moveCount  = 0;          // consecutive non-still samples
uint32_t tLaunch    = 0;          // millis() of last throw
float    peakG      = 0;          // peak |a| of the current impact
uint32_t impactAt   = 0;
uint32_t landedAt   = 0;          // millis() of the last floor hit/bounce
uint32_t softSince  = 0;          // in flight but not weightless since
bool     onFloor    = false;      // hit the floor since the last throw

StreamPkt spkt;
uint8_t   sFill = 0;
uint8_t   decim = 0;
uint32_t  lastBeat = 0;

// -------------------------------------------------- calibration state
enum CalMode : uint8_t { CAL_NONE, CAL_BIAS, CAL_GROUND, CAL_HAND };
CalMode  calMode   = CAL_NONE;
uint32_t calUntil  = 0;
uint32_t calN      = 0;
double   calGx = 0, calGy = 0, calGz = 0, calA = 0;
float    calVarMax = 0, calWMax = 0;
float    learnedGroundVar = -1, learnedHandVar = -1;
float    learnedGroundW   = -1, learnedHandW   = -1;

// ---------------------------------------------------------------- helpers
void sendEvent(EvType t, float v1 = 0, float v2 = 0) {
  if (!Bluefruit.connected()) return;
  EventPkt e;
  e.t_ms   = millis();
  e.type   = (uint8_t)t;
  e.state  = (uint8_t)state;
  e.ballId = BALL_ID;
  e.flags  = 0;
  e.v1     = v1;
  e.v2     = v2;
  chEvent.notify((uint8_t*)&e, sizeof(e));
}

void setLed(bool r, bool g, bool b) {         // XIAO RGB is active LOW
  digitalWrite(LED_RED,   r ? LOW : HIGH);
  digitalWrite(LED_GREEN, g ? LOW : HIGH);
  digitalWrite(LED_BLUE,  b ? LOW : HIGH);
}

void gotoState(State s) {
  if (s == state) return;
  state      = s;
  stateSince = millis();
  switch (s) {
    case ST_REST_HAND:   setLed(0,1,0); break;
    case ST_REST_GROUND: setLed(1,0,0); break;
    case ST_FLIGHT:      setLed(0,0,1); break;
    case ST_CALIB:       setLed(1,1,0); break;
    default:             setLed(0,0,0); break;
  }
}

bool streaming() {
  return forceStream ||
         state == ST_HANDLED || state == ST_FLIGHT ||
         state == ST_IMPACT  || state == ST_BOUNCING;
}

void pushMag(float m) {
  if (aFull) { aSum -= aBuf[aIdx]; aSum2 -= (double)aBuf[aIdx] * aBuf[aIdx]; }
  aBuf[aIdx] = m;
  aSum  += m;
  aSum2 += (double)m * m;
  if (++aIdx >= WIN) { aIdx = 0; aFull = true; }
}

float magVar() {
  uint16_t n = aFull ? WIN : aIdx;
  if (n < 4) return 1.0f;
  double mean = aSum / n;
  double v    = aSum2 / n - mean * mean;
  return v > 0 ? (float)v : 0.0f;
}

float magMean() {
  uint16_t n = aFull ? WIN : aIdx;
  return n ? (float)(aSum / n) : 1.0f;
}

// ---------------------------------------------------------------- control
void onCtrl(uint16_t, BLECharacteristic*, uint8_t* data, uint16_t len) {
  if (len < 1) return;
  uint8_t cmd = data[0];
  switch (cmd) {
    case 0x01:  // zero the gyro + scale the accel: ball STILL on a table
      calMode = CAL_BIAS;   calUntil = millis() + 3000;
      calN = 0; calGx = calGy = calGz = calA = 0;
      gotoState(ST_CALIB);  sendEvent(EV_CAL, 0x01, 0);
      break;
    case 0x02:  // learn the floor noise floor: ball resting ON THE GROUND
      calMode = CAL_GROUND; calUntil = millis() + 3000;
      calVarMax = 0; calWMax = 0;
      gotoState(ST_CALIB);  sendEvent(EV_CAL, 0x02, 0);
      break;
    case 0x03:  // learn the hand noise floor: ball held STILL IN HAND
      calMode = CAL_HAND;   calUntil = millis() + 3000;
      calVarMax = 0; calWMax = 0;
      gotoState(ST_CALIB);  sendEvent(EV_CAL, 0x03, 0);
      break;
    case 0x06:  cfgSave();     sendEvent(EV_CAL, 0x06, 1); break;
    case 0x07:  cfgDefaults(); cfgSave(); sendEvent(EV_CAL, 0x07, 1); break;
    case 0x10:  forceStream = (len > 1) ? (data[1] != 0) : true;
                sendEvent(EV_CAL, 0x10, forceStream ? 1 : 0); break;
    default: break;
  }
}

void finishCal() {
  calMode = CAL_NONE;
  if (learnedGroundVar >= 0 && learnedHandVar >= 0) {
    // split between the two measured noise floors, and make "still" loose
    // enough that a held ball still counts as still
    cfg.jitterSplit = sqrtf(fmaxf(learnedGroundVar, 1e-9f) *
                            fmaxf(learnedHandVar,  1e-9f));
    cfg.stillVar    = fmaxf(learnedHandVar * 4.0f, 1e-5f);
    cfg.stillW      = fmaxf(learnedHandW  * 2.0f + 2.0f, 3.0f);
  }
  gotoState(ST_HANDLED);
  sendEvent(EV_CAL, 0xFF, cfg.jitterSplit);
}

// ---------------------------------------------------------------- setup
void setup() {
  pinMode(LED_RED, OUTPUT); pinMode(LED_GREEN, OUTPUT); pinMode(LED_BLUE, OUTPUT);
  setLed(0,0,0);

  InternalFS.begin();
  cfgDefaults();
  cfgLoad();

  Wire.begin();
  Wire.setClock(400000);
  imu.settings.accelRange      = 16;     // floor impacts blow past 8 g
  imu.settings.accelSampleRate = 208;
  imu.settings.gyroRange       = 2000;   // a flourished ball spins fast
  imu.settings.gyroSampleRate  = 208;
  imu.begin();
  // block data update: without it the high and low byte of a reading can
  // come from different samples, giving +-256 LSB (17.8 dps) glitches
  uint8_t ctrl3 = 0;
  imu.readRegister(&ctrl3, LSM6DS3_ACC_GYRO_CTRL3_C);
  imu.writeRegister(LSM6DS3_ACC_GYRO_CTRL3_C, ctrl3 | LSM6DS3_ACC_GYRO_BDU_BLOCK_UPDATE);

  Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);   // 247-byte MTU
  Bluefruit.begin(1, 0);
  Bluefruit.setTxPower(4);
  char name[24];
  snprintf(name, sizeof(name), "JuggleBall-%d", BALL_ID);
  Bluefruit.setName(name);
  Bluefruit.Periph.setConnInterval(6, 12);        // 7.5 - 15 ms

  svcBall.begin();

  chStream.setProperties(CHR_PROPS_NOTIFY);
  chStream.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  chStream.setFixedLen(sizeof(StreamPkt));
  chStream.begin();

  chEvent.setProperties(CHR_PROPS_NOTIFY);
  chEvent.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  chEvent.setFixedLen(sizeof(EventPkt));
  chEvent.begin();

  chCtrl.setProperties(CHR_PROPS_WRITE | CHR_PROPS_WRITE_WO_RESP);
  chCtrl.setPermission(SECMODE_NO_ACCESS, SECMODE_OPEN);
  chCtrl.setMaxLen(8);
  chCtrl.setWriteCallback(onCtrl);
  chCtrl.begin();

  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.Advertising.addService(svcBall);
  Bluefruit.ScanResponse.addName();
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 160);
  Bluefruit.Advertising.setFastTimeout(30);
  Bluefruit.Advertising.start(0);

  gotoState(ST_HANDLED);
}

// ---------------------------------------------------------------- loop
void loop() {
  static uint32_t next = 0;
  uint32_t now = micros();
  if ((int32_t)(now - next) < 0) return;
  next = (next == 0) ? now + SAMPLE_US : next + SAMPLE_US;

  uint32_t tms = millis();

  // ---- read + correct ----------------------------------------------------
  float ax = imu.readFloatAccelX() * cfg.accelScale;
  float ay = imu.readFloatAccelY() * cfg.accelScale;
  float az = imu.readFloatAccelZ() * cfg.accelScale;
  float gx = imu.readFloatGyroX() - cfg.gyroBias[0];
  float gy = imu.readFloatGyroY() - cfg.gyroBias[1];
  float gz = imu.readFloatGyroZ() - cfg.gyroBias[2];

  float aMag = sqrtf(ax*ax + ay*ay + az*az);          // g
  float wMag = sqrtf(gx*gx + gy*gy + gz*gz);          // deg/s
  pushMag(aMag);
  float var = magVar();

  // ---- calibration passes ------------------------------------------------
  if (calMode != CAL_NONE) {
    if (calMode == CAL_BIAS) {
      calGx += gx + cfg.gyroBias[0];
      calGy += gy + cfg.gyroBias[1];
      calGz += gz + cfg.gyroBias[2];
      calA  += aMag / cfg.accelScale;
      calN++;
      if (tms > calUntil && calN > 100) {
        cfg.gyroBias[0] = calGx / calN;
        cfg.gyroBias[1] = calGy / calN;
        cfg.gyroBias[2] = calGz / calN;
        cfg.accelScale  = 1.0f / (float)(calA / calN);
        finishCal();
      }
    } else {                                  // noise-floor learning
      if (var  > calVarMax) calVarMax = var;
      if (wMag > calWMax)   calWMax   = wMag;
      if (tms > calUntil) {
        if (calMode == CAL_GROUND) { learnedGroundVar = calVarMax; learnedGroundW = calWMax; }
        else                       { learnedHandVar   = calVarMax; learnedHandW   = calWMax; }
        finishCal();
      }
    }
    return;
  }

  // ---- free fall ---------------------------------------------------------
  if (aMag < cfg.freefallG) { if (!ffStart) ffStart = tms; }
  else ffStart = 0;
  bool falling = ffStart && (tms - ffStart) >= FF_CONFIRM_MS;

  // ---- catch or bounce? --------------------------------------------------
  // A floor bounce is back in the air within tens of ms. A hand holds on
  // for hundreds of ms before the next throw.
  if (state == ST_IMPACT) {
    if (aMag > peakG) peakG = aMag;
    float flight = (impactAt - tLaunch) / 1000.0f;
    if (falling && (ffStart - impactAt) <= BOUNCE_WIN_MS) {
      onFloor = true; landedAt = tms;
      gotoState(ST_BOUNCING);
      sendEvent(EV_LAND_GROUND, flight, peakG);
    } else if ((tms - impactAt) > BOUNCE_WIN_MS &&
               (!ffStart || (ffStart - impactAt) > BOUNCE_WIN_MS)) {
      gotoState(ST_HANDLED);
      sendEvent(EV_CATCH, flight, peakG);
      sendEvent(EV_APEX, flight, 9.81f * flight * flight / 8.0f);
    }
  }

  // ---- throw -------------------------------------------------------------
  if (falling && (state == ST_HANDLED || state == ST_REST_HAND ||
                  state == ST_REST_GROUND)) {
    tLaunch = ffStart; onFloor = false; softSince = 0;
    gotoState(ST_FLIGHT);
    sendEvent(EV_THROW);
  }
  if (state == ST_BOUNCING) {
    if (falling) landedAt = tms;                      // still hopping
    else if ((tms - landedAt) > BOUNCE_END_MS) gotoState(ST_HANDLED);
  }

  // ---- impact ------------------------------------------------------------
  if (state == ST_FLIGHT) {
    if (aMag >= cfg.freefallG) { if (!softSince) softSince = tms; }
    else softSince = 0;
    if (aMag > cfg.impactG || (softSince && (tms - softSince) >= SOFT_LAND_MS)) {
      peakG = aMag; impactAt = softSince ? softSince : tms;
      gotoState(ST_IMPACT);
    }
  }

  // ---- stillness ---------------------------------------------------------
  bool still = (fabsf(magMean() - 1.0f) < cfg.stillTolG) &&
               (var  < cfg.stillVar) &&
               (wMag < cfg.stillW);
  if (!still) { stillSince = 0; if (moveCount < 255) moveCount++; }
  else { moveCount = 0; if (stillSince == 0) stillSince = tms; }

  // ---- settle -> classify hand vs ground ---------------------------------
  if (stillSince && (tms - stillSince) >= cfg.holdMs &&
      (state == ST_HANDLED || state == ST_BOUNCING)) {
    int score = 0;
    if (onFloor)                   score += 3;   // bounced off the floor
    if (var < cfg.jitterSplit)     score += 2;   // dead still, no hand tremor
    if (wMag < 1.5f)               score += 1;   // so a ball set down gently
                                                 // still scores 3 -> ground
    bool ground = (score >= 3);
    gotoState(ground ? ST_REST_GROUND : ST_REST_HAND);
    sendEvent(EV_REST, ground ? 1 : 0, 0);
    onFloor = false;
    sFill = 0;                                   // drop the partial batch
  }

  // ---- wake from rest ----------------------------------------------------
  if ((state == ST_REST_HAND || state == ST_REST_GROUND) && moveCount >= 4) {
    gotoState(ST_HANDLED);
    sendEvent(EV_PICKED_UP);
  }

  // ---- stream ------------------------------------------------------------
  if (streaming() && Bluefruit.connected()) {
    if (++decim >= STREAM_DECIM) {
      decim = 0;
      if (sFill == 0) { spkt.t_ms = tms; spkt.dt_ms = 1000 / (SAMPLE_HZ/STREAM_DECIM); }
      spkt.s[sFill][0] = (int16_t)(ax * 1000.0f);
      spkt.s[sFill][1] = (int16_t)(ay * 1000.0f);
      spkt.s[sFill][2] = (int16_t)(az * 1000.0f);
      spkt.s[sFill][3] = (int16_t)(gx * 10.0f);
      spkt.s[sFill][4] = (int16_t)(gy * 10.0f);
      spkt.s[sFill][5] = (int16_t)(gz * 10.0f);
      if (++sFill >= BATCH) {
        spkt.state  = (uint8_t)state;
        spkt.ballId = BALL_ID;
        spkt.n      = BATCH;
        chStream.notify((uint8_t*)&spkt, sizeof(spkt));
        sFill = 0;
      }
    }
  } else {
    sFill = 0;
    if (tms - lastBeat > HEARTBEAT_MS) { lastBeat = tms; sendEvent(EV_HEARTBEAT); }
  }
}
