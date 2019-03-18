/**** Experiments for new maistage window: *****

- keep scope
- add server meter?

- use MViews for volume sliders?
- add ProxyMeter on top of MView?

- show pads in geom. layout,
grey if move mode, bright

q.keys(SortedList).postcs

SortedList[ 'active', 'allSoundNames', 'allSoundPaths', 'broad', 'centerToCurrent', 'centerToNewRandSeed', 'centerToPreset', 'centerToRandPreset', 'choice', 'choiceNewNdefFunc', 'choiseNdefs_storePath', 'currPresetCol', 'currxoscPx', 'dirnames', 'fulldirnames', 'fx', 'getActivePxsAsList', 'getInfluxDestins', 'getMyIPs', 'getNdefs', 'getPdefs', 'getTdefs', 'gpad', 'guiMaFX', 'guiXOSC', 'incZoom', 'incrementSeed', 'influxWhich', 'inphGui', 'inphlux', 'inphscale', 'lastOSCactivity', 'liveInput', 'loadFolder', 'loadRel', 'mFX', 'mainStageSkippa', 'mainstage', 'makeCurr', 'makeMeAPreset', 'makePast', 'me', 'mfx', 'midi', 'mySoundPaths', 'mySoundsIndex', 'ndefGuis', 'ndefPresetWin', 'ndefs', 'ndgwin', 'numChans', 'padCols', 'postServerOptions', 'presetCols', 'pxmix', 'resetInphl', 'seedRandInfl', 'setZoom', 'slOffset', 'sliders', 'soundsPerPlayer', 'stepNdefPreInf', 'stepWeights', 'timeText', 'timerButton', 'topDir', 'utilDir', 'warnWin', 'x', 'zoom' ]


/// move mode, touch pads off:
q.padCols = Color.grey(0.5, 0.25) ! 8; u.refresh;
q.currMode = \touch; q.movevals = { 1.0.rand }!9;
u.refresh;


// touch mode
q.padCols = { Color.yellow(rrand(0.2, 1.0)).red_(1) } ! 8; u.refresh;
q.currMode = \move; q.movevals = { 0 }!9; u.refresh;

// all Ndefs off
m.do (_.putDict(\backCol, Color.grey)); m.do(_.refresh);
// all on
m.do (_.putDict(\backCol, Color.green(1.0))); m.do(_.refresh);

// move mode

q.currMode = \move;

n[3].label_('touch').value_('touch');
n[3].label_('move').value_('move');

NdefMixer(s)
*/

q.currMode = q.currMode ? \move;

