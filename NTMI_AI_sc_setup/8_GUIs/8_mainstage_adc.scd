/**** Experiments for new maistage window: *****

- add ProxyMeter on top of MView?

/// move mode, touch pads off:
g.main.padCols = Color.grey(0.5, 0.25) ! 8; u.refresh;
q.inph.mode = \touch; g.main.movevals = { 1.0.rand }!9;
u.refresh;

g.makeGui.main_adc

// touch mode
g.main.padCols = { Color.yellow(rrand(0.2, 1.0)).red_(1) } ! 8; u.refresh;
q.inph.mode = \move; g.main.movevals = { 0 }!9; u.refresh;

// all Ndefs off
m.do (_.putDict(\backCol, Color.grey)); m.do(_.refresh);
// all on
m.do (_.putDict(\backCol, Color.green(1.0))); m.do(_.refresh);

// move mode

q.inph.mode = \move;

n[3].label_('touch').value_('touch');
n[3].label_('move').value_('move');

g.main.movevals = { 1.0.rand2 }!9;
g.main.movevals = { 1.0 }!9; u.refresh;

NdefMixer(s)

// test gui update
MFdef('guiSlots').value;

q.slots.chooseNext(0); MFdef('guiSlots').value;
q.slots.chooseNext(1); MFdef('guiSlots').value;
q.slots.chooseNext(2); MFdef('guiSlots').value;
q.slots.chooseNext(3); MFdef('guiSlots').value;

q.slots.addActive(0, Ndef(\kiteHi));
q.slots.actives[0].vol;

*/

MFdef('guiSlots').add(\set, {
	"MFdef('guiSlots') runs".postln;
	q.slots.actives.do { |ndef, i|
		var pair = q.slots.pops[i];
		var pop = pair[0], mview = pair[1];
		pop.items = q.slots.choices[i];
		pop.value = q.slots.choices[i].indexOf(ndef.key);
		mview.label = ndef.key;
		mview.value = ndef.vol;
	};
	"MFdef('guiSlots') done.".postln;
});

g.main = g.main ? ();

