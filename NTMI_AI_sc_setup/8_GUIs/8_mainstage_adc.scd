/**** New mainstage window: *****
new layout so it scales better:

butz scope - meters -  [       ] <- free for influx
------------- snap
butz slot1  nUFO  nUFO   zoom     nufoInfo
butz slot2    Info       preUp    clock
butz slot3    Info       preDn    recButs
butz slot4  nUFO  nUFO   nufmod   recButs
.           MAINFX RAND
.           MAIN VOLUME

*/

// gui code directory
NTMI.g.dir = thisProcess.nowExecutingPath.dirname; // ++ "xxx";

// subdict for all Main_NTMI window items
NTMI.g.main = NTMI.g.main ? ();

// style, look, feel variables
NTMI.g.main.sliderCols = [ Color.grey(1.0, 0.85), Color.grey(0.8, 0.75) ];
NTMI.g.alpha = NTMI.g.alpha ? 0.8;

NTMI.g.main.winUpdate = MFunc();
NTMI.g.main.imuFunc = MFunc();


// nUFO - allow for removal of nUFO views from gui:
NTMI.g.hasnUFO = { MKtl.all[\nUFO].notNil };
NTMI.nUFO = NTMI.nUFO ? ();

NTMI.nUFO.bat = NTMI.nUFO.bat ? ();
NTMI.nUFO.frame = NTMI.nUFO.frame ? ();
NTMI.nUFO.timeSinceLast = NTMI.nUFO.timeSinceLast ? 0.2;

NTMI.nUFO.modes = NTMI.nUFO.modes ? [\full, \touch, \binary]; //
NTMI.nUFO.modeIndex = NTMI.nUFO.modeIndex ? 0;
NTMI.nUFO.mode = NTMI.nUFO[\mode] ? { NTMI.nUFO.modes.wrapAt(NTMI.nUFO.modeIndex) };


