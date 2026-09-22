#!/usr/bin/env python3
"""
Receiver / calibration console for JuggleBall.

    pip install bleak
    python receiver.py                 # connect, print events, log CSV
    python receiver.py --cal bias      # 0x01  ball still on a table, 3 s
    python receiver.py --cal ground    # 0x02  ball resting on the floor, 3 s
    python receiver.py --cal hand      # 0x03  ball held still in hand, 3 s
    python receiver.py --cal save      # 0x06  persist to flash
    python receiver.py --calibrate     # guided: all of the above in one go
    python receiver.py --raw           # 0x10  stream even while at rest
"""
import argparse, asyncio, struct, sys, time
from bleak import BleakClient, BleakScanner

SVC    = "9a1e0000-7a4b-4f2b-8c1a-1f0d2b3c4d5e"
STREAM = "9a1e0001-7a4b-4f2b-8c1a-1f0d2b3c4d5e"
EVENT  = "9a1e0002-7a4b-4f2b-8c1a-1f0d2b3c4d5e"
CTRL   = "9a1e0003-7a4b-4f2b-8c1a-1f0d2b3c4d5e"

STATES = {0: "REST_HAND", 1: "REST_GROUND", 2: "HANDLED",
          3: "FLIGHT", 4: "IMPACT", 5: "CALIB", 6: "BOUNCING"}
EVENTS = {1: "THROW", 2: "CATCH", 3: "LAND_GROUND", 4: "REST",
          5: "PICKED_UP", 6: "HEARTBEAT", 7: "CAL", 8: "APEX"}
CMDS   = {"bias": 0x01, "ground": 0x02, "hand": 0x03,
          "save": 0x06, "reset": 0x07}

GUIDED = [("bias",   "Put the ball still on a TABLE and let go."),
          ("ground", "Put the ball still on the FLOOR and let go."),
          ("hand",   "Hold the ball in your hand, as still as you can.")]

BATCH = 8
STREAM_FMT = "<IBBBB" + "h" * (BATCH * 6)


async def main(args):
    print("scanning for JuggleBall...")
    dev = await BleakScanner.find_device_by_filter(
        lambda d, ad: (d.name or "").startswith("JuggleBall"), timeout=15.0)
    if not dev:
        sys.exit("no ball found — is it powered and advertising?")
    print(f"connecting to {dev.name} [{dev.address}]")

    csv = open(args.out, "w")
    csv.write("t_ms,state,ax_g,ay_g,az_g,gx_dps,gy_dps,gz_dps\n")

    def on_stream(_, data):
        f = struct.unpack(STREAM_FMT, data)
        t0, state, ball, n, dt = f[0], f[1], f[2], f[3], f[4]
        s = f[5:]
        for i in range(n):
            ax, ay, az, gx, gy, gz = s[i * 6:i * 6 + 6]
            csv.write(f"{t0 + i*dt},{state},{ax/1000:.3f},{ay/1000:.3f},"
                      f"{az/1000:.3f},{gx/10:.1f},{gy/10:.1f},{gz/10:.1f}\n")

    cal_done = asyncio.Event()
    loop = asyncio.get_running_loop()

    def on_event(_, data):
        t, typ, st, ball, flags, v1, v2 = struct.unpack("<IBBBBff", data)
        # 0xFF = a 3 s measurement finished; the other commands ack at once
        if EVENTS.get(typ) == "CAL" and int(v1) in (0xFF, 0x06, 0x07):
            loop.call_soon_threadsafe(cal_done.set)
        if args.calibrate:        # keep the guided prompts readable
            return
        name = EVENTS.get(typ, typ)
        if name == "HEARTBEAT" and not args.verbose:
            return
        print(f"[{t/1000:8.2f}s] ball{ball} {name:<12} "
              f"state={STATES.get(st, st):<11} v1={v1:.4g} v2={v2:.4g}")

    async with BleakClient(dev) as c:
        await c.start_notify(EVENT, on_event)
        await c.start_notify(STREAM, on_stream)
        async def run_cal(name):
            cal_done.clear()
            if name in ("bias", "ground", "hand"):
                for n in (3, 2, 1):             # let the ball settle after Enter
                    print(f"  starting in {n}...", flush=True)
                    await asyncio.sleep(1)
            await c.write_gatt_char(CTRL, bytes([CMDS[name]]), response=False)
            print(f"  {name}: measuring, keep still...")
            await asyncio.wait_for(cal_done.wait(), timeout=10)
            print(f"  {name}: done")

        if args.calibrate:
            for name, instruction in GUIDED:
                await loop.run_in_executor(
                    None, input, f"\n{instruction}\nPress Enter when ready. ")
                await run_cal(name)
            await run_cal("save")
            print("\nCalibration saved. All done.")
            csv.close()
            return
        if args.cal:
            await run_cal(args.cal)
            csv.close()
            return
        if args.raw:
            await c.write_gatt_char(CTRL, bytes([0x10, 1]), response=False)
            print("raw streaming forced on")
        print(f"logging to {args.out} — ctrl-C to stop")
        try:
            while True:
                await asyncio.sleep(1)
        except asyncio.CancelledError:
            pass
        finally:
            csv.close()


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--cal", choices=list(CMDS))
    p.add_argument("--calibrate", action="store_true",
                   help="guided calibration: table, floor, hand, then save")
    p.add_argument("--raw", action="store_true")
    p.add_argument("--out", default=f"capture_{int(time.time())}.csv")
    p.add_argument("-v", "--verbose", action="store_true")
    try:
        asyncio.run(main(p.parse_args()))
    except KeyboardInterrupt:
        print("\nstopped")
