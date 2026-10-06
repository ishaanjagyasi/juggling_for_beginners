"""
OSC output for the juggling balls — written for Max.

Addresses
  /ball/N/imu        ax ay az gx gy gz   acceleration (g), rotation (deg/s)
  /ball/N/motion     amag wmag tilt energy
  /ball/N/throw      1
  /ball/N/catch      flight_s height_m peak_g
  /ball/N/floor      flight_s height_m peak_g
  /ball/N/bounce     peak_g              every bounce after the first
  /ball/N/pickup     1
  /ball/N/rest       0 in hand / 1 on the floor
  /ball/N/state      symbol: rest_hand rest_ground handled flight impact bouncing
  /ball/N/connected  1 / 0
  /juggle/airborne   how many balls are in the air right now
  /juggle/balls      how many are connected
  /juggle/throws     running counts since start
  /juggle/catches
  /juggle/drops

The continuous messages are rate limited (default 50 Hz per ball); events and
bounce detection always run on every sample.
"""
import math
import socket
import struct
import time

STATE_NAMES = {0: "rest_hand", 1: "rest_ground", 2: "handled",
               3: "flight", 4: "impact", 5: "calib", 6: "bouncing"}

STREAM_HZ     = 100     # what the ball sends when it is moving
BOUNCE_G      = 2.5     # a spike this big during a bounce counts as a hit
BOUNCE_GAP_S  = 0.06    # ignore hits closer together than this
AFTER_LAND_S  = 0.15    # the firmware already reported the first floor hit


def _ostr(s):
    """An OSC string: null terminated, padded to a multiple of 4 bytes."""
    b = s.encode("utf-8") + b"\0"
    return b + b"\0" * (-len(b) % 4)


def encode(address, *args):
    tags, body = ",", b""
    for a in args:
        if isinstance(a, bool):
            tags += "i"; body += struct.pack(">i", int(a))
        elif isinstance(a, int):
            tags += "i"; body += struct.pack(">i", a)
        elif isinstance(a, float):
            tags += "f"; body += struct.pack(">f", a)
        else:
            tags += "s"; body += _ostr(str(a))
    return _ostr(address) + _ostr(tags) + body


class _BallState:
    def __init__(self):
        self.energy = 0.0
        self.count = 0
        self.prev_mag = 1.0
        self.landed_at = 0.0
        self.last_bounce = 0.0
        self.state = None


class OscOut:
    def __init__(self, host="127.0.0.1", port=7400, rate=50):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.target = (host, int(port))
        # samples arrive in bursts of 8, so thin them by counting samples
        # rather than by the clock
        self.decim = max(1, round(STREAM_HZ / float(rate)))
        self.balls = {}
        self.airborne = set()
        self.connected = set()
        self.throws = self.catches = self.drops = 0

    def __str__(self):
        return (f"{self.target[0]}:{self.target[1]}, every {self.decim} "
                f"sample{'s' if self.decim > 1 else ''} (~{STREAM_HZ // self.decim} Hz per ball)")

    def send(self, address, *args):
        try:
            self.sock.sendto(encode(address, *args), self.target)
        except OSError:
            pass                      # nothing listening yet is not an error

    def _ball(self, num):
        return self.balls.setdefault(num, _BallState())

    # ---------------------------------------------------------------- link
    def set_connected(self, num, up):
        self._ball(num)
        self.connected.add(num) if up else self.connected.discard(num)
        if not up:
            self.airborne.discard(num)
            self.send("/juggle/airborne", len(self.airborne))
        self.send(f"/ball/{num}/connected", 1 if up else 0)
        self.send("/juggle/balls", len(self.connected))

    # ---------------------------------------------------------------- state
    def _set_state(self, num, code):
        b = self._ball(num)
        name = STATE_NAMES.get(code, str(code))
        if name == b.state:
            return
        b.state = name
        self.send(f"/ball/{num}/state", name)
        was = len(self.airborne)
        self.airborne.add(num) if name == "flight" else self.airborne.discard(num)
        if len(self.airborne) != was:
            self.send("/juggle/airborne", len(self.airborne))

    # ---------------------------------------------------------------- events
    def on_event(self, num, typ, state_code, v1, v2):
        self._set_state(num, state_code)
        if typ == 1:                                        # THROW
            self.throws += 1
            self.send(f"/ball/{num}/throw", 1)
            self.send("/juggle/throws", self.throws)
        elif typ == 2:                                      # CATCH
            self.catches += 1
            self.send(f"/ball/{num}/catch", float(v1), 9.81 * v1 * v1 / 8.0, float(v2))
            self.send("/juggle/catches", self.catches)
        elif typ == 3:                                      # LAND_GROUND
            self.drops += 1
            self._ball(num).landed_at = time.monotonic()
            self.send(f"/ball/{num}/floor", float(v1), 9.81 * v1 * v1 / 8.0, float(v2))
            self.send("/juggle/drops", self.drops)
        elif typ == 4:                                      # REST
            self.send(f"/ball/{num}/rest", int(v1))
        elif typ == 5:                                      # PICKED_UP
            self.send(f"/ball/{num}/pickup", 1)

    # ---------------------------------------------------------------- motion
    def on_sample(self, num, state_code, ax, ay, az, gx, gy, gz):
        b = self._ball(num)
        self._set_state(num, state_code)
        amag = math.sqrt(ax * ax + ay * ay + az * az)
        wmag = math.sqrt(gx * gx + gy * gy + gz * gz)
        b.energy = 0.85 * b.energy + 0.15 * (abs(amag - 1.0) + wmag / 400.0)
        now = time.monotonic()

        # bounces after the first one: the ball only reports the first hit
        if (b.state == "bouncing" and amag > BOUNCE_G and b.prev_mag <= BOUNCE_G
                and now - b.landed_at > AFTER_LAND_S and now - b.last_bounce > BOUNCE_GAP_S):
            b.last_bounce = now
            self.send(f"/ball/{num}/bounce", float(amag))
        b.prev_mag = amag

        b.count += 1
        if b.count % self.decim:
            return
        tilt = math.acos(max(-1.0, min(1.0, az / amag))) / math.pi if amag > 0.01 else 0.0
        self.send(f"/ball/{num}/imu", float(ax), float(ay), float(az),
                  float(gx), float(gy), float(gz))
        self.send(f"/ball/{num}/motion", float(amag), float(wmag), float(tilt), float(b.energy))
