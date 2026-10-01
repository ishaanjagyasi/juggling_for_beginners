#!/usr/bin/env python3
"""
Which board is which?

Connects to every ball it can find and tells you, in plain words, which ball
number is moving. Pick up one board, shake it, and read the number.

    python3 tools/identify.py
"""
import asyncio, math, struct, sys, time

from bleak import BleakScanner, BleakClient

SVC    = "9a1e0000-7a4b-4f2b-8c1a-1f0d2b3c4d5e"
STREAM = "9a1e0001-7a4b-4f2b-8c1a-1f0d2b3c4d5e"
EVENT  = "9a1e0002-7a4b-4f2b-8c1a-1f0d2b3c4d5e"
QUIET_S  = 1.2                     # stop reporting after this long with no motion
GRACE_S  = 2.0                     # ignore whatever arrives right after connecting
SHAKE_G  = 0.35                    # how far from 1 g counts as a real shake


class Watcher:
    def __init__(self, num):
        self.num = num
        self.last = 0.0
        self.moving = False
        self.ready_at = time.monotonic() + GRACE_S

    def bump(self):
        if time.monotonic() < self.ready_at:
            return
        self.last = time.monotonic()
        if not self.moving:
            self.moving = True
            print(f"\n>>>  This is BALL {self.num}  <<<\n", flush=True)

    def tick(self):
        if self.moving and time.monotonic() - self.last > QUIET_S:
            self.moving = False


async def watch(num, dev, stop):
    w = Watcher(num)
    async with BleakClient(dev) as c:
        def on_event(_, data):
            if data[4] in (1, 2, 3):       # thrown, caught or dropped: definitely this one
                w.bump()

        def on_stream(_, data):
            # a ball only streams while it is moving; look for a real shake
            n = data[6]
            for i in range(n):
                o = 8 + i * 12
                ax, ay, az = struct.unpack_from("<hhh", data, o)
                if abs(math.dist((0, 0, 0), (ax / 1000, ay / 1000, az / 1000)) - 1) > SHAKE_G:
                    w.bump()
                    return

        await c.start_notify(EVENT, on_event)
        await c.start_notify(STREAM, on_stream)
        print(f"ball {num}: watching")
        while not stop.is_set():
            w.tick()
            await asyncio.sleep(0.2)


async def main():
    print("scanning...")
    found = {}
    for dev, adv in (await BleakScanner.discover(timeout=10.0, return_adv=True)).values():
        name = adv.local_name or dev.name or ""
        if name.startswith("JuggleBall"):
            try:
                found.setdefault(int(name.rsplit("-", 1)[1]), dev)
            except (IndexError, ValueError):
                pass
    if not found:
        sys.exit("no balls found — are they powered on?")

    stop = asyncio.Event()
    print(f"found {len(found)} ball(s): {', '.join(str(n) for n in sorted(found))}\n")
    print("Now pick up ONE board and shake it. Mark it with the number shown.")
    print("Then do the next one. Press Ctrl-C when you're done.\n")
    await asyncio.gather(*(watch(n, d, stop) for n, d in sorted(found.items())))


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\ndone")
