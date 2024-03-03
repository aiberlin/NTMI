/*
MUSIC THING 8mu faderbox + imu:
use as study for headless NTMI setup.

MKtl('mu8').gui;

**** fixed functions:
rightmost slider 8 is mainVol
motion sensors always go to influx

**** modal functions:
4 buttons toggle sounds on/off,
or when held, they set up modes for the sliders.

slider Modes:
no buttons held: -> sliders 1-7 got to influx

same mode for bt1, 2, or 3 down:
slider 7 changes mainFX preset
slider 6 changes main zoom
slider 5 changes mu8 zoom - experimental

button modes for sliders 1-4:
bt1 down: change slot volume
bt2 down: change slot presets
bt3 down: change slot sounds

this leaves button 4 free for an extra mode.

****

*/

NTMI.mu8 = (influxMode: \setRel, zoom: 1,
	butDown: Set[], butsUsedForMode: false);

MKtl.all.mu8.free;

MKtlDesc("music_thing_8mu").elAt(\sl).elements.do { |eldesc|
	eldesc.style.put(\height, 2);
};
MKtlDesc("music_thing_8mu").elAt(\acc).elements.do { |eldesc|
	eldesc.style.put(\height, 2);
};


MKtl('mu8', "music_thing_8mu");

NTMI.mu8.setRel = {
	NTMI.mu8.influxMode = 'setRel';
	"NTMI.mu8.influxMode = 'setRel';".postln;
};
NTMI.mu8.setAbs = {
	"NTMI.mu8 has no setAbs, so: ".postln;
	NTMI.mu8.setRel;
};

// rightmost slider is main vol:
MKtl('mu8').elAt(\sl, 7).action = { |sl|
	MFdef(\mainVolStep).(sl.deviceValue - sl.prevDeviceValue)
};

// all accels go to straight influx setRel, no setAbs mode
MKtl('mu8').elAt(\acc).action = { |ac|
	// inIndices, diffs, zoom
	MFdef(\setRelInf).(
		ac.indexInGroup,
		ac.value - ac.prevValue,
		NTMI.mu8.zoom * NTMI.zoom
	);
};

MKtl('mu8').elAt(\bt).action = { |bt|
	var slotIndex = bt.parent.indexInGroup;
	if (bt.indexInGroup == 0) {
		"on: ".post; [bt.name, bt.value].postln;
		NTMI.mu8.butDown.add(slotIndex).postln;
		NTMI.mu8.butModeUsed = false;
	} {
		"off: ".post; [bt.name, bt.value].postln;
		NTMI.mu8.butDown.remove(slotIndex).postln;
		if (NTMI.mu8.butModeUsed) {
			"% was used for mode.\n".postf(bt.name);
			NTMI.mu8.butModeUsed = false;
		} {
			NTMI.slots.toggleAt(slotIndex);
		};
	};
};

MKtl('mu8').addNamed(\modSl, MKtl('mu8').elAt(\sl, (0..6)));

NTMI.mu8.zoomSpec = [0, 4, \amp].asSpec;
NTMI.mu8.lastPreTime = 0;
(
MKtl('mu8').elAt(\modSl).action = { |sl|
	case { NTMI.mu8.butDown.isEmpty } {
		// "influx".postln;
		// inIndices, diffs, zoom
		MFdef(\setRelInf).(
			sl.indexInGroup,
			sl.value - sl.prevValue,
			NTMI.mu8.zoom * NTMI.zoom
		);
	} {
		var step = sl.deviceValue - sl.prevDeviceValue;

		// "mode buts: %\n".postf(NTMI.mu8.butDown);
		NTMI.mu8.butModeUsed = true;
		case { sl.indexInGroup == 6 } {
			var now = Main.elapsedTime;
			// speed limit to 0.25 sec!
			if (now - NTMI.mu8.lastPreTime > 0.25) {
				MFdef('mainPreStep').(step);
				NTMI.mu8.lastPreTime = now;
			};

		} { sl.indexInGroup == 5 } {
			// "main zoom".postln;
			NTMI.incZoom(sl.deviceValue - sl.prevDeviceValue / 64);

		} { sl.indexInGroup == 4 } {
			var uniNewVal = NTMI.mu8.zoomSpec.unmap(NTMI.mu8.zoom) + (step / 64);
			NTMI.mu8.zoom = NTMI.mu8.zoomSpec.map(uniNewVal);
			"NTMI.mu8.zoom: %\n".postf(NTMI.mu8.zoom);
		} { sl.indexInGroup < 4 } {
			var ndef = NTMI.ndefs[sl.indexInGroup];

			// "slot mode:".postln;
			case { NTMI.mu8.butDown.includes(0) } {
				MFdef(\ndefVolStep).(ndef, step)

			} { NTMI.mu8.butDown.includes(1) } {
				NTMI.pre.stepNdefInf(ndef, step)

			} { NTMI.mu8.butDown.includes(2) } {
				NTMI.slots.stepNext(sl.indexInGroup, step)

			};
		}
	};
};
);
