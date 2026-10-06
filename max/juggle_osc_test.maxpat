{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 8,
      "minor": 5,
      "revision": 0,
      "architecture": "x64",
      "modernui": 1
    },
    "classnamespace": "box",
    "rect": [
      60.0,
      80.0,
      1160.0,
      850.0
    ],
    "bglocked": 0,
    "openinpresentation": 0,
    "default_fontsize": 12.0,
    "default_fontface": 0,
    "default_fontname": "Arial",
    "gridonopen": 1,
    "gridsize": [
      15.0,
      15.0
    ],
    "gridsnaponopen": 1,
    "objectsnaponopen": 1,
    "statusbarvisible": 2,
    "toolbarvisible": 1,
    "lefttoolbarpinned": 0,
    "toptoolbarpinned": 0,
    "righttoolbarpinned": 0,
    "bottomtoolbarpinned": 0,
    "toolbars_unpinned_last_save": 0,
    "tallnewobj": 0,
    "boxanimatetime": 200,
    "enablehscroll": 1,
    "enablevscroll": 1,
    "devicewidth": 0.0,
    "description": "",
    "digest": "",
    "tags": "",
    "style": "",
    "subpatcher_template": "",
    "assistshowspatchername": 0,
    "boxes": [
      {
        "box": {
          "id": "obj-1",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            12.0,
            400.0,
            24.0
          ],
          "outlettype": [],
          "text": "JUGGLE BALLS \u2014 OSC test patch",
          "fontsize": 18.0
        }
      },
      {
        "box": {
          "id": "obj-2",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            40.0,
            760.0,
            20.0
          ],
          "outlettype": [],
          "text": "1. Power on the balls.   2. Close the Chrome synth page.   3. Run:  python3 tools/receiver.py --osc",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-3",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            58.0,
            760.0,
            20.0
          ],
          "outlettype": [],
          "text": "Numbers move only while a ball is moving \u2014 that is by design. A resting ball sends nothing.",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            20.0,
            92.0,
            130.0,
            22.0
          ],
          "outlettype": [
            ""
          ],
          "text": "udpreceive 7400"
        }
      },
      {
        "box": {
          "id": "obj-5",
          "maxclass": "toggle",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            180.0,
            92.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "int"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-6",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            212.0,
            95.0,
            360.0,
            20.0
          ],
          "outlettype": [],
          "text": "see every message in the Max console (Cmd-Shift-M) \u2014 noisy",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-7",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            180.0,
            128.0,
            50.0,
            22.0
          ],
          "outlettype": [
            ""
          ],
          "text": "gate"
        }
      },
      {
        "box": {
          "id": "obj-8",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            180.0,
            160.0,
            70.0,
            22.0
          ],
          "outlettype": [],
          "text": "print OSC"
        }
      },
      {
        "box": {
          "id": "obj-9",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            210.0,
            100.0,
            24.0
          ],
          "outlettype": [],
          "text": "BALL 1",
          "fontsize": 16.0
        }
      },
      {
        "box": {
          "id": "obj-10",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 11,
          "patching_rect": [
            20.0,
            238.0,
            340.0,
            22.0
          ],
          "outlettype": [
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
          ],
          "text": "route /ball/1/imu /ball/1/motion /ball/1/state /ball/1/throw /ball/1/catch /ball/1/floor /ball/1/bounce /ball/1/pickup /ball/1/rest /ball/1/connected"
        }
      },
      {
        "box": {
          "id": "obj-11",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            270.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "accel  ax ay az  (g)        gyro  gx gy gz  (deg/s)",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-12",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 6,
          "patching_rect": [
            20.0,
            290.0,
            180.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float",
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f f f f"
        }
      },
      {
        "box": {
          "id": "obj-13",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            20.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-14",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            76.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-15",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            132.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-16",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            188.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-17",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            244.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-18",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            300.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-19",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            352.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "motion   |a|      spin     tilt    energy",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-20",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 4,
          "patching_rect": [
            20.0,
            372.0,
            130.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f f"
        }
      },
      {
        "box": {
          "id": "obj-21",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            20.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-22",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            76.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-23",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            132.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-24",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            188.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-25",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            434.0,
            60.0,
            20.0
          ],
          "outlettype": [],
          "text": "state",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-26",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            20.0,
            454.0,
            150.0,
            22.0
          ],
          "outlettype": [
            ""
          ],
          "text": ""
        }
      },
      {
        "box": {
          "id": "obj-27",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            486.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "throw   catch    floor   bounce  pickup",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-28",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            20.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-29",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            76.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-30",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            132.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-31",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            188.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-32",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            244.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-33",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            540.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "catch / floor:   flight s   height m   peak g",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-34",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            20.0,
            560.0,
            110.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f"
        }
      },
      {
        "box": {
          "id": "obj-35",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            20.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-36",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            76.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-37",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            132.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-38",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            622.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "rest 0=hand 1=floor      connected",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-39",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            20.0,
            642.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-40",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            180.0,
            642.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-41",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            380.0,
            210.0,
            100.0,
            24.0
          ],
          "outlettype": [],
          "text": "BALL 2",
          "fontsize": 16.0
        }
      },
      {
        "box": {
          "id": "obj-42",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 11,
          "patching_rect": [
            380.0,
            238.0,
            340.0,
            22.0
          ],
          "outlettype": [
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
          ],
          "text": "route /ball/2/imu /ball/2/motion /ball/2/state /ball/2/throw /ball/2/catch /ball/2/floor /ball/2/bounce /ball/2/pickup /ball/2/rest /ball/2/connected"
        }
      },
      {
        "box": {
          "id": "obj-43",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            380.0,
            270.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "accel  ax ay az  (g)        gyro  gx gy gz  (deg/s)",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-44",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 6,
          "patching_rect": [
            380.0,
            290.0,
            180.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float",
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f f f f"
        }
      },
      {
        "box": {
          "id": "obj-45",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            380.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-46",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            436.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-47",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            492.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-48",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            548.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-49",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            604.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-50",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            660.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-51",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            380.0,
            352.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "motion   |a|      spin     tilt    energy",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-52",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 4,
          "patching_rect": [
            380.0,
            372.0,
            130.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f f"
        }
      },
      {
        "box": {
          "id": "obj-53",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            380.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-54",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            436.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-55",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            492.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-56",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            548.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-57",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            380.0,
            434.0,
            60.0,
            20.0
          ],
          "outlettype": [],
          "text": "state",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-58",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            380.0,
            454.0,
            150.0,
            22.0
          ],
          "outlettype": [
            ""
          ],
          "text": ""
        }
      },
      {
        "box": {
          "id": "obj-59",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            380.0,
            486.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "throw   catch    floor   bounce  pickup",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-60",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            380.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-61",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            436.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-62",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            492.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-63",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            548.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-64",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            604.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-65",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            380.0,
            540.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "catch / floor:   flight s   height m   peak g",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-66",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            380.0,
            560.0,
            110.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f"
        }
      },
      {
        "box": {
          "id": "obj-67",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            380.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-68",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            436.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-69",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            492.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-70",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            380.0,
            622.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "rest 0=hand 1=floor      connected",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-71",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            380.0,
            642.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-72",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            540.0,
            642.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-73",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            740.0,
            210.0,
            100.0,
            24.0
          ],
          "outlettype": [],
          "text": "BALL 3",
          "fontsize": 16.0
        }
      },
      {
        "box": {
          "id": "obj-74",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 11,
          "patching_rect": [
            740.0,
            238.0,
            340.0,
            22.0
          ],
          "outlettype": [
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
          ],
          "text": "route /ball/3/imu /ball/3/motion /ball/3/state /ball/3/throw /ball/3/catch /ball/3/floor /ball/3/bounce /ball/3/pickup /ball/3/rest /ball/3/connected"
        }
      },
      {
        "box": {
          "id": "obj-75",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            740.0,
            270.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "accel  ax ay az  (g)        gyro  gx gy gz  (deg/s)",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-76",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 6,
          "patching_rect": [
            740.0,
            290.0,
            180.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float",
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f f f f"
        }
      },
      {
        "box": {
          "id": "obj-77",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            740.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-78",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            796.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-79",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            852.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-80",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            908.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-81",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            964.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-82",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            1020.0,
            320.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-83",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            740.0,
            352.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "motion   |a|      spin     tilt    energy",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-84",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 4,
          "patching_rect": [
            740.0,
            372.0,
            130.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f f"
        }
      },
      {
        "box": {
          "id": "obj-85",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            740.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-86",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            796.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-87",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            852.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-88",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            908.0,
            402.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-89",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            740.0,
            434.0,
            60.0,
            20.0
          ],
          "outlettype": [],
          "text": "state",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-90",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "patching_rect": [
            740.0,
            454.0,
            150.0,
            22.0
          ],
          "outlettype": [
            ""
          ],
          "text": ""
        }
      },
      {
        "box": {
          "id": "obj-91",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            740.0,
            486.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "throw   catch    floor   bounce  pickup",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-92",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            740.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-93",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            796.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-94",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            852.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-95",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            908.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-96",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            964.0,
            506.0,
            24.0,
            24.0
          ],
          "outlettype": [
            "bang"
          ]
        }
      },
      {
        "box": {
          "id": "obj-97",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            740.0,
            540.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "catch / floor:   flight s   height m   peak g",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-98",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 3,
          "patching_rect": [
            740.0,
            560.0,
            110.0,
            22.0
          ],
          "outlettype": [
            "float",
            "float",
            "float"
          ],
          "text": "unpack f f f"
        }
      },
      {
        "box": {
          "id": "obj-99",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            740.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-100",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            796.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-101",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            852.0,
            590.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-102",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            740.0,
            622.0,
            340.0,
            20.0
          ],
          "outlettype": [],
          "text": "rest 0=hand 1=floor      connected",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-103",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            740.0,
            642.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-104",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            900.0,
            642.0,
            50.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-105",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            690.0,
            300.0,
            24.0
          ],
          "outlettype": [],
          "text": "WHOLE PATTERN",
          "fontsize": 16.0
        }
      },
      {
        "box": {
          "id": "obj-106",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 6,
          "patching_rect": [
            20.0,
            718.0,
            420.0,
            22.0
          ],
          "outlettype": [
            "",
            "",
            "",
            "",
            "",
            ""
          ],
          "text": "route /juggle/airborne /juggle/balls /juggle/throws /juggle/catches /juggle/drops"
        }
      },
      {
        "box": {
          "id": "obj-107",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            750.0,
            560.0,
            20.0
          ],
          "outlettype": [],
          "text": "in the air      connected        throws          catches          drops",
          "fontsize": 12.0
        }
      },
      {
        "box": {
          "id": "obj-108",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            20.0,
            770.0,
            60.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-109",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            120.0,
            770.0,
            60.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-110",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            220.0,
            770.0,
            60.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-111",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            320.0,
            770.0,
            60.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-112",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "patching_rect": [
            420.0,
            770.0,
            60.0,
            22.0
          ],
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "destination": [
            "obj-7",
            0
          ],
          "source": [
            "obj-5",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-7",
            1
          ],
          "source": [
            "obj-4",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-8",
            0
          ],
          "source": [
            "obj-7",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-10",
            0
          ],
          "source": [
            "obj-4",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-12",
            0
          ],
          "source": [
            "obj-10",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-13",
            0
          ],
          "source": [
            "obj-12",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-14",
            0
          ],
          "source": [
            "obj-12",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-15",
            0
          ],
          "source": [
            "obj-12",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-16",
            0
          ],
          "source": [
            "obj-12",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-17",
            0
          ],
          "source": [
            "obj-12",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-18",
            0
          ],
          "source": [
            "obj-12",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-20",
            0
          ],
          "source": [
            "obj-10",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-21",
            0
          ],
          "source": [
            "obj-20",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-22",
            0
          ],
          "source": [
            "obj-20",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-23",
            0
          ],
          "source": [
            "obj-20",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-24",
            0
          ],
          "source": [
            "obj-20",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-26",
            1
          ],
          "source": [
            "obj-10",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-28",
            0
          ],
          "source": [
            "obj-10",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-29",
            0
          ],
          "source": [
            "obj-10",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-30",
            0
          ],
          "source": [
            "obj-10",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-31",
            0
          ],
          "source": [
            "obj-10",
            6
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-32",
            0
          ],
          "source": [
            "obj-10",
            7
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-34",
            0
          ],
          "source": [
            "obj-10",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-34",
            0
          ],
          "source": [
            "obj-10",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-35",
            0
          ],
          "source": [
            "obj-34",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-36",
            0
          ],
          "source": [
            "obj-34",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-37",
            0
          ],
          "source": [
            "obj-34",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-39",
            0
          ],
          "source": [
            "obj-10",
            8
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-40",
            0
          ],
          "source": [
            "obj-10",
            9
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-42",
            0
          ],
          "source": [
            "obj-4",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-44",
            0
          ],
          "source": [
            "obj-42",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-45",
            0
          ],
          "source": [
            "obj-44",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-46",
            0
          ],
          "source": [
            "obj-44",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-47",
            0
          ],
          "source": [
            "obj-44",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-48",
            0
          ],
          "source": [
            "obj-44",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-49",
            0
          ],
          "source": [
            "obj-44",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-50",
            0
          ],
          "source": [
            "obj-44",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-52",
            0
          ],
          "source": [
            "obj-42",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-53",
            0
          ],
          "source": [
            "obj-52",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-54",
            0
          ],
          "source": [
            "obj-52",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-55",
            0
          ],
          "source": [
            "obj-52",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-56",
            0
          ],
          "source": [
            "obj-52",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-58",
            1
          ],
          "source": [
            "obj-42",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-60",
            0
          ],
          "source": [
            "obj-42",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-61",
            0
          ],
          "source": [
            "obj-42",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-62",
            0
          ],
          "source": [
            "obj-42",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-63",
            0
          ],
          "source": [
            "obj-42",
            6
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-64",
            0
          ],
          "source": [
            "obj-42",
            7
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-66",
            0
          ],
          "source": [
            "obj-42",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-66",
            0
          ],
          "source": [
            "obj-42",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-67",
            0
          ],
          "source": [
            "obj-66",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-68",
            0
          ],
          "source": [
            "obj-66",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-69",
            0
          ],
          "source": [
            "obj-66",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-71",
            0
          ],
          "source": [
            "obj-42",
            8
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-72",
            0
          ],
          "source": [
            "obj-42",
            9
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-74",
            0
          ],
          "source": [
            "obj-4",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-76",
            0
          ],
          "source": [
            "obj-74",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-77",
            0
          ],
          "source": [
            "obj-76",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-78",
            0
          ],
          "source": [
            "obj-76",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-79",
            0
          ],
          "source": [
            "obj-76",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-80",
            0
          ],
          "source": [
            "obj-76",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-81",
            0
          ],
          "source": [
            "obj-76",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-82",
            0
          ],
          "source": [
            "obj-76",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-84",
            0
          ],
          "source": [
            "obj-74",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-85",
            0
          ],
          "source": [
            "obj-84",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-86",
            0
          ],
          "source": [
            "obj-84",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-87",
            0
          ],
          "source": [
            "obj-84",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-88",
            0
          ],
          "source": [
            "obj-84",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-90",
            1
          ],
          "source": [
            "obj-74",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-92",
            0
          ],
          "source": [
            "obj-74",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-93",
            0
          ],
          "source": [
            "obj-74",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-94",
            0
          ],
          "source": [
            "obj-74",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-95",
            0
          ],
          "source": [
            "obj-74",
            6
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-96",
            0
          ],
          "source": [
            "obj-74",
            7
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-98",
            0
          ],
          "source": [
            "obj-74",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-98",
            0
          ],
          "source": [
            "obj-74",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-99",
            0
          ],
          "source": [
            "obj-98",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-100",
            0
          ],
          "source": [
            "obj-98",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-101",
            0
          ],
          "source": [
            "obj-98",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-103",
            0
          ],
          "source": [
            "obj-74",
            8
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-104",
            0
          ],
          "source": [
            "obj-74",
            9
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-106",
            0
          ],
          "source": [
            "obj-4",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-108",
            0
          ],
          "source": [
            "obj-106",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-109",
            0
          ],
          "source": [
            "obj-106",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-110",
            0
          ],
          "source": [
            "obj-106",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-111",
            0
          ],
          "source": [
            "obj-106",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-112",
            0
          ],
          "source": [
            "obj-106",
            4
          ]
        }
      }
    ],
    "dependency_cache": [],
    "autosave": 0
  }
}