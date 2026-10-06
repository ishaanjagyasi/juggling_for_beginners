# Juggling for Beginners

Smart juggling balls: a Seeed XIAO nRF52840 Sense inside a tennis ball streams its IMU over Bluetooth, and detects throws, catches, floor landings and rest. Up to three balls at once.

## How it works

An accelerometer reads **0 g in flight** (free fall) and **1 g at rest**. The ball uses that to tell what's happening:

| Event | How it's detected |
|---|---|
| `THROW` | weightless for 50 ms or more |
| `CATCH` | hits something and stays down (no bounce within 80 ms). Reports flight time and height |
| `LAND_GROUND` | hits something and is airborne again within 80 ms (it bounced) |
| `REST` hand / ground | still for 250 ms. Hand has a tiny tremor, the floor doesn't |

While resting, the ball stops streaming and only sends a heartbeat once a second.

Onboard LED: **red** resting on a surface, **green** resting in hand, **blue** in the air, **off** moving. At power-on each ball blinks green its own number (1, 2 or 3).

Sampling runs at 200 Hz; 100 Hz is streamed over BLE in packets of 8 samples. With three balls connected at once, expect roughly 50–65 Hz each, because they share the radio. Events are unaffected.

---

# Setting up on a new computer

## 1. Get the code

```
git clone https://github.com/ishaanjagyasi/juggling_for_beginners.git
cd juggling_for_beginners
```

## 2. To use balls that are already flashed

This is all you need — one library:

```
pip3 install bleak
```

Then:

```
python3 tools/identify.py                   # shake a ball, see its number
python3 tools/receiver.py                   # connect to every ball, log CSV
python3 tools/receiver.py --ball 2          # just ball 2
python3 tools/receiver.py --ball 1 3        # balls 1 and 3
python3 tools/receiver.py --raw             # stream even while at rest
python3 tools/receiver.py --calibrate --ball 1   # guided calibration
```

Each ball logs to its own file: `capture_<time>_ball<N>.csv`.

**Calibration lives on the ball, not on the computer.** A new computer does not need recalibration.

**macOS:** the first run asks for Bluetooth permission. Allow it, or tick Terminal under System Settings → Privacy & Security → Bluetooth.

## 3. The Juggle Synth page

