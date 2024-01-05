/**** guis for the 4 slots: *****

// test gui update
NTMI.g.main[\updateSlots];

NTMI.slots.chooseNext(0); NTMI.g.main[\updateSlots];
NTMI.slots.chooseNext(1); NTMI.g.main[\updateSlots];

NTMI.slots.addActive(0, Ndef(\kiteHi));

NTMI.g.main.ndefMViews[0].label;

NTMI.g.main.leftMVZone.bounds;

*/

var scrscale = NTMI.g.screenScale;
var font = NTMI.g.font, fatfont = NTMI.g.fatfont;
var popMVs;



if (NTMI.g.main.leftMVZone.isNil or: {
	NTMI.g.main.leftMVZone.isClosed
}) {
	NTMI.g.main.leftMVZone = CompositeView(nil, Rect(158.0, 258.0, 300, 400)).front;
	SkipJack(NTMI.g.main[\updateSlots], 0.2, {
		NTMI.g.main.leftMVZone.isClosed
	}, \slotGuis);
};

NTMI.g.addMVmeter = { |g, gui, bounds|
	if (ProxyMeter.proxyGuis.includes(gui).not) {
		ProxyMeter.proxyGuis.add(gui);
		ProxyMeter.prePostViews.put(gui,
			PrePostView(gui.parent, bounds));
	};
	ProxyMeter.checkSkip;
};


// 4 popups to select sounds, 4 mviews for volume levels
// add play buttons?
popMVs = 4.collect { |i|
	var ndef = NTMI.slots.actives[i];
	var ndefpre = NdefPreset(ndef);
	var zonebounds = NTMI.g.main.leftMVZone.bounds;
	var left = 0;
	var top = zonebounds.height / 4 * i;
	var width = zonebounds.width;
	var height = zonebounds.height / 4 - NTMI.g.main.marg;

	var emmy = MView(0.25, NTMI.g.main.leftMVZone, Rect(left, top, width, height));
	var pop = PopUpMenu(NTMI.g.main.leftMVZone,
		Rect(left, top, width * 0.45, height / 4))
	.items_(NTMI.slots.choices[i])
	.value_(ndef.key).font_(font);
	var prePop = PopUpMenu(NTMI.g.main.leftMVZone,
		Rect(left + (width * 0.45), top, width * 0.45, height / 4))
	.items_(ndefpre.getSetNames)
	.value_(ndefpre.getSetNames.size.rand).font_(font);


	var coupleBut = Button(NTMI.g.main.leftMVZone,
		Rect(left + (width * 0.9), top, width * 0.1, height / 4))
	.states_([["––"], ["- -"]])
	.font_(font);

	emmy.addUniqueMethod(\object, { emmy.dict.object });
	emmy.dict.object = ndef;
	NTMI.g.addMVmeter(emmy,
		Rect(left, top + (height * 0.75), width, height * 0.25)
	);

	pop.background_(Color.grey(1.0, 0.4));

	pop.action = { |pop|
		NTMI.slots.addActive(i, Ndef(pop.item));
		MFdef('guiSlots').value;
		emmy.refresh;
	};

	prePop.action = { |pop|
		var ndef = NTMI.slots.actives[i];
		NdefPreset(ndef).setCurr(pop.item).setProxy(pop.item);
		// dont step, just add influx offset
		NTMI.pre.stepNdefInf(ndef, 0);
		MFdef('guiSlots').value;
		emmy.refresh;
	};

	coupleBut.action = { |but|
		var ndef = NTMI.slots.actives[i];
		if (but.value > 0) {
			NTMI.inph.decouple(ndef)
		} {
			NTMI.inph.couple(ndef)
		}
	};

	emmy.uv.resize_(1);
	emmy.uv.alpha = 0.8;
	emmy.dict[\knobCol] = Color.grey(0, 0.7);
	emmy.putDict(\myspec, \amp);
	emmy.action.add(\setVol,  { |em|
		NTMI.slots.actives[i].vol_(em.value)
	});

	emmy.dict.keyNumFuncs
	.put($ , { NTMI.slots.toggleAt(i) });

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
	[pop,emmy, prePop, coupleBut];
};

NTMI.g.main.popups = popMVs.flop[0];
NTMI.g.main.ndefMViews = popMVs.flop[1];
NTMI.g.main.prePops = popMVs.flop[2];
NTMI.g.main.coupleButs = popMVs.flop[3];


// start with click, or drag for volume change
NTMI.g.main.ndefMViews.do { |mview, i|
	var downx, didDrag;
	// prepare for toggle or volume change
	mview.uv.mouseDownAction = { |uv, x|
		// ("down" + x).postln;
		downx = x;
		didDrag = false;
	};
	// volume change, no on/off toggle
	mview.uv.mouseMoveAction = { |uv, x|
		var ndef = NTMI.slots.actives[i];
		var wid = uv.bounds.width;
		var step = (x - downx / wid * 1.6);
		var spec = \amp.asSpec;
		var currvol = ndef.vol;
		var currvolnorm = spec.unmap(currvol);
		var newvolnorm = (currvolnorm + step).clip(0, 1);
		var newvol = spec.map(newvolnorm);

		downx = x;
		didDrag = true;
		ndef.vol = newvol;
		uv.refresh;
	};
	// no move, just click ->  on/off toggle
	mview.uv.mouseUpAction = {|uv, x|
		var ndef = NTMI.slots.actives[i];
		if (didDrag.not) {
			didDrag = false;
			\toggle.postln;
			NTMI.slots.toggleAt(i);
			uv.refresh;
		};
	}
};


NTMI.g.main.ndefMViews.do { |mv|

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


NTMI.g.main[\updateSlots] = {

	NTMI.slots.actives.do { |ndef, i|
		var pop = NTMI.g.main.popups[i];
		var prepop = NTMI.g.main.prePops[i];
		var mview = NTMI.g.main.ndefMViews[i];
		var coupleBut = NTMI.g.main.coupleButs[i];
		var vol = ndef.vol;

		var playCol = if (ndef.monitor.isPlaying,
			NTMI.g.main.sliderCols[0],
			NTMI.g.main.sliderCols[1]);
		var ndefRandSeed;

		var isDecoupled = NTMI.inph.decoupled.includes(ndef.key);

		var presetName = NdefPreset(ndef).currSet.key;

		var newLabel = ndef.key.asString;

		if (presetName == \curr) {
			ndefRandSeed = ndef.getHalo(\randSeed);
			ndefRandSeed !? {
				newLabel = newLabel + "rd." ++ ndefRandSeed
			};
		} {
			newLabel = newLabel + presetName
		};


		if (ndef.key != pop.item or: { newLabel != mview.label }) {
			pop.items = NTMI.slots.choices[i];
			pop.value = pop.items.indexOf(ndef.key);

			mview.dict.object = ndef;
			prepop.items = NdefPreset(ndef).getSetNames;
			prepop.value = NdefPreset(ndef).currIndex;

			mview.label_( newLabel );
		};

		if (NdefPreset(ndef).settings.size != prepop.items.size) {
			prepop.items = NdefPreset(ndef).getSetNames;
		};

		if (NdefPreset(ndef).currIndex != prepop.value) {
			prepop.value = NdefPreset(ndef).currIndex;
		};

		if (mview.value != vol) { mview.value = vol };
		if (mview.uv.background != playCol) { mview.uv.background_(playCol) };

		if (coupleBut.value != isDecoupled) {
			coupleBut.value = isDecoupled.binaryValue
		};

	};
};
