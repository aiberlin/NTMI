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

// Use makeMKtl and NTMI.currInfo to support multiple hardware MKtls:
// arguments:MKtl name, desc filename, info reg. multiple hardware
var m = NTMI.makeMKtl('mu8', "music_thing_8mu", NTMI.currInfo);
m;

// tweak gui look:
MKtlDesc("music_thing_8mu").elAt(\sl).elements.do { |eldesc|
	eldesc.style.put(\height, 2);
};
MKtlDesc("music_thing_8mu").elAt(\acc).elements.do { |eldesc|
	eldesc.style.put(\height, 2);
};

m.addHalo(\butDown, Set[]);
m.addHalo(\butsUsedForMode, false);

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
		m.getHalo.zoom * NTMI.zoom
	);
};

MKtl('mu8').elAt(\bt).action = { |bt|
	var slotIndex = bt.parent.indexInGroup;
	if (bt.indexInGroup == 0) {
		"on: ".post; [bt.name, bt.value].postln;
		m.getHalo.butDown.add(slotIndex).postln;
		m.getHalo.butModeUsed = false;
	} {
		"off: ".post; [bt.name, bt.value].postln;
		m.getHalo.butDown.remove(slotIndex).postln;
		if (m.getHalo.butModeUsed) {
			"% was used for mode.\n".postf(bt.name);
			m.getHalo.butModeUsed = false;
		} {
			NTMI.slots.toggleAt(slotIndex);
		};
	};
};

MKtl('mu8').addNamed(\modSl, MKtl('mu8').elAt(\sl, (0..6)));

(
MKtl('mu8').elAt(\modSl).action = { |sl|
	case { m.getHalo.butDown.isEmpty } {
		// "influx".postln;
		// inIndices, diffs, zoom
		MFdef(\setRelInf).(
			sl.indexInGroup,
			sl.value - sl.prevValue,
			m.getHalo.zoom * NTMI.zoom
		);
	} {
		var step = sl.deviceValue - sl.prevDeviceValue;

		// "mode buts: %\n".postf(m.getHalo.butDown);
		m.getHalo.butModeUsed = true;
		case { sl.indexInGroup == 6 } {
			var now = Main.elapsedTime;
			// speed limit to 0.25 sec!
			if (now - m.getHalo.lastPreTime > 0.25) {
				MFdef('mainPreStep').(step);
				m.getHalo.lastPreTime = now;
			};

		} { sl.indexInGroup == 5 } {
			// "main zoom".postln;
			NTMI.incZoom(sl.deviceValue - sl.prevDeviceValue / 64);

		} { sl.indexInGroup == 4 } {
			var spec = \xZoom.asSpec;
			var uniNewVal = spec.unmap(m.getHalo.zoom) + (step / 64);
			m.getHalo.zoom = spec.map(uniNewVal);
			"%.zoom: %\n".postf(m.name, m.getHalo.zoom);
		} { sl.indexInGroup < 4 } {
			var ndef = NTMI.ndefs[sl.indexInGroup];

			// "slot mode:".postln;
			case { m.getHalo.butDown.includes(0) } {
				MFdef(\ndefVolStep).(ndef, step)

			} { m.getHalo.butDown.includes(1) } {
				NTMI.pre.stepNdefInf(ndef, step)

			} { m.getHalo.butDown.includes(2) } {
				NTMI.slots.stepNext(sl.indexInGroup, step)

			};
		}
	};
};
MKtl('mu8');
);
