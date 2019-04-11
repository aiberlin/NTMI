/**** New mainstage window: *****


// test gui update
MFdef('guiSlots').value;

q.slots.chooseNext(0); MFdef('guiSlots').value;
q.slots.chooseNext(1); MFdef('guiSlots').value;
q.slots.chooseNext(2); MFdef('guiSlots').value;
q.slots.chooseNext(3); MFdef('guiSlots').value;

q.slots.addActive(0, Ndef(\kiteHi));
q.slots.actives[0].vol;

g.main.ndefMViews[0].label_(\test).refresh;
g.main.ndefMViews[0].label;
*/

g.main = g.main ? ();
g.main.sliderCols = [ Color.green(1.0, 0.75), Color.grey(1.0, 0.75) ];


MFdef('guiSlots').add(\set, {
	// "MFdef('guiSlots') runs".postln;

	q.slots.actives.do { |ndef, i|
		var pop = g.main.popups[i];
		var mview = g.main.ndefMViews[i];
		var vol = ndef.vol;
		var playCol = if (ndef.monitor.isPlaying, g.main.sliderCols[0], g.main.sliderCols[1]);

		var presetName = NdefPreset(ndef).currSet.key;
		var newLabel;
		if (presetName == \curr) {
			newLabel = ndef.key
		} {
			newLabel = ndef.key.asString + presetName
		};

		if (ndef.key != pop.item or: { newLabel != mview.label }) {
			pop.items = q.slots.choices[i];
			pop.value = pop.items.indexOf(ndef.key);

			mview.label_( newLabel.postcs );
		};
		if (mview.value != vol) { mview.value = vol };
		if (mview.uv.background != playCol) { mview.uv.background_(playCol) };
	};
	// "MFdef('guiSlots') done.".postln;
});