WinBounds.addMake('Main_NTMI', {

	var main = NTMI.g.main;
	var name = 'Main_NTMI';
	// style vars
	var butGrey = NTMI.g.butGrey, butGreen = NTMI.g.butGreen;
	var font = NTMI.g.font, fontFat = NTMI.g.fontFat;

	var bounds = NTMI.g.bounds;
	var wheight = bounds.height, wwidth = bounds.width;
	// macbook pro default
	var scrscale = min(bounds.width / 1512, bounds.height / 944);

	// define geometric constraints for good scaling of window -
	// absolute numbers, dont scale:
	// shrink butz width for small screens
	var leftMinWidth = NTMI.g.bounds.width.linlin(480, 1200, 80, 130);
	var topMinHeight = NTMI.g.bounds.height.linlin(320, 1200, 100, 230);
	var botMinHeight = NTMI.g.bounds.height.linlin(320, 1200, 0, 230);
	var meterWidth = ServerMeterView.getWidth(NTMI.numIns, NTMI.numChans, s);
	var scopeWidth = 264;
	var frontUVSize = bounds.height / 2 - topMinHeight;
	var marg = 6;

	var colHeight = wheight - topMinHeight - botMinHeight;

	var leftColWidth = bounds.width / 2 - frontUVSize - marg - leftMinWidth;
	var leftColRect = Rect(leftMinWidth, topMinHeight, leftColWidth, colHeight);

	var midRightColLeft = bounds.width / 2 + frontUVSize + marg;
	var rightColWidth = bounds.width  - midRightColLeft / 2 - marg;
	var midRightColRect = Rect(midRightColLeft, topMinHeight, rightColWidth, colHeight);

	var rightColRect = midRightColRect.copy.left_(midRightColRect.right + marg);

	// define all window and view variables
	var w, leftCol, midRightCol, rightCol;
	var center, centPadsL, padsLPos, centPadsR, padsRPos;
	var nUFOView, recBut;
	var popMVs, ndefPops, ndefMViews, rMViews;

	"leftMinWidth: %, botMinHeight: %\n".postf(leftMinWidth, botMinHeight);

	///// then make the window:
	w = Window(name, bounds).front.alpha_(NTMI.g.alpha ? 0.8);
	w.background_(NTMI.inph.currPresetCol);
	NTMI.g.main.w = w;

	NTMI.g.main.marg = marg;

	////////////
	// 	// then negotiate and make all zones ...


	// then make the zones
	//// CENTER ZONES:
	// bigUV - the background center square for the circle and mainFX name:
	main.bigUVBounds = Rect.aboutPoint( bounds.center, wheight * 0.5, wheight * 0.5);
	main.bigUV = UserView(w, main.bigUVBounds)
	.canFocus_(false);
	main.bigUVMFunc = MFunc();
	main.bigUV.drawFunc = main.bigUVMFunc;
	LoadMe("subsParts/bigUV.scd", NTMI.g.dir);

	main.frontUVBounds =
	Rect.aboutPoint( bounds.center, frontUVSize, frontUVSize);

	main.imuUV = UserView(w, main.frontUVBounds)
	.canFocus_(false);
	main.imuUVMFunc = MFunc();
	main.imuUV.drawFunc = main.imuUVMFunc;

	LoadMe("subsParts/imuUV.scd", NTMI.g.dir);

	// 	//// TOP LINE ZONES:

	main.meterCenterTop = main.w.bounds.center.x @ 0;
	main.meterHeight = 230;
	main.scopeLeft = leftMinWidth;
	main.meterLeft = main.meterCenterTop.x - (meterWidth / 2);
	if (main.scopeLeft + scopeWidth > main.meterLeft) {
		"move scope to the left".postln;
		main.scopeLeft = (main.meterLeft - scopeWidth).max(0);
	};

	main.stethoBounds = Rect(main.scopeLeft, 0, scopeWidth, topMinHeight);
	LoadMe("subsParts/meter.scd", NTMI.g.dir);


	LoadMe("subsParts/stetho.scd", NTMI.g.dir);

	// snapshot button
	main.snapBounds = (190@60 * scrscale).asRect
	.left_(main.meterCenterTop.x - (95 * scrscale))
	.top_(main.meterHeight);

	main.snapBut = Button(main.w, main.snapBounds)
	.states_([["SNAP!", Color.blue, Color.grey(0.8, 0.8)],
		["¡SNAP!", Color.white, Color.red]
	])
	.action_(MFdef(\snapshot))
	.font_(fontFat);

	MFdef(\snapshot).add(\show, {
		if (main.w.isClosed.not) {
			defer { try { main.snapBut.value_(1);
				MFdef(\guiSlots).value;
			} };
			defer ({ try { main.snapBut.value_(0) } }, 1);
		};
	});

	// for the demo:
	main.frontText = StaticText(main.w, main.imuUV.bounds);
	main.frontText.align_(\center).font_(fontFat).acceptsMouse_(false);

	NTMI.g.setFrontText = { |q, text=""|
		defer {
			"*** frontText:  ".post;
			main.frontText.string = text.asString.postln; };
	};

	main.leftCol = leftCol = CompositeView(w, leftColRect);
	main.midRightCol = midRightCol  = CompositeView(w, midRightColRect);
	main.rightCol = rightCol = CompositeView(w, rightColRect);

	main.nUFOZone = CompositeView(main.rightCol,
		Rect(0, 0, rightColWidth, rightCol.bounds.height / 3));
	LoadMe("subsParts/nUFOInfo.scd", NTMI.g.dir);

	main.clockZone = CompositeView(main.rightCol,
		Rect(0, main.nUFOZone.bounds.height,
			rightColWidth, rightCol.bounds.height / 3)
	)
	.background_(Color.grey(1.0, 0.1)
	);

	LoadMe("subsParts/clock.scd", NTMI.g.dir);

	main.recZone = CompositeView(main.rightCol,
		Rect(0, rightCol.bounds.height * 2 / 3,
			rightColWidth, rightCol.bounds.height / 3)
	).background_(Color.grey(1.0, 0.1));

	LoadMe("subsParts/recButs.scd", NTMI.g.dir);

	main.mainHeight = bounds.height - main.frontUVBounds.bottom - 40 / 2;

	main.mainRect = Rect(
		main.frontUVBounds.left,
		main.frontUVBounds.bottom + (marg * 0.5),
		main.frontUVBounds.width,
		main.mainHeight
	);


	if (NTMI.usesMainFX) {
		main.fxZone = CompositeView(w, main.mainRect);
		LoadMe("subsParts/mainFXBut.scd", NTMI.g.dir);
		main.mainRect = main.mainRect.moveBy(0, main.mainRect.height + 2);
	};
	main.mainVolZone = CompositeView(w, main.mainRect);
	LoadMe("subsParts/mainVol.scd", NTMI.g.dir);


	main[\winUpdate].add(\main, main[\updateMainVol]);

	NTMI.g.main.leftMVZone = leftCol;
	LoadMe("subsParts/slotGuis.scd", NTMI.g.dir);

	////// the 4 mviews on the right -  remove n eventually
	rMViews = 4.collect { |i|
		var initval = [1.0, \pre_1, '¿-?', \full][i];
		var height = rightColRect.height / 4;
		var rect = Rect(0, height * i, rightColRect.width, height - marg);
		var emmy = MView(nil, midRightCol, rect);
		emmy.dict[\knobCol] = Color.grey(0, 0.6);
		emmy.uv.alpha = 0.8;
		emmy.uv.resize_(1);
		emmy.drawFunc.add(\label, {
			Pen.stringCenteredIn(
				emmy.label ? emmy.value,
				emmy.bounds.moveTo(0,0),
				fontFat,
				Color.blue
			)
		});
		emmy;
	};
	main.rMViews = rMViews;

	///// unify all mview behaviours :

	[main.ndefMViews, rMViews].flat.do { |mv|

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

	main[\winUpdate].add(\inphPre, {
		if (NTMI.inph.presIndex != rMViews[1].value) {
			protect {
				rMViews[1].value_(NTMI.inph.presIndex);
				rMViews[2].value_("seed"
					+ NTMI.inph.randSeeds[NTMI.inph.presIndex]);
				NTMI.g.main.bigUVUpdate;
			}
		}
	});

	rMViews[0].action.add(\setzoom, { |mv| NTMI.setZoom(mv.value) });
	rMViews[0].label_(\zoom).value_(NTMI.zoom).putDict(\myspec, \zoom.asSpec);

	rMViews[1].label_(\preUp).putDict(\myspec, [0, 7, \lin, 1]).value_(NTMI.inph.presIndex);
	rMViews[1].uv.mouseDownAction = { NTMI.inph.stepWPre(1) };

	rMViews[2].label_(\preDown).mode_(\code).value_(NTMI.inph.randSeeds[NTMI.inph.presIndex]);
	rMViews[2].uv.mouseDownAction = { NTMI.inph.stepWPre(-1) };

	rMViews[3].label_('nUFO mode').value_(NTMI.nUFO.mode).mode_(\code);
	rMViews[3].uv.mouseDownAction.add(\cycle, { |x|
		NTMI.nUFO.modeStep(1);
		rMViews[3].valueAction_(NTMI.nUFO.mode);
	});


	main.nUFOViews = [
		// main.imuUV,
		main.nUFOView,
		main.rMViews.last.uv,
		main.caliBut,
		main.nUFO2InfBut
	];

	main.skipper.stop;
	main.skipper = SkipJack(main[\winUpdate],  0.1, { w.isClosed }, name: \mainUV);

	// update OSC and battery status
	main[\winUpdate].add(\nUFOView, {
		var shownUFO = NTMI.g.hasnUFO;
		main.nUFOViews.do { |view|

			if (view.notNil and: { view.visible != shownUFO }) {
				view.visible = shownUFO;
			};
		};

		if (shownUFO) {
			if (NTMI.nUFO.timeSinceLast >= 1) {
				NTMI.nUFO.bat.calc.(0);
				NTMI.nUFO.bat.resetVals;
				NTMI.nUFO.frame.resetVals;
			};


			// update battery status if new
			if (NTMI.nUFO.bat.percent != NTMI.nUFO.bat.percentOld
				or: { NTMI.wifiOld != NTMI.wifiStr
					or: { (NTMI.nUFO.frame.rateStr == NTMI.nUFO.frame.rateStrOld).not }
			})
			{
				main.nUFOView.refresh;
				NTMI.nUFO.bat.percentOld = NTMI.nUFO.bat.percent;
				NTMI.nUFO.frame.rateStrOld = NTMI.nUFO.frame.rateStr;
				NTMI.wifiOld = NTMI.wifiStr;
			};
		};
	});


	main[\winUpdate].add(\modeZoom, {
		// inphlux mode to color and mview labels and values
		if (main.backCol != NTMI.inph.currPresetCol) {
			// "refresh win color.".postln;
			main.backCol = NTMI.inph.currPresetCol;
			main.w.background_(NTMI.inph.currPresetCol);
			/// main.g.bigUV.refresh;
		};
		if (NTMI.g.hasnUFO) {
			if (NTMI.nUFO.mode != rMViews[3].label) { rMViews[3].label_(NTMI.nUFO.mode) };
		};

		// zoom
		if ( NTMI.zoom.absdif( rMViews[0].value) > 0.001 ) { rMViews[0].valueAction = NTMI.zoom };

	});

	main[\winUpdate].add(\slots, main[\updateSlots]);

	w
});