g.makeGui.main_adc = {
	var bounds = Window.availableBounds;
	var scrscale = min(bounds.width / 1920, bounds.height / 1200);
	var font = Font("Monaco", (36 * scrscale).round);
	var fatfont = Font("Monaco", (72 * scrscale).round);
	var center, centPadsL, padsLPos, centPadsR, padsRPos;

	var rightCol = bounds.width - ( bounds.width - bounds.height / 2) + (30 * scrscale);

	var oscBut, midiBut, movevals;
	var w, u, v, z, m, n;

	[scrscale].postln;
	try { g.main.w.close };
	w = Window("N T M I MainStage", bounds).front;
	w.background_(Color.black);
	g.main.w = w;

	u = UserView(w, bounds.moveTo(0,0));
	v = UserView(w, Rect.aboutPoint( w.bounds.center, 240 * scrscale, 300 * scrscale));
	v.background_(Color.red);
	u.background_(Color.red);

	g.main.bigUV = u;
	g.main.imuUV = v;

	g.main.padCols = Color.grey(0.5) ! 8;

	g.main.movevals = MKtl('xosc').elAt([0, 1, 2]).flat.collect(_.value);

	Stethoscope(s, 4, view: w.view);
	ServerMeterView(s, w, 250@0, 4, 4);

	oscBut = Button(w,
		Rect(rightCol, 10 * scrscale, 300 * scrscale, 50 * scrscale)).states_([
		["¿¿OSC??", Color.white, Color.red],
		["¡OSC OK!", Color.black, Color.green]
	]).font_(font).value_(0);

	midiBut = Button(w, Rect(rightCol, 80 * scrscale, 300 * scrscale, 50 * scrscale)).states_([
		["¿¿MIDI??", Color.white, Color.red],
		["MIDI OK!", Color.black, Color.green]
	]).font_(font).value_(0);

	Button(w, Rect(rightCol, 810 * scrscale, 300 * scrscale, 150 * scrscale)).states_([
		["RECORD?", Color.white, Color.red],
		["Recording!", Color.black, Color.green]
	]).font_(font)
	.action_({ |bt|
		if (bt.value > 0) {
			s.recChannels_(q.numChans ? 2);
			s.record;
		} {
			s.stopRecording;
		}
	});

	Button(w, Rect(rightCol, 610 * scrscale, 300 * scrscale, 150 * scrscale)).states_([
		["Reset Clock", Color.white, Color.red],
	]).font_(font)
	.action_({
		Tdef(\clocK).set(\runtime, 0, \isRunning, true).stop.play
	});

	// 4 popups to select sounds, 4 mviews for volume levels
	// add play buttons?
	m = [ 3, 1, -1, -3].collect { |offset, i|
		var top = w.bounds.center.y + (offset + 1 * -80 * scrscale);
		var left = 200 - (offset.abs * 0) * scrscale;
		var emmy = MView(0.25, w, Rect(left, top, 500 * scrscale, 150));
		var pop = PopUpMenu(w, Rect(left, top, 250 * scrscale, 40 * scrscale))
		.items_(q.process.allNames)
		.value_(q.slots.actives[i].key).font_(font);
		pop.alpha_(0.8);
		pop.action = { |pop|
			q.slots.addActive(i, Ndef(pop.item));
			MFdef('guiSlots').value;
			emmy.refresh;
		};
		emmy.uv.resize_(1);
		emmy.uv.alpha = 0.8;
		emmy.dict[\knobCol] = Color.grey(0, 0.7);
		emmy.putDict(\myspec, \amp);
		emmy.action.add(\setVol,  { |em|
			q.slots.actives[i].vol_(em.value)
		});
		emmy.drawFunc.add(\label, {
			Pen.stringCenteredIn(
				q.ndefs[i].key.asString,
				emmy.bounds.moveTo(0,0),
				fatfont,
				Color.blue
			)
		});
		[pop,emmy];
	};

	q.slots.pops = m;

	////// the 4 mviews on the right
	n = [ 3, 1, -1, -3].collect { |offset, i|
		var top = bounds.center.y + (offset + 1 * -80 * scrscale);
		var left = bounds.width * 0.64 + (offset.abs * 0 * scrscale);
		var initval = [1.0, \pre_1, '¿-?', \move][i];
		var emmy = MView(nil, w, Rect(left, top, 320 * scrscale, 150));
		emmy.dict[\knobCol] = Color.grey(0, 0.7);
		emmy.uv.alpha = 0.8;
		emmy.uv.resize_(1);
		emmy.drawFunc.add(\label, {
			Pen.stringCenteredIn(
				emmy.label ? emmy.value,
				emmy.bounds.moveTo(0,0),
				fatfont,
				Color.blue
			)
		});
		emmy;
	};

	MFdef('stepInphWPre').add(\updateMain, {
		defer { protect {
			n[1].value_(q.inph.presIndex);
			n[2].value_("seed" + q.inph.randSeeds[q.inph.presIndex]);
		} }
	});

	n[0].action.add(\setzoom, { |mv| q.setZoom(mv.value) });
	n[0].label_(\zoom).value_(q.zoom).putDict(\myspec, \unipolar);

	n[1].label_(\preDown).putDict(\myspec, [0, 7, \lin, 1]).value_(q.inph.presIndex);
	n[1].uv.mouseDownAction = { MFdef('stepInphWPre').value(-1) };

	n[2].label_(\preUp).mode_(\code).value_(q.inph.randSeeds[q.inph.presIndex]);
	n[2].uv.mouseDownAction = { MFdef('stepInphWPre').value(1) };

	n[3].label_(q.inph.mode).mode_(\code);
	n[3].uv.mouseDownAction.add(\toggle, { |x|
		MFdef(\imuMode).value;
		n[3].label_(q.inph.mode).valueAction_(q.inph.mode);
	});

	[m.collect(_[1]), n].flat.do { |mv|

		mv.dict.font.size = 48 * scrscale;

		mv.uv.drawFunc.add(\prep, { |uv|
			var dict = mv.dict;
			dict[\bounds] = uv.bounds;
			dict[\height] = dict[\bounds].height;
			dict[\width] = dict[\bounds].width;

			dict[\bounds00] = dict[\bounds].moveTo(0,0);
			dict[\boundsLabel] = dict[\bounds00].copy.height_(24);
			dict[\boundsValues] = dict[\bounds00].copy.top_(dict[\height] * 0.62).height_(dict[\height] * 0.38);
			dict[\hiRect] = dict[\bounds00].copy
			.width_(dict[\width] * 0.5);
		});
	};

	// circle shape in the background
	(
		u.drawFunc = { |uv|
			var center = uv.bounds.center;

			Pen.addArc(center, center.y * 0.9, 0, 2pi);
			// shape:
			Pen.color_(Color.white);
			Pen.width = 3;
			Pen.stroke;
		};
		u.refresh;
	);

	// small UV in the middle for cheaper pads/axes drawing
	(
		v.drawFunc = { |uv|
			var bounds = uv.bounds.moveTo(0,0);
			var center = bounds.center;
			var centPadsL, padsLPos, centPadsR, padsRPos;
			var star;

			// q.inph.currPresetCol = q.inph.presetCols @@ q.inph.at(\presIndex);
			// uv.background_(q.inph.currPresetCol);

			if (q.inph.mode == \touch) {
				centPadsL = center.copy.x_(center.x - (center.y * 1.8));
				centPadsR = center.copy.x_(center.x + (center.y * 1.8));
				padsLPos = [ 0.6, 0.2, -0.2, -0.6].collect { |angle|
					Polar(center.y * 1.5, angle * 0.8).asPoint + centPadsL;
				};

				padsRPos = [ 0.6, 0.2, -0.2, -0.6].collect { |angle|
					Polar(center.y * -1.5 + pi, angle * 0.8).asPoint + centPadsR;
				};

				// 4 left, 4 right touchpads
				(padsLPos ++ padsRPos).collect { |pt, i|
					Pen.addArc(pt, 60, 0, 2pi);
					Pen.color_(g.main.padCols[i]);
					Pen.fill;
					// Pen.stringCenteredIn(i.asString, Rect.aboutPoint(pt, 60, 60),
					// 	font: Font("Monaco", 96),
					// color: Color.black);
				};
			};

			// visualize move mode as star of 9;
			if (q.inph.mode == \move) {
				// "move mode vis".postln;
				star = g.main.movevals.collect { |val, i|
					Polar(val.linlin( 0, 1, 40, 240), i / 9 * 2pi).asPoint + center;
				};
				// star.postln;
				Pen.color = Color.yellow; Pen.width = 3;
				star.wrapExtend(10).doAdjacentPairs { |p1, p2| Pen.line(p1, p2); };
				Pen.stroke;
				star.do { |p1| Pen.line(p1, center); };
				Pen.color = Color.white; Pen.width = 1.5;
				Pen.stroke;
			};

		};
		v.refresh;

		z.stop;
		z = SkipJack({

			if (g.main.backCol != q.inph.currPresetCol) {
				u.background_(q.inph.currPresetCol);
				v.background_(q.inph.currPresetCol);
			};

			// q.inph.currPresetCol = q.inph.presetCols @@ q.inph.at(\presIndex);
			// uv.background_(q.inph.currPresetCol);

			// g.main.padCols = { Color.yellow(rrand(0.2, 1.0)).red_(1) } ! 8;
			// g.main.movevals = { 1.0.rand }!9;
			g.main.movevals = x.elAt(['accel', 'gyro', 'magnet']).flat.collect(_.value);
			g.main.padCols = x.elAt('inA').value.drop(8).collect { |val|
				Color.yellow(val.linlin(0, 1, 0.25, 1)).red_(1);
			};
			v.refresh;
			// zoom
			n[0].value = q.zoom;
			n[3].label_(q.inph.mode);
			// OSC status
			oscBut.value = q.osc.timeSinceLast < 1;

			// check if new ndefs, and update if needed
			if (
				(q.slots.actives.collect(_.key) ==
					q.slots.pops.collect { |pair| pair[0].item }).not
			) { MFdef('guiSlots').value };

			// always check volumes?
			q.slots.actives.do { |ndef, i|
				var vol = ndef.vol;
				var mview = q.slots.pops[i][1];
				if (mview.value != vol) { mview.value = vol };
			};
			// "mainUV skip runs".postln;
		}, 0.2, { w.isClosed }, name: \mainUV);

	);

	/////// Clock display shows how long something has been running
	/*
	Tdef(\clocK).set(\isRunning, true);
	// jumps back to zero when stopped
	Tdef(\clocK).set(\isRunning, false);

	// watch some Tdef to see how long a piece has been running
	Tdef(\clocK).set(\isRunning, { Tdef(\watchMe).isPlaying });

	Tdef(\watchMe).play;
	Tdef(\watchMe).stop;
	*/


	Tdef(\clocK).addSpec(\runtime, [0, 10000, \lin, 0.1]);
	Tdef(\clocK).set(\runtime, 0, \isRunning, true);

	//	Tdef(\clocK).gui;

	/// add gui parent here:
	Tdef(\clocK).set(\timeUV, UserView(w,
		Rect(rightCol, 110 * scrscale, 300 * scrscale, 200 * scrscale)
	).front);
	Tdef(\clocK).set(\font, fatfont.copy.size_(60 * scrscale));
	Tdef(\clocK).set(\color, Color.white);

	Tdef(\clocK).get(\timeUV).drawFunc = { |uv|
		var font = fatfont.copy.size_(60 * scrscale);
		var timeStr = Tdef(\clocK).get(\timeStr);
		Pen.stringCenteredIn(timeStr,
			Rect(0,0, uv.bounds.width, uv.bounds.height),
			Tdef(\clocK).get(\font),
			Tdef(\clocK).get(\color)
		)
	};

	Tdef(\clocK).get(\timeUV).refresh;

	Tdef(\clocK, { |envir|
		var dt = 1;
		inf.do { |i|
			envir.timeStr =
			// "Runtime :\n" +
			envir.runtime.asTimeString.drop(-4);
			defer { envir.timeUV.refresh };
			if (envir.isRunning == true) {
				envir.runtime = envir.runtime ? 0 + dt;
			} {
				envir.runtime = 0;
			};
			dt.wait;
		}
	}).play;
};