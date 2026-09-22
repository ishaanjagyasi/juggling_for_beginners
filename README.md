# Juggling for Beginners

Smart juggling ball: a Seeed XIAO nRF52840 Sense inside a tennis ball streams its IMU over Bluetooth, and detects throws, catches, floor landings and rest.

## How it works

An accelerometer reads **0 g in flight** (free fall) and **1 g at rest**. The ball uses that to tell what's happening:

| Event | How it's detected |
|---|---|
| `THROW` | weightless for 50 ms or more |
| `CATCH` | hits something and stays down (no bounce within 80 ms). Reports flight time and height |
| `LAND_GROUND` | hits something and is airborne again within 80 ms (it bounced) |
| `REST` hand / ground | still for 250 ms. Hand has a tiny tremor, the floor doesn't |

While resting, the ball stops streaming and only sends a heartbeat once a second.

Onboard LED: **red** resting on a surface, **green** resting in hand, **blue** in the air, **off** moving.

## Hardware

- Seeed XIAO nRF52840 **Sense** (built-in LSM6DS3TR-C IMU + BLE)
- Single-cell 3.7 V LiPo on the BAT pads on the back (see `battery_pads_annotated.jpg`)

## Firmware

`firmware/juggling_ball/juggling_ball.ino`

- Arduino IDE board package: **Seeed nRF52 Boards** → *Seeed XIAO nRF52840 Sense* (not the mbed one)
- Library: **Seeed Arduino LSM6DS3**
- Set `BALL_ID` at the top for each ball

On macOS the Seeed package calls `python`, which doesn't exist. Add a `platform.local.txt` next to its `platform.txt` that points `recipe.objcopy.uf2.pattern` at `python3`.

## Receiver and calibration

```
pip3 install bleak
python3 tools/receiver.py              # print events, log CSV
python3 tools/receiver.py --calibrate  # guided: table, floor, hand, save
python3 tools/receiver.py --raw        # stream even while at rest
```

Samples at 200 Hz; streams 100 Hz over BLE in packets of 8.