Needs only **Chrome** (Web Bluetooth; Safari and Firefox can't do it).

```
cd sound
python3 -m http.server 8000
```

Open http://localhost:8000, click **Add ball** once per ball.

A ball accepts **one connection at a time**, so close `receiver.py` before connecting from the browser.

| Ball | Sound |
|---|---|
| Moving in hand | drone, brighter with more motion |
| Tilt | drone note |
| Spin | FM growl, shimmer in flight |
| Throw | whoosh + rising whistle |
| Catch | bell, higher throw = higher note |
| Floor | distorted thud + clang, per bounce |
| Rest in hand | breathing chord |
| Rest on floor | fades to silence |

Each ball gets its own pitch and stereo position: ball 1 left, ball 2 centre, ball 3 right. Three presets: Glass, Machine, Void.

Demo mode without any ball: `T` throw, `C` catch, `G` floor, `H` rest in hand, `F` rest on floor, `P` pick up, `1`/`2`/`3` pick which ball the keys drive. Mouse over the graph tilts and shakes.

## 4. Working with Max (OSC)

This is the main path. Max never touches Bluetooth; the Python receiver does that and forwards everything as OSC.

**Launch order**

1. Power on the balls (they advertise as soon as they have power).
2. Quit anything else that holds them — a ball accepts **one connection at a time**, so close the Chrome synth page first.
3. In Max, add `[udpreceive 7400]`.
4. In Terminal:

   ```
   cd juggling_for_beginners
   python3 tools/receiver.py --osc
   ```

   Wait for `found: ball 1, ball 2, ball 3` and `sending OSC to 127.0.0.1:7400`.

It keeps writing CSV logs at the same time, so a Max session is also a recording.

```
python3 tools/receiver.py --osc                  # 127.0.0.1:7400
python3 tools/receiver.py --osc 10.0.0.5:9000    # another machine
python3 tools/receiver.py --osc --osc-rate 100   # every sample, no thinning
python3 tools/receiver.py --osc --ball 1 2       # only these balls
```

**Addresses** — `N` is the ball number.

| Address | Arguments | When |
|---|---|---|
| `/ball/N/imu` | `ax ay az gx gy gz` | continuously while moving. Acceleration per axis in g, rotation per axis in °/s |
| `/ball/N/motion` | `amag wmag tilt energy` | same rate. Total acceleration, total spin, tilt 0–1, smoothed movement |
| `/ball/N/throw` | `1` | ball leaves the hand |
| `/ball/N/catch` | `flight_s height_m peak_g` | caught |
| `/ball/N/floor` | `flight_s height_m peak_g` | hit the floor |
| `/ball/N/bounce` | `peak_g` | each further bounce (worked out on the computer) |
| `/ball/N/pickup` | `1` | picked up from rest |
| `/ball/N/rest` | `0` hand / `1` floor | came to rest |
| `/ball/N/state` | symbol | on change: `rest_hand` `rest_ground` `handled` `flight` `impact` `bouncing` |
| `/ball/N/connected` | `1` / `0` | link up or lost |
| `/juggle/airborne` | `n` | how many balls are in the air right now |
| `/juggle/balls` | `n` | how many are connected |
| `/juggle/throws` `/juggle/catches` `/juggle/drops` | `n` | running counts since launch |

A resting ball sends nothing at all, by design. Add `--raw` to make it stream anyway.

**Rate.** `--osc-rate` is per ball; the default 50 sends every second sample. The balls share one radio, so with three connected each delivers roughly 50–65 samples a second, and the thinned output lands around 25–32 Hz per ball. Events are never thinned.

**Routing in Max**

```
[udpreceive 7400]
|
[route /ball/1 /ball/2 /ball/3 /juggle]
|
[route /imu /motion /throw /catch /floor /bounce /pickup /rest /state /connected]
```

## 5. To build and flash the firmware

Only needed to change the ball's code.

1. Install the **Arduino IDE**.
2. **File → Preferences → Additional boards manager URLs**, add:
   `https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json`
3. **Tools → Board → Boards Manager**: install **Seeed nRF52 Boards**. Pick *Seeed XIAO nRF52840 Sense* — **not** the mbed version, the code won't build against it.
4. **Tools → Manage Libraries**: install **Seeed Arduino LSM6DS3**.
5. **macOS only:** the Seeed package calls `python`, which modern macOS doesn't have, so uploads fail at the last step. Create `platform.local.txt` next to the package's `platform.txt` (at
   `~/Library/Arduino15/packages/Seeeduino/hardware/nrf52/<version>/`) containing:

   ```
   recipe.objcopy.uf2.pattern=/usr/local/bin/python3 "{runtime.platform.path}/tools/uf2conv/uf2_wrap.py" "{runtime.platform.path}/tools/uf2conv/uf2conv.py" "{build.board}" "{build.path}" "{build.source.path}" "{build.project_name}"
   ```

   Use the path `which python3` reports.
6. Open `firmware/juggling_ball/juggling_ball.ino`, set `BALL_ID` at the top (1, 2 or 3), and upload.

To flash several balls without editing the file, set the number at build time:

```
arduino-cli compile --fqbn Seeeduino:nrf52:xiaonRF52840Sense \
  --build-property "compiler.cpp.extra_flags=-DBALL_ID=2" --build-path /tmp/b2 firmware/juggling_ball
arduino-cli upload --fqbn Seeeduino:nrf52:xiaonRF52840Sense -p /dev/cu.usbmodemXXXX \
  --input-dir /tmp/b2 firmware/juggling_ball
```

**A board fresh from the factory won't accept an upload** ("No data received on serial port"). Press its reset button twice quickly; it appears as a drive called `XIAO-SENSE`. Copy a `.uf2` onto it:

```
python3 ~/Library/Arduino15/packages/Seeeduino/hardware/nrf52/<version>/tools/uf2conv/uf2conv.py \
  -f 0xADA52840 -c -o ball2.uf2 /tmp/b2/juggling_ball.ino.hex
cp ball2.uf2 /Volumes/XIAO-SENSE/
```

Boards flashed with this firmware accept normal uploads from then on.

## Hardware

- Seeed XIAO nRF52840 **Sense** (built-in LSM6DS3TR-C IMU + BLE)
- Single-cell 3.7 V LiPo on the BAT pads on the back (see `battery_pads_annotated.jpg`). Check polarity against GND with a multimeter before soldering; reversed polarity kills the board.
- Board and battery in foam, in the middle of the ball, USB-C port at a slit so you can charge and reflash without opening it.

## Calibrating a ball

```
python3 tools/receiver.py --calibrate --ball 1
```

Three measurements, three seconds each: ball still on a **table** (zeroes the sensor), still on the **floor**, then held still in your **hand** (these two learn the difference between floor-still and hand-still). Saved to the ball's flash, so it survives power cycles.

Do it **after** the board is inside the tennis ball; the foam changes how still it feels.

## Files

| Path | What it is |
|---|---|
| `firmware/juggling_ball/juggling_ball.ino` | the code running on each ball |
| `tools/receiver.py` | connect, print events, log CSV, run calibration |
| `tools/identify.py` | shake a ball to find out which number it is |
| `tools/oscout.py` | OSC encoding and the ball-to-address mapping used by `--osc` |
| `sound/index.html` | Juggle Synth: live view + sound, in Chrome |
| `battery_pads_annotated.jpg` | where to solder the battery |
