/**** New mainstage window: *****
reconsider layout so it scales better!
butz scope - meters - nufo status -
butz scope - meters - nufo calibrate
-------------- snap
butz slot1  nufo  nufo   zoom
butz slot2    CENTER     preUp
butz slot3    CENTER     preDn
butz slot4  nufo  nufo   nufmod
            MAINFX RAND
            MAIN VOLUME

make userViews here, make their drawFunc MFunc
extra files only add to these MFuncs then
*/

var g = NTMI.g;
var q = NTMI.q;


g.main = g.main ? ();
g.main.sliderCols = [ Color.grey(1.0, 0.85), Color.grey(0.8, 0.75) ];


// quick and dirty removal of nufo from gui:
g.hasNufo = { MKtl.all[\nUFO].notNil };
NTMI.nufo = NTMI.nufo ? ();
NTMI.nufo.bat = NTMI.nufo.bat ? ();
NTMI.nufo.frame = NTMI.nufo.frame ? ();
q.nufo = q.nufo ? ();
q.nufo.timeSinceLast = 0.2;

NTMI.g.dir = thisProcess.nowExecutingPath.dirname;

NTMI.g.main.winUpdate = MFunc();
NTMI.g.main.imuFunc = MFunc();

WinBounds.addMake('Main_NTMI', { |dict, name = 'ntmi_MainStage'|

	var w, butGrey = g.butGrey, butGreen = g.butGreen;
	var bounds = g.bounds;
	var wheight = g.bounds.height, wwidth = g.bounds.width;
	var scrscale = min(bounds.width / 1920, bounds.height / 1177);

	var font = Font(g.fontName, (36 * scrscale).round);
	var fatfont = Font(g.fontName, (72 * scrscale).round);
	var center, centPadsL, padsLPos, centPadsR, padsRPos;

	var rightCol = bounds.width - ( bounds.width - bounds.height / 2) + (30 * scrscale);

	var nufoView, recBut;
	var popMVs, ndefPops, ndefMViews, rMViews;


	NTMI.g.font = font; NTMI.g.fatfont = fatfont;
	// quick fix so we can keep nufo graphics when no nUFO present
	NTMI.nufo = NTMI.nufo ? ();
	NTMI.nufo.modes = NTMI.nufo.modes ? [\full, \touch, \binary]; //
	NTMI.nufo.modeIndex = NTMI.nufo.modeIndex ? 0;
	NTMI.nufo.mode = NTMI.nufo[\mode] ? { NTMI.nufo.modes.wrapAt(NTMI.nufo.modeIndex) };

	w = Window(name, bounds).front;
	g.main.w = w;
	g.main.w.background_(q.inph.currPresetCol);
	g.main.w.alpha_(g.alpha ? 0.8);

	//// CENTER ZONES:

	NTMI.g.main.bigUVBounds = Rect.aboutPoint( w.view.bounds.center, wheight * 0.5, wheight * 0.5);
	NTMI.g.main.bigUV = UserView(w, g.main.bigUVBounds).background_(Color.clear).canFocus_(false);
	NTMI.g.main.bigUVMFunc = MFunc();
	NTMI.g.main.bigUV.drawFunc = NTMI.g.main.bigUVMFunc;

	LoadMe("subsParts/bigUV.scd", NTMI.g.dir);

	NTMI.g.main.imuUVBounds = Rect.aboutPoint( w.view.bounds.center, 240 * scrscale, 300 * scrscale);
	NTMI.g.main.imuUV = UserView(w, g.main.imuUVBounds).background_(Color.clear).canFocus_(false);
	NTMI.g.main.imuUVMFunc = MFunc();
	NTMI.g.main.imuUV.drawFunc = NTMI.g.main.imuUVMFunc;
	NTMI.g.main.imuUV.background_(Color.rand.alpha_(0.4));
	LoadMe("subsParts/imuUV.scd", NTMI.g.dir);


	//// TOP LINE ZONES:

	LoadMe("subsParts/stetho.scd", NTMI.g.dir);

	NTMI.g.main.meterCenterTop = NTMI.g.main.w.bounds.center.x @ 0;
	LoadMe("subsParts/meter.scd", NTMI.g.dir);

	//// RIGHT COLUMN:

	g.main.rightColumn = CompositeView(w,
		Rect(rightCol, 0, 300 * scrscale, bounds.height)
	);

	NTMI.g.main.nufoZone = CompositeView(g.main.rightColumn,
		Rect(0, 330 * scrscale, 300 * scrscale, 300 * scrscale));
	LoadMe("subsParts/nufoInfo.scd", NTMI.g.dir);

	g.main.clockZone = CompositeView(w,
		Rect(rightCol, 635 * scrscale, 300 * scrscale, 160 * scrscale)
	).background_(Color.grey(1.0, 0.1));

	LoadMe("subsParts/clock.scd", NTMI.g.dir);

	g.main.recZone = CompositeView(w,
		Rect(rightCol, 800 * scrscale, 300 * scrscale, 160 * scrscale)
	).background_(Color.grey(1.0, 0.1));

	LoadMe("subsParts/recButs.scd", NTMI.g.dir);


	if (q.usesMainFX) {
		g.main.fxZone = CompositeView(w,
			Rect.aboutPoint( (wwidth * 0.5) @( wheight * 0.85),
				250 * scrscale, 50 * scrscale));
		LoadMe("subsParts/mainFXBut.scd", NTMI.g.dir);
	};

	NTMI.g.main.mainVolZone = CompositeView(w,
		Rect.aboutPoint( (wwidth * 0.5) @( wheight * 0.94), 250 * scrscale, 50 * scrscale)
	);

	LoadMe("subsParts/mainVol.scd", NTMI.g.dir);

	NTMI.g.main[\winUpdate].add(\main, NTMI.g.main[\updateMainVol]);

	g.main.leftMVZone = CompositeView(w,
		Rect(200 * scrscale,
			w.bounds.center.y + (3 + 1 * -80 * scrscale),
			500 * scrscale,
			160 * 4 * scrscale
		)
	);

	LoadMe("subsParts/slotGuis.scd", NTMI.g.dir);

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

	// snapshot button
	NTMI.g.main.snapBounds = (220@80 * scrscale).asRect
	.right_(NTMI.g.main.leftMVZone.bounds.right)
	.bottom_(NTMI.g.main.leftMVZone.bounds.top);

	g.main.snapBut = Button(g.main.w, g.main.snapBounds)
	.states_([["SNAP!", Color.blue, Color.grey(0.8, 0.8)],
		["¡SNAP!", Color.white, Color.red]
	])
	.action_(MFdef(\snapshot))
	.font_(fatfont);

	MFdef(\snapshot).add(\show, {
		if (g.main.w.isClosed.not) {
			defer { try { g.main.snapBut.value_(1);
				MFdef(\guiSlots).value;
			} };
			defer ({ try { g.main.snapBut.value_(0) } }, 1);
		};
	});

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
			dict[\round] = (1/1000);

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

	NTMI.g.main[\winUpdate].add(\inphPre, {
		if (q.inph.presIndex != rMViews[1].value) {
			protect {
				rMViews[1].value_(q.inph.presIndex);
				rMViews[2].value_("seed" + q.inph.randSeeds[q.inph.presIndex]);
			}
		}
	});

	rMViews[0].action.add(\setzoom, { |mv| q.setZoom(mv.value) });
	rMViews[0].label_(\zoom).value_(q.zoom).putDict(\myspec, \zoom.asSpec);

	rMViews[1].label_(\preUp).putDict(\myspec, [0, 7, \lin, 1]).value_(q.inph.presIndex);
	rMViews[1].uv.mouseDownAction = { NTMI.inph.stepWPre(1) };

	rMViews[2].label_(\preDown).mode_(\code).value_(q.inph.randSeeds[q.inph.presIndex]);
	rMViews[2].uv.mouseDownAction = { NTMI.inph.stepWPre(-1) };

	rMViews[3].label_('nUFO mode').value_(q.nufo.mode).mode_(\code);
	rMViews[3].uv.mouseDownAction.add(\cycle, { |x|
		NTMI.nufo.modeStep(1);
		rMViews[3].valueAction_(q.nufo.mode);
	});


	g.main.nufoViews = [
		// g.main.imuUV,
		g.main.nufoView,
		g.main.rMViews.last.uv, // mode view
		g.main.caliBut,
	];

	g.main.skipper.stop;
	g.main.skipper = SkipJack(NTMI.g.main[\winUpdate],  0.1, { w.isClosed }, name: \mainUV);

	// update OSC and battery status
	NTMI.g.main[\winUpdate].add(\nufoView, {
		var showNufo = g.hasNufo;
		g.main.nufoViews.do { |view|
			if (view.visible != showNufo) {
				view.visible = showNufo;
			};
		};

		if (showNufo) {
			if (q.nufo.timeSinceLast >= 1) {
				NTMI.nufo.bat.calc.(0);
				NTMI.nufo.bat.resetVals;
				NTMI.nufo.frame.resetVals;
			};


			// update battery status if new
			if (NTMI.nufo.bat.percent != NTMI.nufo.bat.percentOld
				or: { q.wifiOld != q.wifiStr
					or: { (NTMI.nufo.frame.rateStr == NTMI.nufo.frame.rateStrOld).not }
			})
			{
				g.main.nufoView.refresh;
				NTMI.nufo.bat.percentOld = NTMI.nufo.bat.percent;
				NTMI.nufo.frame.rateStrOld = NTMI.nufo.frame.rateStr;
				q.wifiOld = q.wifiStr;
			};
		};
	});


	NTMI.g.main[\winUpdate].add(\modeZoom, {
		// inphlux mode to color and mview labels and values
		if (g.main.backCol != q.inph.currPresetCol) {
			// "refresh win color.".postln;
			g.main.backCol = q.inph.currPresetCol;
			g.main.w.background_(q.inph.currPresetCol);
		};
		if (g.hasNufo) {
			if (q.nufo.mode != rMViews[3].label) { rMViews[3].label_(q.nufo.mode) };
		};

		// zoom
		if ( q.zoom.absdif( rMViews[0].value) > 0.001 ) { rMViews[0].valueAction = q.zoom };

	});

	NTMI.g.main[\winUpdate].add(\slots, NTMI.g.main[\updateSlots]);

	NTMI.g.main.w
});
