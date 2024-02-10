/******* make a control interface for the NTMI app for the behringer xtouch

MKtl.all[\xtm].free;
MKtl(\xtm, "*x-touch-mini*");
MKtl(\xtm).gui.showLabels;

-------- THE LAYOUT: ----------

main volume : big slider
play/stop slot: buttons A 1-4

set relative influx: 8 knobs

set volume per slot: encoder 1-4, press  down and turn
set preset per slot: encoder 5-8, press  down and turn
set sound per slot : hold MC + press hat knob  1-4

record button -> snapshot

hold MC button and turn
- left knobs 1-4  		change slots volume (with softVol takeover)
- bottom buttons 1-4 	toggle sound slots on/off

- knobs 5-8 		select presets or sounds
-- button 5-8 up	scroll thru presets
-- button 5-8 down	scroll thru sounds

MKtl('xtm').gui.showLabels;

***********/

// if (MKtlLookup.findByIDInfo("X-TOUCH MINI").size > 0) { };

MKtl.all.xtm.free;
MKtl('xtm', "*x-touch-mini*");

// main volume
MKtl('xtm').addNamed(\main, MKtl('xtm').elAt(\A, \sl));
MKtl('xtm').elAt(\main).elemDesc.label = "Main Vol";
MKtl('xtm').elAt(\main).action = { |sl| MFdef(\mainVol).value((sl.value * 2).squared) };

// play buttons for the four slots
MKtl('xtm').addNamed(\playBts, MKtl('xtm').elAt(\A, \chan, (0..3), \bt, \A, 0));
MKtl('xtm').elAt(\playBts).do { |el, i| el.elemDesc.label = "play" + (i + 1) };
MKtl('xtm').elAt(\playBts).do { |el, i|
	el.action = { |bt| if (bt.isOn) { NTMI.slots.toggleAt(i) } };
};

// we want to use the encoders for several things:
// setting volume per slot, and playing influx inputs.
// so, we need ways to switch modes...

// first, we make the named elements - encoders, hats, MC button
MKtl('xtm').addNamed(\enc, MKtl('xtm').elAt(\A, \chan, nil, \enc, 0));
MKtl('xtm').addNamed(\enchat, MKtl('xtm').elAt(\A, \chan, nil, \enc, 1));
// define MC button to use for mode switching
MKtl('xtm').addNamed(\MC, MKtl('xtm').elAt(\A, \chan, 0, \bt, \B, 0));


MKtl('xtm').elAt(\enc).value = 0.5;

/*
// first pass: use encoders to do absolute influx setting
MKtl('xtm').elAt(\enc).do { |enc, i|
enc.action = { |enc|
var name = NTMI.inphlux.inNames[i + NTMI.inph.sliderOffset ? 1];
NTMI.inphlux.set(name, enc.value.unibi);
};
};

// new relative set for all 8 envoders
MKtl('xtm').elAt(\enc).do { |enc, i|
enc.action = { |enc|
MFdef(\setRelInf).(
// add sliderOffset + 1, so we get to channel 8 for amp tweak
i + NTMI.inph.sliderOffset ? 1 + 1,
(enc.prevValue - enc.value),
NTMI.zoom * (NTMI.xtm.zoom ? 1)
);
}
};

// try volume per slot on first 4, preset select on second 4:
MKtl('xtm').elAt(\enc).do { |el, i|
// first 4 change volume
if (i < 4) {
el.action = { |enc|
NTMI.ndefs[i].softVol_(el.value, lastVal: el.prevValue);
};
} {
// second 4 should step thru NdefPreset setting
el.action = { |enc|
var step = enc.deviceValue - enc.prevDeviceValue;
var ndef = NTMI.ndefs[i-4];
NTMI.pre.stepNdefInf( ndef, step );
};
};
};
*/

MKtl('xtm').elAt(\enc).do { |enc, i|
	enc.elemDesc.label = if (i < 4, "infvol", "infsel")
};

MKtl('xtm').elAt(\enchat).do { |hat, i|
	hat.elAt(0).elemDesc.label = "enc" ++ i ++ "mode";
};

// now merge the two - when enchat is down, new mode:
// first 4 do volume per slot, second 4 do select
MKtl('xtm').elAt(\enc).do { |enc, i|
	enc.action = {
		var enchat = MKtl('xtm').elAt(\enchat, i, 0);
		if (enchat.isOn.not) {
			"// normal mode is influx ...".postln;
			MFdef(\setRelInf).(
				// add sliderOffset + 1, so we get to channel 8 for amp tweak
				i + (NTMI.inph.sliderOffset ? 1),
				(enc.prevValue - enc.value),
				NTMI.zoom * (NTMI.xtm.zoom ? 1)
			)
		} { // if enchat is down,
			// first 4 change volume ...
			if (i < 4) {
				NTMI.ndefs[i].softVol_(enc.value.squared, lastVal: enc.prevValue.squared);
			} {
				// second 4 step thru NdefPreset setting
				var step = enc.deviceValue - enc.prevDeviceValue;
				var slotIndex = i-4;
				var ndef = NTMI.ndefs[slotIndex];

				if (MKtl('xtm').elAt(\shift).isOn) {
					"// if shift key, step sound!".postln;
					NTMI.slots.stepNext(slotIndex, step);
					// NTMI.slots.playAt(slotIndex);
				} {
					"// no shift, switch preset".postln;
					NTMI.pre.stepNdefInf( ndef, step );
				}
			}
		}
	}
};

MKtl('xtm').addNamed(\rec, MKtl('xtm').elAt(\A, \chan, 7, \bt, \B, \on));
MKtl('xtm').elAt(\rec).action = { |bt| if (bt.isOn) { MFdef(\snapshot).value } };
MKtl('xtm').elAt(\rec).elemDesc.label = "SNAP";

MKtl('xtm').addNamed(\shift, MKtl('xtm').elAt(\A, \chan, 0, \bt, \B, \on));
MKtl('xtm').elAt(\shift).elemDesc.label = "SHIFT";

MKtl('xtm').addNamed(\fx, MKtl('xtm').elAt(\A, \chan, [4,5,6], \bt, \B, \on));
MKtl('xtm').elAt(\fx).at(0).elemDesc.label = "prev MFX";
MKtl('xtm').elAt(\fx).at(0).action = { |b| if (b.isOn) { MFdef(\mainPreStep).(-1) } };
MKtl('xtm').elAt(\fx).at(1).elemDesc.label = "rand MFX";
MKtl('xtm').elAt(\fx).at(1).action = { |b| if (b.isOn) { MFdef(\mainPreStep).() } };
MKtl('xtm').elAt(\fx).at(2).elemDesc.label = "next MFX";
MKtl('xtm').elAt(\fx).at(2).action = { |b| if (b.isOn) { MFdef(\mainPreStep).(1) } };


MKtl('xtm').addNamed(\inph, MKtl('xtm').elAt(\A, \chan, [1, 2, 3], \bt, \B, \on));
MKtl('xtm').elAt(\inph).at(0).elemDesc.label = "prev inph";
MKtl('xtm').elAt(\inph).at(0).action = { |b| if (b.isOn) { NTMI.inph.stepWPre(-1) } };
MKtl('xtm').elAt(\inph).at(1).elemDesc.label = "rand inph";
MKtl('xtm').elAt(\inph).at(1).action = { |b| if (b.isOn) { NTMI.inph.stepWPre(nil) } };
MKtl('xtm').elAt(\inph).at(2).elemDesc.label = "next inph";
MKtl('xtm').elAt(\inph).at(2).action = { |b| if (b.isOn) { NTMI.inph.stepWPre(1) } };


MKtl('xtm');
