/******* this setup is for the nanoKontrol 2 only;
nanoKontrol1 is moved to its own separate file.

-------- THE LAYOUT: ----------
- left knobs 1-4  		change slots volume (with softVol takeover)

- S buttons 1-4 (top)     solo: play all held btn slots, end all others.
- M buttons could be couple/decouple?
- R buttons 1-4 (bottom)  toggle sound slots on/off

- knobs 5-8 		select presets or sounds
-- button 5-8 up	scroll thru presets
-- button 5-8 down	scroll thru sounds

- sliders 1-7: 	influx!

- last slider 8:	mainVol via mainVol func

transport buttons:
nk2: cycle, rew, fwd 	rand, prev, next influx preset

nk1: loop, stop, rec:  rand, prev, next MainFX preset
nk2: stop, play, rec:  rand, prev, next MainFX preset

- top row(s) of buttons still unused.

MKtl(~nanoKtl).elAt(\bt)
***********/

var m;

// support multiple identical interfaces:
if (NTMI.currInfo.notNil) {
	~nanoKtl = NTMI.currInfo.mktlName;
	MKtl.all[~nanoKtl].free;
	MKtl(~nanoKtl, "korg-nanokontrol2", false, multiIndex: NTMI.currInfo.multiIndex);
} {
	// just one single interface:
	// no need for NTMI.currInfo,
	// just go by name given earlier or default
	~nanoKtl = ~nanoKtl ? \nanoKtl;
	MKtl(~nanoKtl, "korg-nanokontrol2");
};

m = MKtl(~nanoKtl);

// make all named elements first
m.addNamed(\main, m.elAt(\sl, 7));
m.addNamed(\inflSet, m.elAt(\sl, (0..6)));

m.addNamed(\vols, m.elAt(\kn, (0..3)));
m.addNamed(\playBts, m.elAt(\bt, 2, (0..3)));

// select preset or sounds
m.addNamed(\select, m.elAt(\kn, (4..7)));
// if but up, select preset, if down, sound
m.addNamed(\selMode, m.elAt(\bt, 2, (4..7)));

m.addNamed(\rand_inph, m.elAt(\tr, \cycle));
m.addNamed(\prev_inph, m.elAt(\tr, \rew));
m.addNamed(\next_inph, m.elAt(\tr, \fwd));

m.addNamed(\prev_pre, m.elAt(\tr, \stop));
m.addNamed(\rand_pre, m.elAt(\tr, \play));
m.addNamed(\next_pre, m.elAt(\tr, \rec));


// *** add local settings and functions to nanoKtl Halo ***
// local zoom value:
m.addSpec(\zoom, [0, 4, \amp]);
// create Halo
m.addHalo(\zoom, 1);

// then allow direct access of halo via NTMI:
NTMI.q.put(~nanoKtl, m.getHalo);
// and access like this
m.getHalo.zoom.postln;

// flag whether to use influx in relative or absolute mode:
// (there could be more modes, e.g. softAbs ...)
m.getHalo.influxMode = \setRel;

// set functions for the two supported modes:
m.getHalo.setRel = {
	m.getHalo.influxMode = \setRel;
	"nanoKtl influxMode is now: %\n.".postf(\setRel);
};
m.getHalo.setAbs = {
	m.getHalo.influxMode = \setAbs;
	"nanoKtl influxMode is now: %\n.".postf(\setAbs);
};
// read and set:
m.getHalo.influxMode;
m.getHalo.setRel;

/* SOLO BUTTONS:
make the first 4 S buttons solo:
- solo all slots where S button is held,
mute all others
- release: stop released one
- last release / all stopped
*/

m.addNamed(\solo, m.elAt(\bt, \S, (0..3)));

m.elAt(\solo).do { |bt, i|
	bt.elemDesc.label = "So%".format(i+1);
};

m.elAt(\solo).action = {
	var nowPlaying = NTMI.slots.nowPlaying;
	"*** solo: ".post;
	m.elAt(\solo).value.postln.do { |val, i|
		defer {
			if (val > 0) {
				if (nowPlaying.includes(NTMI.slots.actives[i]).not) {
					NTMI.slots.playAt(i)
				};
			} {
				if (nowPlaying.includes(NTMI.slots.actives[i])) {
					NTMI.slots.stopAt(i)
				};
			}
		}
	}
};

m.elAt(\inflSet).do(_.value = 0.5);


m.elAt(\main).elemDesc.label = "Main Vol";

m.elAt(\rand_inph).elemDesc.label = "rand inph";
m.elAt(\prev_inph).elemDesc.label = "prev inph";
m.elAt(\next_inph).elemDesc.label = "next inph";

m.elAt(\rand_pre).elemDesc.label = "rand MFX";
m.elAt(\prev_pre).elemDesc.label = "prev MFX";
m.elAt(\next_pre).elemDesc.label = "next MFX";

// modify labels:
m.elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
m.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

m.elAt(\selMode).do { |el, i| el.elemDesc.label = "mod sl%".format(i+1) };
m.elAt(\select).do { |el, i| el.elemDesc.label = "slc % snd".format(i+1) };

m.elAt(\inflSet).do { |sl, i| sl.elemDesc.label = "inf" + NTMI.inphlux.inNames[i].cs };


/// left top 4 knobs change slots volume
m.elAt(\vols).do { |el, i|
	el.action = { |el|
		NTMI.ndefs[i].softVol_(el.value, lastVal: el.prevValue);
	};
};

// left bottom 4 buttons toggle sound slots on/off
m.elAt(\playBts).do { |el, i|
	el.action = { |el|
		if (el.isOn) { NTMI.slots.toggleAt(i) }
	};
};

m.elAt(\inflSet).do { |sl, i|
	sl.action = { |sl|
		// add sliderOffset + 1, so we get to channel 8 for amp tweak
		var inphInIndex = NTMI.inph.sliderOffset + 1 + i;

		if (m.getHalo.influxMode == \setAbs) {
			var name = NTMI.inphlux.inNames[i];
			\setAbs.postln;
			NTMI.inphlux.set(name, sl.value.unibi * m.getHalo.zoom);
		} {
			// setRel, also default
			MFdef(\setRelInf).(inphInIndex,
				(sl.prevValue - sl.value).clip2(0.05),
				NTMI.zoom * m.getHalo.zoom
			)
		}
	}
};

// rightmost slider is main volume (into limiter)
m.elAt(\main).action = { |sl|
	MFdef(\mainVolSetUni).value(sl.value) };
m.elAt(\main).value = 0.5;

// normal: select next setting
// hat down: select next sound
m.elAt(\select).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		var relStep = (el.deviceValue - el.prevValue).sign;
		if (m.elAt(\selMode)[i].isOn) {
			// next sound
			NTMI.slots.stepNext(i, relStep);
		} {
			// next preset
			NTMI.pre.stepNdefInf(ndef, relStep);
		};
	};
};

m.elAt(\rand_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(nil) } };
m.elAt(\prev_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(-1 ) } };
m.elAt(\next_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre( 1 ) } };

m.elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
m.elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
m.elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };

// snapshot
m.elAt(\tr, 'mset').elemDesc.label = "snap pre!";
m.elAt(\tr, 'mset').action = { |el| if (el.isOn, MFdef(\snapshot)) };

m;