q.makeGui.mainstage_adc = {
	var font = Font("Monaco", 36);
	var center, centPadsL, padsLPos, centPadsR, padsRPos;
	var bounds = Window.screenBounds;
	var rightCol = bounds.width - ( bounds.width - bounds.height / 2) + 30;

	var oscBut, midiBut;
	// var w, u, v, z, m, n;

	try { w.close };
	w = Window("N T M I MainStage", bounds.height_( bounds.height - 50)).front;
	u = UserView(w, bounds);
	v = UserView(w, Rect.aboutPoint( w.bounds.center, 240, 300)).background_(Color.red);
	u.background_(Color.red);

	q.padCols = Color.grey(0.5) ! 8;

	q.movevals = MKtl('xosc').elAt([0, 1, 2]).flat.collect(_.value);
	q.movevals = { 1.0.rand2 }!9;
	q.movevals = { 1.0 }!9; u.refresh;


	Stethoscope(s, 4, view: w.view);
	ServerMeterView(s, w, 250@0, 4, 4);

	oscBut = Button(w, Rect(rightCol, 10, 300, 50)).states_([
		["¿¿OSC??", Color.white, Color.red],
		["¡OSC OK!", Color.black, Color.green]
	]).font_(font).value_(0);

	midiBut = Button(w, Rect(rightCol, 80, 300, 50)).states_([
		["¿¿MIDI??", Color.white, Color.red],
		["MIDI OK!", Color.black, Color.green]
	]).font_(font).value_(0);

	Button(w, Rect(rightCol, 810, 300, 150)).states_([
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

	Button(w, Rect(rightCol, 610, 300, 150)).states_([
		["Reset Clock", Color.white, Color.red],
	]).font_(font)
	.action_({ Tdef(\clocK).set(\runtime, 0, \isRunning, true).stop.play });



	// 4 popups to select sounds, and volume levels
	m = [ 3, 1, -1, -3].collect { |offset, i|
		var top = w.bounds.center.y + (offset + 1 * -80 );
		var left = 200 - (offset.abs * 0);
		var emmy = MView(0.25, w, Rect(left, top, 500, 150));
		var pop = PopUpMenu(w, Rect(left, top, 250, 40)).items_(q.allSoundNames)
		.value_(q.allSoundNames.indexOf(q.ndefs[i].key)).font_(font);
		pop.alpha_(0.8);
		pop.action = { |pop|
			q.ndefs.put(i, Ndef(pop.item));
			emmy.refresh;
		};
		emmy.uv.alpha = 0.8;
		emmy.dict[\knobCol] = Color.grey(0, 0.7);
		emmy.putDict(\myspec, \amp);
		emmy.drawFunc.add(\label, {
			Pen.stringCenteredIn(
				q.ndefs[i].key.asString,
				emmy.bounds.moveTo(0,0),
				Font("Monaco", 72),
				Color.blue
			)
		});
		emmy;
	};


	n = [ 3, 1, -1, -3].collect { |offset, i|
		var top = w.bounds.center.y + (offset + 1 * -80 );
		var left = 1220 + (offset.abs * 0);
		var initval = [1.0, \pre_1, '¿-?', \move][i];
		var emmy = MView(nil, w, Rect(left, top, 320, 150));
		emmy.dict[\knobCol] = Color.grey(0, 0.7);
		emmy.uv.alpha = 0.8;
		emmy.drawFunc.add(\label, {
			Pen.stringCenteredIn(
				emmy.label ? emmy.value,
				emmy.bounds.moveTo(0,0),
				Font("Monaco", 72),
				Color.blue
			)
		});
		emmy;
	};
	n[0].label_(\zoom).value_(q.zoom).putDict(\myspec, \unipolar);
	n[1].label_(\preset).value_(0).putDict(\myspec, [0, 7, \lin, 1]);
	n[2].label_('¿-?').value_('¿-?').mode_(\code);
	n[3].label_('move').value_('move').mode_(\code);

	n[0].action.add(\setzoom, { |mv| q.setZoom(mv.value) });

	n[3].uv.mouseDownAction.add(\toggle, { |x|
		var vals = [ \touch, \move];
		var currVal = vals.indexOf(n[3].value) ? 0;
		var newval = vals[1-currVal];
		n[3].label_(newval).valueAction_(newval);
		q.currMode = newval;
	});

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

	(
		v.drawFunc = { |uv|
			var bounds = uv.bounds.moveTo(0,0);
			var center = bounds.center;
			var centPadsL, padsLPos, centPadsR, padsRPos;
			var star;

			// Pen.stringAtPoint("tralala", 10@10);

			// [bounds, center].postln;

			if (q.currMode == \touch) {
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
					Pen.color_(q.padCols[i]);
					Pen.fill;
					// Pen.stringCenteredIn(i.asString, Rect.aboutPoint(pt, 60, 60),
					// 	font: Font("Monaco", 96),
					// color: Color.black);
				};
			};

			// visualize move mode as star of 9;
			if (q.currMode == \move) {
				// "move mode vis".postln;
				star = q.movevals.collect { |val, i|
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
			// q.padCols = { Color.yellow(rrand(0.2, 1.0)).red_(1) } ! 8;
			// q.movevals = { 1.0.rand }!9;
			q.movevals = x.elAt(['accel', 'gyro', 'magnet']).flat.collect(_.value);
			q.padCols = x.elAt('inA').value.keep(8).collect { |val|
				Color.yellow(val.linlin(0, 1, 0.25, 1)).red_(1);
			};
			v.refresh;
			// zoom
			n[0].value = q.zoom;
			// OSC status
			oscBut.value = q.osc.timeSinceLast < 1;
		}, 0.1, name: \mainUV);

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
	Tdef(\clocK).set(\timeUV, UserView(w, Rect(rightCol, 110, 300, 200)).front);
	Tdef(\clocK).get(\timeUV).drawFunc = { |uv|
		var timeStr = Tdef(\clocK).get(\timeStr);
		Pen.stringCenteredIn(timeStr, Rect(0,0, uv.bounds.width, uv.bounds.height),
			Font("Monaco", 60), Color.white)
	};

	Tdef(\clocK).get(\timeUV).refresh;

	Tdef(\clocK, { |envir|
		var dt = 1;
		var timeStr;
		inf.do { |i|
			if (envir.isRunning == true) {
				envir.runtime = envir.runtime ? 0 + dt;
			} {
				envir.runtime = 0;
			};
			envir.timeStr =
			// "Runtime :\n" +
			envir.runtime.asTimeString.drop(-4);
			defer { envir.timeUV.refresh };
			dt.wait;
		}
	}).play;
};