g.makeGui['NTMI_Main'] = { |dict, name = 'ntmi_MainStage'|

	var butRed = Color.red(1, 0.7), butGreen = Color.green(1, 0.7);
	var bounds = Window.availableBounds;
	var wheight = bounds.height, wwidth = bounds.width;
	var scrscale = min(bounds.width / 1920, bounds.height / 1177);

	var font = Font("Monaco", (36 * scrscale).round);
	var fatfont = Font("Monaco", (72 * scrscale).round);
	var center, centPadsL, padsLPos, centPadsR, padsRPos;

	var rightCol = bounds.width - ( bounds.width - bounds.height / 2) + (30 * scrscale);

	var oscBut, midiBut, recBut, batView;
	var w;
	var bigUV, imuUV;
	var popMVs, ndefPops, ndefMViews, rMViews, skipper;

	try { g.main.w.close };
	w = Window(name, bounds).front;
	g.main.w = w;
	g.main.w.background_(q.inph.currPresetCol);

	bigUV = UserView(w, Rect.aboutPoint( bounds.center, wheight * 0.5, wheight * 0.5));
	bigUV.background_(Color.clear);
	g.main.bigUV = u;

	imuUV = v = UserView(w, Rect.aboutPoint( w.bounds.center, 240 * scrscale, 300 * scrscale));
	imuUV.background_(Color.clear);
	g.main.imuUV = v;

	g.main.padCols = MKtl('xosc').elAt(\inA, (8..15)).collect(_.value);
	g.main.movevals = MKtl('xosc').elAt([0, 1, 2]).flat.collect(_.value);

	Stethoscope(s, 4, view: w.view);
	ServerMeterView(s, w, 250@0, 4, 4);

	oscBut = Button(w,
		Rect(rightCol, 20 * scrscale, 300 * scrscale, 50 * scrscale)).states_([
		["¿¿OSC??", Color.white, butRed],
		["¡OSC OK!", Color.black, butGreen]
	]).font_(font).value_(0);
	g.main.oscBut = oscBut;

	midiBut = Button(w, Rect(rightCol, 80 * scrscale, 300 * scrscale, 50 * scrscale)).states_([
		["¿¿MIDI??", Color.white, butRed],
		["MIDI OK!", Color.black, butGreen]
	]).font_(font).value_(0);

	batView = UserView(w, Rect(rightCol, 140 * scrscale, 300 * scrscale, 40 * scrscale));
	batView.background_(butRed);
	batView.drawFunc_({ |uv|
		var bounds = uv.bounds.extent.asRect;
		Pen.addRect(bounds).color_(Color.white).stroke;
		Pen.addRect(bounds.copy.width_(bounds.width * (q.osc.batPercent ? 0 * 0.01)));
		Pen.color_(Color.green(0.75, 0.8)).fill;
		Pen.stringCenteredIn(q.osc.batString,
			bounds,
			font.copy.size_(font.size * 0.8),
			Color.white
		);
	});
	batView.refresh;
	g.main.batView = batView;

	recBut = Button(w, Rect(rightCol, 810 * scrscale, 300 * scrscale, 120 * scrscale)).states_([
		["RECORD?", Color.white, butRed],
		["Recording!", Color.black, butGreen]
	]).font_(font)
	.action_({ |bt|
		if (bt.value > 0) {
			s.recChannels_(q.numChans ? 2);
			s.record;
		} {
			s.stopRecording;
		}
	});

	Button(w, Rect(rightCol, 950 * scrscale, 300 * scrscale, 60 * scrscale)).states_([
		["show recordings", Color.white, butRed]
	]).font_(font.copy.size_(font.size * 0.62))
	.action_({ |bt|
		Platform.recordingsDir.openOS;
	});

	Button(w, Rect(rightCol, 510 * scrscale, 300 * scrscale, 120 * scrscale)).states_([
		["SET ZERO for\ntouch + move", Color.white, butRed],
	]).font_(font)
	.action_({ MFdef('ZERO').value });

	Button(w, Rect(rightCol, 660 * scrscale, 300 * scrscale, 120 * scrscale)).states_([
		["Reset Clock", Color.white, butRed],
	]).font_(font)
	.action_({
		Tdef(\clocK).set(\runtime, 0, \isRunning, true).stop.play
	});


	// 4 popups to select sounds, 4 mviews for volume levels
	// add play buttons?
	popMVs = [ 3, 1, -1, -3].collect { |offset, i|
		var top = w.bounds.center.y + (offset + 1 * -80 * scrscale);
		var left = 200 - (offset.abs * 0) * scrscale;
		var emmy = MView(0.25, w, Rect(left, top, 500 * scrscale, 150 * scrscale));
		var pop = PopUpMenu(w, Rect(left, top, 250 * scrscale, 40 * scrscale))
		.items_(q.process.allNames)
		.value_(q.slots.actives[i].key).font_(font);

		pop.background_(Color.grey(1.0, 0.7));

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
		emmy.uv.keyDownAction = { |uv, char, mod = 0|
			"emmy keydown action - char: % mod: % \n".postf(char.cs, mod);
			switch(char,
				$ , { q.slots.playAt(i) },
				$., { q.slots.stopAt(i) }
			);
		};

		emmy.drawFunc.add(\label, {
			var labelStr = emmy.label.asString;
			var labelStrSize = labelStr.size;
			var fontSize = fatfont.size * (11 / labelStrSize.max(12));
			Pen.stringCenteredIn(
				emmy.label.asString,
				emmy.bounds.moveTo(0,0),
				fatfont.copy.size_(fontSize),
				Color.blue
			)
		});
		[pop,emmy];
	};

	g.main.popups = popMVs.flop[0];
	g.main.ndefMViews = popMVs.flop[1];

	////// the 4 mviews on the right -  remove n eventually
	rMViews = [ 3, 1, -1, -3].collect { |offset, i|
		var top = bounds.center.y + (offset + 1 * -80 * scrscale);
		var left = bounds.width * 0.64 + (offset.abs * 0 * scrscale);
		var initval = [1.0, \pre_1, '¿-?', \move][i];
		var emmy = MView(nil, w, Rect(left, top, 320 * scrscale, 150 * scrscale));
		emmy.dict[\knobCol] = Color.grey(0, 0.6);
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
	g.main.rMViews = rMViews;

	///// unify all mview behaviours :

	[g.main.ndefMViews, rMViews].flat.do { |mv|

		mv.dict.font.size = 48 * scrscale;

		mv.uv.drawFunc.add(\prep, { |uv|
			var dict = mv.dict;
			dict[\bounds] = uv.bounds;
			dict[\height] = dict[\bounds].height;
			dict[\width] = dict[\bounds].width;
			dict[\focusCol] = Color.grey(1.0, 0.8);
			dict[\backCol] = Color.grey(1.0, 0.6);

			dict[\bounds00] = dict[\bounds].moveTo(0,0);
			dict[\boundsLabel] = dict[\bounds00].copy.height_(24);
			dict[\boundsValues] = dict[\bounds00].copy.top_(dict[\height] * 0.62)
			.height_(dict[\height] * 0.38);
			dict[\hiRect] = dict[\bounds00].copy
			.width_(dict[\width] * 0.5);
		});
		// force right side mviews to use lightly transparent colors
		mv.uv.focus(true).refresh;
		mv.uv.focus(false).refresh;
	};

	MFdef('stepInphWPre').add(\updateMain, {
		defer { protect {
			rMViews[1].value_(q.inph.presIndex);
			rMViews[2].value_("seed" + q.inph.randSeeds[q.inph.presIndex]);
		} }
	});

	rMViews[0].action.add(\setzoom, { |mv| q.setZoom(mv.value) });
	rMViews[0].label_(\zoom).value_(q.zoom).putDict(\myspec, \unipolar);

	rMViews[1].label_(\preUp).putDict(\myspec, [0, 7, \lin, 1]).value_(q.inph.presIndex);
	rMViews[1].uv.mouseDownAction = { MFdef('stepInphWPre').value(1) };

	rMViews[2].label_(\preDown).mode_(\code).value_(q.inph.randSeeds[q.inph.presIndex]);
	rMViews[2].uv.mouseDownAction = { MFdef('stepInphWPre').value(-1) };

	rMViews[3].label_(q.inph.mode).mode_(\code);
	rMViews[3].uv.mouseDownAction.add(\toggle, { |x|
		MFdef(\imuMode).value;
		rMViews[3].label_(q.inph.mode).valueAction_(q.inph.mode);
	});


	// circle shape in the background
	(
		bigUV.drawFunc = { |uv|
			var center = uv.bounds.extent * 0.5;

			"bigUV should only refresh when making NTMI_Main window.".postln;

			Pen.addArc(center, center.y * 0.9, 0, 2pi);
			// shape:
			Pen.color_(Color.white);
			Pen.width = 3;
			Pen.stroke;
		};
		bigUV.refresh;
	);

	// small UV in the middle for cheaper pads/axes drawing
	(
		imuUV.drawFunc = { |uv|
			var bounds = uv.bounds.moveTo(0,0);
			var center = bounds.center;
			var centPadsL, padsLPos, centPadsR, padsRPos;
			var star;

			if (q.inph.mode == \touch) {
				centPadsL = center.copy.x_(center.x - (center.y * 1.8));
				centPadsR = center.copy.x_(center.x + (center.y * 1.8));
				padsLPos = [ -0.6, -0.2, 0.2, 0.6].collect { |angle|
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
		imuUV.refresh;

		skipper.stop;
		skipper = SkipJack({

			if (g.main.backCol != q.inph.currPresetCol) {
				// "refresh win color.".postln;
				g.main.backCol = q.inph.currPresetCol;
				g.main.w.background_(q.inph.currPresetCol);
			};

			g.main.movevals = MKtl('xosc').elAt(\imu9).value;
			g.main.padCols = MKtl('xosc').elAt('pads8').value.collect { |val|
				Color.yellow(val.linlin(0, 1, 0.25, 1)).red_(1);
			};

			// only of values changed? hmmm.
			imuUV.refresh;

			// zoom
			if (q.zoom != rMViews[0].value) { rMViews[0].value = q.zoom };
			if (q.inph.mode != rMViews[3].label) { rMViews[3].label_(q.inph.mode) };

			// OSC status
			if (oscBut.value != (q.osc.timeSinceLast < 1)) {
				oscBut.value = q.osc.timeSinceLast < 1;
				if (q.osc.timeSinceLast >= 1) {
					q.osc.batval = 0;
					q.osc.batPercent = 0;
					q.osc.batString = "battery ?";
				};
			};

			if (q.osc.batval != q.osc.oldbatval) {
				batView.refresh;
			};

			MFdef('guiSlots').value;

			// "mainUV skip runs".postln;
		}, 0.2, { w.isClosed }, name: \mainUV);
		g.main.skipper = skipper;

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
		Rect(rightCol, 160 * scrscale, 300 * scrscale, 200 * scrscale)
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
