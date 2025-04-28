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

m.gui.showLabels;
MKtl(\xtm).free;
***********/


// Use makeMKtl and NTMI.currInfo to support multiple hardware MKtls:
// arguments:MKtl name, desc filename, info reg. multiple hardware

var m;

m = NTMI.makeMKtl(\xtm, "*x-touch-mini*", NTMI.currInfo);


// main volume
m.addNamed(\main, m.elAt(\A, \sl));
m.elAt(\main).elemDesc.label = "Main Vol";
m.elAt(\main).action = { |sl| MFdef(\mainVol).value((sl.value * 2).squared) };

// play buttons for the four slots
m.addNamed(\playBts, m.elAt(\A, \chan, (0..3), \bt, \A, 0));
m.elAt(\playBts).do { |el, i| el.elemDesc.label = "play" + (i + 1) };
m.elAt(\playBts).do { |el, i|
	el.action = { |bt| if (bt.isOn) { NTMI.slots.toggleAt(i) } };
};

// we want to use the encoders for several things:
// setting volume per slot, and playing influx inputs.
// so, we need ways to switch modes...

// first, we make the named elements - encoders, hats, MC button
m.addNamed(\enc, m.elAt(\A, \chan, nil, \enc, 0));
m.addNamed(\enchat, m.elAt(\A, \chan, nil, \enc, 1));
// define MC button to use for mode switching
m.addNamed(\MC, m.elAt(\A, \chan, 0, \bt, \B, 0));


m.elAt(\enc).value = 0.5;


m.elAt(\enc).do { |enc, i|
	enc.elemDesc.label = if (i < 4, "infvol", "infsel")
};

m.elAt(\enchat).do { |hat, i|
	hat.elAt(0).elemDesc.label = "enc" ++ i ++ "mode";
};

// now merge the two - when enchat is down, new mode:
// first 4 do volume per slot, second 4 do select
m.elAt(\enc).do { |enc, i|
	enc.action = {
		// make encoder rotation endless
		var step = enc.deviceValue - enc.prevDeviceValue.clip(1, 126);
		// prepare for mode
		var enchat = m.elAt(\enchat, i);
		var enchatIsUp = enchat.isOn.not;

		if (enchatIsUp) {
			// "// normal mode is influx ...".postln;
			MFdef(\setRelInf).(
				// add sliderOffset + 1, so we get to channel 8 for amp tweak
				i + (NTMI.inph.sliderOffset ? 1),
				step * 0.01,
				NTMI.zoom * (m.getHalo.zoom ? 1)
			)
		} { // if enchat is down,

			if (i < 4) {
				// "// first 4 change volume ...".postln;
				NTMI.ndefs[i].softVol_(enc.value.squared, lastVal: enc.prevValue.squared);
			} {
				var slotIndex = i-4;
				var ndef = NTMI.ndefs[slotIndex];
				// "// second 4 step thru NdefPreset setting".postln;

				if (m.elAt(\shift).parent.isOn) {
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

m.addNamed(\rec, m.elAt(\A, \chan, 7, \bt, \B, \on));
m.elAt(\rec).action = { |bt| if (bt.isOn) { MFdef(\snapshot).value } };
m.elAt(\rec).elemDesc.label = "SNAP";

m.addNamed(\shift, m.elAt(\A, \chan, 0, \bt, \B, \on));
m.elAt(\shift).elemDesc.label = "SHIFT";
m.elAt(\shift).action = { |bt| "shift...".postln };
m.elAt(\A, \chan, 0, \bt, \B, \off).action = { |bt| "...unshift".postln };

m.addNamed(\fx, m.elAt(\A, \chan, [4,5,6], \bt, \B, \on));
m.elAt(\fx).at(0).elemDesc.label = "prev MFX";
m.elAt(\fx).at(0).action = { |b| if (b.isOn) { MFdef(\mainPreStep).(-1) } };
m.elAt(\fx).at(1).elemDesc.label = "rand MFX";
m.elAt(\fx).at(1).action = { |b| if (b.isOn) { MFdef(\mainPreStep).() } };
m.elAt(\fx).at(2).elemDesc.label = "next MFX";
m.elAt(\fx).at(2).action = { |b| if (b.isOn) { MFdef(\mainPreStep).(1) } };


m.addNamed(\inph, m.elAt(\A, \chan, [1, 2, 3], \bt, \B, \on));
m.elAt(\inph).at(0).elemDesc.label = "prev inph";
m.elAt(\inph).at(0).action = { |b| if (b.isOn) { NTMI.inph.stepWPre(-1) } };
m.elAt(\inph).at(1).elemDesc.label = "rand inph";
m.elAt(\inph).at(1).action = { |b| if (b.isOn) { NTMI.inph.stepWPre(nil) } };
m.elAt(\inph).at(2).elemDesc.label = "next inph";
m.elAt(\inph).at(2).action = { |b| if (b.isOn) { NTMI.inph.stepWPre(1) } };


m;
