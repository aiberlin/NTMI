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
g.makeGui['NTMI_Main'].value;
*/

g.main = g.main ? ();
g.main.sliderCols = [ Color.green(1.0, 0.75), Color.grey(1.0, 0.75) ];

/////// Clock display shows how long something has been running
/*
Tdef(\clocK).gui;

Tdef(\clocK).set(\isRunning, true);
// jumps back to zero when stopped
Tdef(\clocK).set(\isRunning, false);

// watch some Tdef to see how long a piece has been running
Tdef(\clocK).set(\isRunning, { Tdef(\watchMe).isPlaying });

Tdef(\watchMe).play;
Tdef(\watchMe).stop;
*/

Tdef(\clocK).clock = SystemClock;
Tdef(\clocK).addSpec(\runtime, [0, 10000, \lin, 1]);
Tdef(\clocK).set(\runtime, 0, \isRunning, true);

Tdef(\clocK, { |envir|
	var dt = 1;
	inf.do { |i|
		envir.timeStr = envir.runtime.asTimeString.drop(-4);
		defer { try { envir.timeUV.refresh } };

		dt.wait;
		if (envir.isRunning == true) {
			envir.runtime = envir.runtime ? 0 + dt;
		} {
			envir.runtime = 0;
		};

	}
}).play;


MFdef('guiSlots').add(\set, {
	// "MFdef('guiSlots') runs".postln;

	q.slots.actives.do { |ndef, i|
		var pop = g.main.popups[i];
		var prepop = g.main.prePops[i];
		var mview = g.main.ndefMViews[i];
		var vol = ndef.vol;
		var playCol = if (ndef.monitor.isPlaying, g.main.sliderCols[0], g.main.sliderCols[1]);
		var ndefRandSeed;

		var presetName = NdefPreset(ndef).currSet.key;

		var newLabel = ndef.key.asString;

		if (presetName == \curr) {
			ndefRandSeed = ndef.getHalo(\randSeed);
			ndefRandSeed !? {
				newLabel = newLabel + "rd:" + ndefRandSeed
			};
		} {
			newLabel = newLabel + presetName
		};

		if (ndef.key != pop.item or: { newLabel != mview.label }) {
			pop.items = q.slots.choices[i];
			pop.value = pop.items.indexOf(ndef.key);

			prepop.items = NdefPreset(ndef).getSetNames;
			prepop.value = NdefPreset(ndef).currIndex;

			mview.label_( newLabel );
		};

		if (NdefPreset(ndef).currIndex != prepop.value) {
			prepop.value = NdefPreset(ndef).currIndex;
		};

		if (mview.value != vol) { mview.value = vol };
		if (mview.uv.background != playCol) { mview.uv.background_(playCol) };
	};
	// "MFdef('guiSlots') done.".postln;
});

// rescale stethoscope height
g.scaleStetho = { |g, stetho, height = 200|
	var scopeV = stetho.scopeView;
	var cycleSl = stetho.view.children[5];
	var yzoomSl = stetho.view.children[6];
	scopeV.bounds = scopeV.bounds.height_(height);
	cycleSl.bounds = cycleSl.bounds.height_(height);
	yzoomSl.bounds = yzoomSl.bounds.top_( 30 + height);
};

