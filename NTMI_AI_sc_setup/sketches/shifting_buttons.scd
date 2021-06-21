/*******  shiftkey sketch for NTMI **********

This is a test mode for how button shifting logic on the NTMI could work.

The principles are:
1. When a single button is pressed, it does its normal action WHEN RELEASED.

2. RIGHT SIDE: holding a button down sets up a shifted action for the left buttons;
this shifted action is used when a left button is pressed while the right button still held.

The right button shift modes are:
--- right top button \preUp - steps UP ndefs in the slots ---
TEST: hold right button \preUp, then click left slot1:
-> posts *** rshift 1 action: slot1 NEXT ndef

--- right middle button \preDown steps down ndefs in the slots ---
TEST: hold middle right \preDown, then click on left slot4
-> posts *** rshift 4 action: slot1 PREV ndef

--- right bottom button \touchMove selects random new ndef on a slot ---
TEST: hold down bottom right \touchMove, then click on any left button
-> posts *** rshift ? action: slot1 RAND ndef


3. LEFT SIDE: Holding a left button selects its slot for the 3 shifted actions of the right buttons.

these actions are:
top right button: step volume of a slot UP
middle right button: step volume of a slot DOWM
bottom right button: choose new random preset for the ndef in this slot.

TESTS: hold down left \slot1, click right button \preUp
-> *** slot1 vol goes UP a step
hold left \slot2, click right \preDown
-> *** slot2 vol vol goes DOWN a step
hold left \slot4, click right \touchMove
-> *** slot4 preset RAND


NOTE: With two thumbs, one can usually only hold down one button on each side,
so pressing more than two buttons is not guaranteed to work or be useful.

For completeness, we can still define what should happen:
4. The shift mode is always only defined by the FIRST button held down;
When the first button is from the right side, all left buttons are shifted to that mode;
all right buttons only do their usual thing.

When the first button is from the left side, all right buttons are in shift mode;
when clicked, each right button applies its shift action to the selected slot/ndef.
Multiple left buttons held down may also receive the same change, but not guaranteed.



****************************/
w = Window("test").front;
f = Font(Font.defaultMonoFace, 24);
w.layout = HLayout(
	VLayout(
		*~lefts = [ \slot1, \slot2, \slot3, \slot4] .collect { |name, i|
			Button(w).states_([[name], [name, nil, Color.green]]).font_(f)
		},
	),
	VLayout(
		*~rights = [\preUp, \preDown, \touchMove].collect { |name, i|
			Button(w).states_([[name], [name, nil, Color.green]]).font_(f)
		},
	)
);

///////// right keys are shift keys for the left keys
///////// -> this enables one of three separate modes for the left keys.

/// e.g. hold down a right key, then press a left key:
/// left keys do the action indicated by the right shift number
(
// init:
~leftDown = List[];
~rightDown = List[];

~rights.do { |but, i|
	var actionFunc;
	but.action = { |but|
		var btval = but.value;
		var btnum = 1 + i;
		var btname = but.states[0][0];
		var slotname;
		if (btval > 0) {
			~rightDown.add(btname).postln;
		} {
			~rightDown.remove(btname).postln;

			if (~leftDown.size == 0) {
				if (~shiftWasUsed) {
					~shiftWasUsed = false
				} {
					" % default action\n".postf(btname);
				}
			} {
				~shiftWasUsed = true;
				actionFunc = (
					1: { |slname| "*** % vol UP\n".postf(slname) },
					2: { |slname| "*** % vol Down\n".postf(slname) },
					3: { |slname| "*** % preset RAND\n".postf(slname) }
				)[btnum];
				actionFunc.value(~leftDown);
			};
		}
	}
};

~lefts.do { |but, i|
	var actionFunc;
	but.action = { |but|
		var btval = but.value;
		var btnum = 1 + i;
		var btname = but.states[0][0];
		if (btval > 0) {
			~leftDown.add(btname).postln;
		} {
			~leftDown.remove(btname).postln;
			if (~rightDown.size == 0) {
				if (~shiftWasUsed) {
					~shiftWasUsed = false
				} {
					" % default action\n".postf(btname);
				}
			} {
				~shiftWasUsed = true;
				actionFunc = (
					preUp: { "*** rshift 1 action: % NEXT ndef\n".postf(btname); },
					preDown: { "*** rshift 2 action: % PREV ndef\n".postf(btname); },
					touchMove: { "*** rshift 3 action: % RAND ndef\n".postf(btname); },
				)[~rightDown.first];
				actionFunc.value;
			}
		}
	}
};
);
