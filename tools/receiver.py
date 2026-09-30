#!/usr/bin/env python3
"""
Receiver / calibration console for JuggleBall.

    pip install bleak
    python receiver.py                     # connect to every ball it finds
    python receiver.py --ball 2            # just ball 2
    python receiver.py --ball 1 3          # balls 1 and 3
    python receiver.py --raw               # stream even while at rest
    python receiver.py --calibrate --ball 1    # guided: table, floor, hand, save
    python receiver.py --cal bias --ball 1     # one calibration step

Each ball logs to its own CSV: <out>_ball<N>.csv
"""
import argparse, asyncio, struct, sys, time
from bleak import BleakScanner, BleakClient

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


def adv_name(dev, adv):
    """macOS caches device names, so prefer the name in the live advert."""
    return adv.local_name or dev.name or ""


async def find_balls(wanted, timeout=10.0):
    found = {}
    for dev, adv in (await BleakScanner.discover(timeout=timeout, return_adv=True)).values():
        name = adv_name(dev, adv)
        if not name.startswith("JuggleBall"):
            continue
        try:
            num = int(name.rsplit("-", 1)[1])
        except (IndexError, ValueError):
            continue
        if wanted and num not in wanted:
            continue
        found.setdefault(num, dev)
    return dict(sorted(found.items()))


class Ball:
    def __init__(self, num, dev, args):
        self.num, self.dev, self.args = num, dev, args
        self.csv = None
        self.cal_done = asyncio.Event()
        self.loop = asyncio.get_event_loop()

    def open_csv(self):
        path = self.args.out.replace(".csv", "") + f"_ball{self.num}.csv"
        self.csv = open(path, "w")
        self.csv.write("t_ms,state,ax_g,ay_g,az_g,gx_dps,gy_dps,gz_dps\n")
        return path

    def on_stream(self, _, data):
        f = struct.unpack(STREAM_FMT, data)
        t0, state, n, dt = f[0], f[1], f[3], f[4]
        s = f[5:]
        for i in range(n):
            ax, ay, az, gx, gy, gz = s[i * 6:i * 6 + 6]
            self.csv.write(f"{t0 + i*dt},{state},{ax/1000:.3f},{ay/1000:.3f},"
                           f"{az/1000:.3f},{gx/10:.1f},{gy/10:.1f},{gz/10:.1f}\n")

    def on_event(self, _, data):
        t, typ, st, ball, flags, v1, v2 = struct.unpack("<IBBBBff", data)
        name = EVENTS.get(typ, typ)
        if name == "CAL" and int(v1) in (0xFF, 0x06, 0x07):
            self.loop.call_soon_threadsafe(self.cal_done.set)
        if self.args.calibrate:            # keep the guided prompts readable
            return
        if name == "HEARTBEAT" and not self.args.verbose:
            return
        print(f"[{t/1000:8.2f}s] ball{ball} {name:<12} "
              f"state={STATES.get(st, st):<11} v1={v1:.4g} v2={v2:.4g}")

    async def run_cal(self, client, step):
        if step in ("bias", "ground", "hand"):
            for n in (3, 2, 1):            # let the ball settle after Enter
                print(f"  starting in {n}...", flush=True)
                await asyncio.sleep(1)
        self.cal_done.clear()
        await client.write_gatt_char(CTRL, bytes([CMDS[step]]), response=False)
        print(f"  {step}: measuring, keep still...")
        await asyncio.wait_for(self.cal_done.wait(), timeout=10)
        print(f"  {step}: done")

    async def session(self, stop):
        async with BleakClient(self.dev) as c:
            await c.start_notify(EVENT, self.on_event)
            if not (self.args.cal or self.args.calibrate):
                path = self.open_csv()
                await c.start_notify(STREAM, self.on_stream)
                print(f"ball {self.num}: connected, logging to {path}")
            if self.args.raw:
                await c.write_gatt_char(CTRL, bytes([0x10, 1]), response=False)

            if self.args.calibrate:
                for step, instruction in GUIDED:
                    await self.loop.run_in_executor(
                        None, input, f"\n{instruction}\nPress Enter when ready. ")
                    await self.run_cal(c, step)
                await self.run_cal(c, "save")
                print("\nCalibration saved. All done.")
                return
            if self.args.cal:
                await self.run_cal(c, self.args.cal)
                return

            await stop.wait()
        if self.csv:
            self.csv.close()


async def main(args):
    wanted = set(args.ball or [])
    if (args.cal or args.calibrate) and len(wanted) != 1:
        sys.exit("calibration works on one ball at a time — add --ball N")

    print("scanning for balls...")
    balls = await find_balls(wanted)
    if not balls:
        sys.exit("no ball found — is it powered and advertising?")
    print("found:", ", ".join(f"ball {n}" for n in balls))

    stop = asyncio.Event()
    objs = [Ball(n, d, args) for n, d in balls.items()]
    tasks = [asyncio.create_task(b.session(stop)) for b in objs]
    try:
        await asyncio.gather(*tasks)
    except asyncio.CancelledError:
        pass
    finally:
        stop.set()


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--ball", type=int, nargs="+", help="ball numbers, e.g. --ball 1 3")
    p.add_argument("--cal", choices=list(CMDS))
    p.add_argument("--calibrate", action="store_true",
                   help="guided calibration: table, floor, hand, then save")
    p.add_argument("--raw", action="store_true")
    p.add_argument("--out", default=f"capture_{int(time.time())}")
    p.add_argument("-v", "--verbose", action="store_true")
    try:
        asyncio.run(main(p.parse_args()))
    except KeyboardInterrupt:
        print("\nstopped")