g.makeGui['Main_NTMI'] = { |dict, name = 'ntmi_MainStage'|

	var w, butGrey = Color.grey(0.3, 0.3), butGreen = Color.green(1, 0.7);
	var bounds = Window.availableBounds;
	var wheight = bounds.height, wwidth = bounds.width;
	var scrscale = min(bounds.width / 1920, bounds.height / 1177);

	var font = Font(g.fontName, (36 * scrscale).round);
	var fatfont = Font(g.fontName, (72 * scrscale).round);
	var center, centPadsL, padsLPos, centPadsR, padsRPos;

	var rightCol = bounds.width - ( bounds.width - bounds.height / 2) + (30 * scrscale);

	var nufoView, recBut;
	var bigUV, imuUV, imuWin;
	var popMVs, ndefPops, ndefMViews, rMViews;

	try { g.main.w.close };
	w = Window(name, bounds).front;
	g.main.w = w;
	g.main.w.background_(q.inph.currPresetCol);
	g.main.w.alpha_(g.alpha ? 0.8);

	bigUV = UserView(w, Rect.aboutPoint( bounds.center, wheight * 0.5, wheight * 0.5));
	bigUV.background_(Color.clear);
	g.main.bigUV = bigUV;
	bigUV.canFocus_(false);

	// imuWin = Window("", Rect.aboutPoint( w.bounds.center, 240 * scrscale, 300 * scrscale), false, false).front;
	// imuUV = v = UserView(imuWin, imuWin.bounds.moveTo(0,0));
	imuUV = v = UserView(w, Rect.aboutPoint( w.bounds.center, 240 * scrscale, 300 * scrscale));
	imuUV.background_(Color.clear);
	g.main.imuUV = imuUV;
	imuUV.canFocus_(false);

	g.main.padCols = 0!8;
	g.main.movevals = 0!9;

	// stetho needs to be in a new-style layout for resizing...
	g.main.stetho = Stethoscope(s, q.numChans, view: w.view);
	// resize quick and dirty
	defer ({
		g.main.stetho.view.bounds_(Rect(130, 0.0, 250.0, 250.0));
		g.scaleStetho(g.main.stetho, 230 * scrscale);

	}, 0.1);
	// ServerMeter does not scale at all...
	// put it in its own window?
	//
	g.main.meterWidth = ServerMeterView.getWidth(q.numIns ? q.numChans, q.numChans);
	g.main.meterLeft = (g.main.w.bounds.width - g.main.meterWidth) div: 2;
	g.main.meter = ServerMeterView(s, w, g.main.meterLeft@0, q.numIns ? q.numChans, q.numChans);

	nufoView = UserView(w, Rect(rightCol, 20 * scrscale, 300 * scrscale, 150 * scrscale));
	nufoView.background_(butGrey);
	nufoView.drawFunc_({ |uv|
		var bounds = uv.bounds.extent.asRect;
		Pen.addRect(bounds).color_(Color.white).stroke;
		Pen.addRect(bounds.copy.width_(bounds.width * (q.bat.percent ? 0 * 0.01)));
		Pen.color_(Color.green(0.75, 0.8)).fill;
		Pen.stringCenteredIn(
			q.wifiStr
			++ "\n" ++ q.frame.rateStr
			++ "\n" ++ q.bat.string,
			bounds,
			font.copy.size_(font.size * 0.8),
			Color.white
		);
		// "nufoView.drawFunc".postln;
	});
	nufoView.refresh;
	g.main.nufoView = nufoView;

	Button(w, Rect(rightCol, 340 * scrscale, 300 * scrscale, 60 * scrscale)).states_([
		["Reset Clock", Color.white, butGrey],
	]).font_(font)
	.action_({
		Tdef(\clocK).set(\runtime, 0, \isRunning, true).stop.play
	});

	recBut = Button(w, Rect(rightCol, 450 * scrscale, 300 * scrscale, 120 * scrscale)).states_([
		["RECORD?", Color.white, butGrey],
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

	Button(w, Rect(rightCol, 580 * scrscale, 300 * scrscale, 60 * scrscale)).states_([
		["show recordings", Color.white, butGrey]
	]).font_(font.copy.size_(font.size * 0.8))
	.action_({ |bt|
		Platform.recordingsDir.openOS;
	});

	Button(w, Rect(rightCol, 800 * scrscale, 300 * scrscale, 120 * scrscale)).states_([
		["CALIBRATE\ntouch + move?", Color.white, butGrey],
		["CALIBRATING\ntouch + move", Color.black, Color.yellow],
		["touch + move\ncalibrated", Color.white, butGrey],

	]).font_(font)
	.action_({ |but|
		but.value_(1);
		MFdef('calibrate').value(1, { |ok| but.value_(if (ok, 2, 0).postln) })
	});


	Button(w,
		Rect.aboutPoint( (wwidth * 0.5) @( wheight * 0.85), 150 * scrscale, 50 * scrscale)
	).states_([
		["MainFX\n<<  RAND  >>", Color.white, butGrey],
	]).font_(font)
	.mouseDownAction_({ |bt, x, y, mod|
		var zone = x div: (bt.bounds.width div: 3);
		var stepVal = [-1, nil, 1][zone];
		MFdef('mainPreStep').value(stepVal);
		// [bt, x, y, mod].postcs;
	});


	g.main.mainSl = MView(
		q.mFX.proxyChain.proxy.get(\mainVol),
		g.main.w, Rect.aboutPoint( (wwidth * 0.5) @( wheight * 0.94), 250 * scrscale, 50 * scrscale)
	);


	g.main.mainSl.uv.alpha_(0.7).refresh;
	g.main.mainSl.label_(\mainVol);
	g.main.mainSl.putDict(\myspec, [0, 4, \amp]);
	g.main.mainSl.dict[\knobCol] = Color.grey(0, 0.7);
	g.main.mainSl.dict.round_(1/100);
	g.main.mainSl.dict.font_(Font(g.fontName, 30 * scrscale));
	g.main.mainSl.action.add(\setMain, { |mv|
		q.mFX.proxyChain.proxy.set(\mainVol, mv.value)
	});
	g.main.mainSl.drawFunc.add(\label, {
		Pen.stringCenteredIn(
			g.main.mainSl.label,
			g.main.mainSl.bounds.moveTo(0,0),
			Font(g.fontName, 40 * scrscale),
			Color.blue
		)
	});
	g.main.mainVolDisplay = {
		var nuval = q.mFX.proxyChain.proxy.get(\mainVol);
		if (g.main.mainSl.value != nuval) {
			g.main.mainSl.value = nuval
		};
	};
	g.main.mainSl.dict[\focusCol] = Color.grey(1.0, 0.8);
	g.main.mainSl.dict[\backCol] = Color.grey(1.0, 0.6);
	g.main.mainSl.uv.focus(true).refresh;
	g.main.mainSl.uv.focus(false).refresh;


	// 4 popups to select sounds, 4 mviews for volume levels
	// add play buttons?
	popMVs = [ 3, 1, -1, -3].collect { |offset, i|
		var ndef = q.slots.actives[i];
		var ndefpre = NdefPreset(ndef);
		var top = w.bounds.center.y + (offset + 1 * -80 * scrscale);
		var left = 200 - (offset.abs * 0) * scrscale;

		var emmy = MView(0.25, w, Rect(left, top, 500 * scrscale, 150 * scrscale));
		var pop = PopUpMenu(w, Rect(left, top, 250 * scrscale, 40 * scrscale))
		.items_(q.slots.choices[i])
		.value_(ndef.key).font_(font);
		var prePop = PopUpMenu(w, Rect(left + 250 * scrscale, top, 250 * scrscale, 40 * scrscale))
		.items_(ndefpre.getSetNames)
		.value_(ndefpre.getSetNames.size.rand).font_(font);

		pop.background_(Color.grey(1.0, 0.7));

		pop.action = { |pop|
			q.slots.addActive(i, Ndef(pop.item));
			MFdef('guiSlots').value;
			emmy.refresh;
		};
		prePop.action = { |pop|
			var ndef = q.slots.actives[i];
			NdefPreset(ndef).setCurr(pop.item);
			// dont step, just add influx offset
			q.pre.stepNdefInf(ndef, 0);
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

		emmy.dict.keyNumFuncs
		.put($ , { q.slots.toggleAt(i) });

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
		[pop,emmy, prePop];
	};

	g.main.popups = popMVs.flop[0];
	g.main.ndefMViews = popMVs.flop[1];
	g.main.prePops = popMVs.flop[2];

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
			dict[\round] = (1/100);


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
	rMViews[0].label_(\zoom).value_(q.zoom).putDict(\myspec, \zoom.asSpec);

	rMViews[1].label_(\preUp).putDict(\myspec, [0, 7, \lin, 1]).value_(q.inph.presIndex);
	rMViews[1].uv.mouseDownAction = { MFdef('stepInphWPre').value(1) };

	rMViews[2].label_(\preDown).mode_(\code).value_(q.inph.randSeeds[q.inph.presIndex]);
	rMViews[2].uv.mouseDownAction = { MFdef('stepInphWPre').value(-1) };

	rMViews[3].label_(q.inph.mode).mode_(\code);
	rMViews[3].uv.mouseDownAction.add(\cycle, { |x|
		MFdef(\inphModeStep).value;
		rMViews[3].label_(q.inph.mode).valueAction_(q.inph.mode);
	});


	// circle shape in the background
	(
		bigUV.drawFunc = { |uv|
			var center = uv.bounds.extent * 0.5;
			var mainIndex = q.mfx.domainIndex;
			var domainName = q.mfx.preNames[mainIndex];

			"bigUV updating.".postln;
			Pen.translate(center.x, center.y);

			Pen.addArc(0@0, center.y * 0.9, 0, 2pi);
			// shape:
			Pen.color_(Color.white);
			Pen.width = 3;
			Pen.stroke;


			Pen.rotate(mainIndex.linlin(-1, q.mfx.preNames.size, 0.5pi, -0.5pi));
			Pen.scale(1.618, 1.618);
			Pen.stringCenteredIn(domainName,
				Rect.aboutPoint(0@0, center.x, 40),
				fatfont,
				Color.grey(1.0, 0.3)

			);
		};
		bigUV.refresh;
	);

	MFdef('mainPreStep').add(\updateMain, { defer { bigUV.refresh } });
	// possible fixes here:
	// do basic geometry of locations only once rel to center,
	// move to center, then scale,
	// and only paint the ones that are needed.

	// small UV in the middle for cheaper pads/axes drawing
	imuUV.drawFunc = { |uv|
		var myscale = Window.screenBounds.width / 1680;
		var bounds = uv.bounds.moveTo(0, 0);
		var center = bounds.center / myscale; // reverse scale
		var centPadsL, padsLPos, centPadsR, padsRPos;
		var star;

		Pen.scale(myscale, myscale);

		if ([\full, \touch, \binary].includes(q.inph.mode)) {
			centPadsL = center.copy.x_(center.x - (center.y * 1.8));
			centPadsR = center.copy.x_(center.x + (center.y * 1.8));
			padsLPos = [ -0.6, -0.2, 0.2, 0.6].collect { |angle|
				Polar(center.y * 1.5, angle * 0.8).asPoint + centPadsL;
			};

			padsRPos = [ 0.6, 0.2, -0.2, -0.6].collect { |angle|
				Polar(center.y * -1.5 + pi, angle * 0.8).asPoint + centPadsR;
			};

			Pen.width_(2);
			// 4 left, 4 right touchpads
			(padsLPos ++ padsRPos).collect { |pt, i|
				Pen.addArc(pt, 60, 0, 2pi);
				Pen.color_(g.main.padCols[i]);
				Pen.fill;
				// rings white
				Pen.addOval(Rect.aboutPoint(pt, 60, 60));
				Pen.color_(Color.white).stroke;
			};
		};

		// visualize move mode as star of 9;
		if ([\full, \move].includes(q.inph.mode)) {
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


	MFdef(\mainWinUpdate);

	g.main.skipper.stop;
	g.main.skipper = SkipJack(MFdef(\mainWinUpdate),  0.1, { w.isClosed }, name: \mainUV);

	// update OSC and battery status
	MFdef(\mainWinUpdate).add(\nufoView, {
		if (q.osc.timeSinceLast >= 1) {
			MFdef(\battery).(0);
			q.bat.resetVals;
			q.frame.resetVals;
		};

		// update battery status if new
		if (q.bat.percent != q.bat.percentOld
			or: { q.wifiOld != q.wifiStr
				or: { (q.frame.rateStr == q.frame.rateStrOld).not }
		})
		{
			g.main.nufoView.refresh;
			q.bat.percentOld = q.bat.percent;
			q.frame.rateStrOld = q.frame.rateStr;
			q.wifiOld = q.wifiStr;
		};
	});

	MFdef(\mainWinUpdate).add(\imuPad, {
		// only if values changed!
		if (q.osc.rawImuBiValues != q.osc.rawImuBiValuesOLD
			or: { q.osc.rawPads != q.osc.rawPadsOLD }) {

			g.main.movevals = q.osc.rawImuBiValues.biuni;
			if (q.inph.mode == \binary) {
				g.main.padCols = q.bin.bins.collect { |val, i|
					Color.white.alpha_(val);
				};
			} {
				g.main.padCols = q.osc.rawPads.collect { |val|
					Color.yellow(val).alpha_(val);
				};
			};
			g.main.imuUV.refresh;
		};
		q.osc.rawImuBiValuesOLD = q.osc.rawImuBiValues;
		q.osc.rawPadsOLD = q.osc.rawPads;
	});

	MFdef(\mainWinUpdate).add(\modeZoom, {
		// inphlux mode to color and mview labels and values
		if (g.main.backCol != q.inph.currPresetCol) {
			// "refresh win color.".postln;
			g.main.backCol = q.inph.currPresetCol;
			g.main.w.background_(q.inph.currPresetCol);
		};
		if (q.inph.mode != rMViews[3].label) { rMViews[3].label_(q.inph.mode) };
		if (q.inph.mode != rMViews[3].label) { rMViews[3].label_(q.inph.mode) };

		// zoom
		if ( q.zoom.absdif( rMViews[0].value) > 0.001 ) { rMViews[0].valueAction = q.zoom };

	});

	MFdef(\mainWinUpdate).add(\slots, MFdef('guiSlots'));

	MFdef(\mainWinUpdate).add(\main, g.main[\mainVolDisplay]);


	/////// Clock display shows how long something has been running
	/*
	Tdef(\clocK).set(\isRunning, true);
	// jumps back to zero when stopped
	Tdef(\clocK).set(\isRunning, false);
	*/

	/// add gui for the clock here:
	Tdef(\clocK).set(\timeUV, UserView(w,
		Rect(rightCol, 240 * scrscale, 300 * scrscale, 100 * scrscale)
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
};
