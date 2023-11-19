// Sketch for miniature GUI for raspi-box screens:
// designed for small fixed size, 3.5 inch, 480x320 pixels.

// Butz.numButz = 24;
// Butz.w.close;
// Butz.show.updateButtons;

// Butz.add('miniNTMI', { WinBounds.showOrMake('miniNTMI')});
// WinBounds.addMake('miniNTMI', {
// 	g.makeGui['miniNTMI'].value;
// });

var g = NTMI.g;
var q = NTMI.q;


MFdef(\miniGuiUpdate).add(\slots, {
	// "slots...".postln;
});

MFdef(\miniGuiUpdate).add(\devices, {
	// show which MKtls are physically connected:
	// nufo, nanoK2, uc4, gamepad
	// devices found?".postln;
});

MFdef(\miniNufoUV).add(\, {
	// draw pad values,
	// orientation star,
	// and network name on little uv in center
});

/*
q.keys
MFdef(\miniGuiUpdate).value;
*/

MFdef(\miniGuiUpdate).add(\modeZoom, {

	var mainvol = q.mfx.chain.proxy.get(\mainVol).round(0.001);

	if (g.mini.mainVol.value != mainvol) {
		g.mini.mainVol.value = mainvol
	};

	if (g.mini.mainPop.value != q.mfx.domainIndex) {
		g.mini.mainPop.value = q.mfx.domainIndex
	};

		// inphlux mode to color and mview labels and values

	if (g.mini.backCol != q.inph.currPresetCol) {
		// "refresh win color.".postln;
		g.mini.backCol = q.inph.currPresetCol;
		g.mini.w.background_(q.inph.currPresetCol);
	};

	if (q.inph.presIndex != g.mini.infpre.value) {
		g.mini.infpre.value = q.inph.presIndex
	};
	// zoom
	if ( q.zoom.absdif( g.mini.zoom.value) > 0.001 ) {
		g.mini.zoom.value = q.zoom
	};
	// mode

	if (q.inph.mode != g.mini.modePop.item) {
		g.mini.modePop.value = q.inph.modes.indexOf(q.inph.mode).postln;
	};
});

g.mini = ();

WinBounds.addMake(\miniNTMI, {

	var w = Window("miniNTMI", Rect(300, 300, 480, 320)).front;
	var f = Font(g.fontName, 18);

	var popPreVols, pops, prePops, vols;
	var popMain, infPreKnob, zoomKnob;
	var nufoUV, popMode, mvVol;
	var nufoBut, nanoBut, gpadBut, uc4But;



	w.background_(Color.red(0.8, 0.8));
	g.mini.w = w;

	popPreVols = q.slots.actives.collect { |ndef, i|
		var pop, prePop, mvol;
		var mychoices = q.slots.choices[i];
		var myndef = q.slots.actives[i];
		var ndefpre = NdefPreset(myndef);

		pop = PopUpMenu(w, Rect(5, 60 + 2 * i + 5, 100, 30)).items_(mychoices)
		.value_(mychoices.indexOf(myndef.key))
		.font_(f)
		.action_({ |pop|
			q.slots.addActive(i, Ndef(pop.item));
		});

		prePop = PopUpMenu(w, Rect(5 + 100, 60 + 2 * i + 5, 100, 30))
		.items_(ndefpre.getSetNames).value_(ndefpre.currIndex)
		.action_({ |ppop|
			ndefpre.setCurr(ppop.item).setProxy(ppop.item);
			// dont step, just add influx offset
			q.pre.stepNdefInf(myndef, 0);

		})
		.font_(f);

		mvol = MView(ndef.vol, w, Rect(5, 60 + 2 * i + 5 + 30, 200, 30));
		mvol.dict.font_(f)
		.myspec_(\amp.asSpec);
		mvol.uv.resize_(1);

		mvol.value = myndef.vol;
		mvol.action.add(\set, { |mv|
			q.slots.actives[i].vol = mv.value.postln;
		});

		[pop, prePop, mvol]
	};

	#pops, prePops, vols = popPreVols.flop;
	g.mini.pops = pops;
	g.mini.prePops = prePops;
	g.mini.vols = vols;

	// MainFX:
	g.mini.mainPop = EZPopUpMenu(w, Rect(5, 280, 120, 30), "FX:",
		q.mfx.preNames,
		labelWidth: 40).font_(f);
	["<", "?", ">"].collect { |sign, i|
		Button(w, Rect(25 * i + 130, 280, 25, 30)).states_([[sign]]).font_(f);
	};

	g.mini.infpre = EZKnob(w, Rect(210, 5, 60, 80), \iPre, [0, 7, \lin, 1]).font_(f);
	g.mini.infpre.labelView.stringColor_(Color.white);

	g.mini.zoom = EZKnob(w, Rect(210 + 65, 5, 60, 80), \zoom, [0, 1]).font_(f);
	g.mini.zoom.labelView.stringColor_(Color.white);

	g.mini.uv = UserView(w, Rect(210, 90, 120, 130)).background_(Color.red(1, 0.7))
	.drawFunc_({ |u|
		4.do { |i|
			var shift = if (i.inclusivelyBetween(1, 2), 10, 0);
			Pen.addArc( (30 + shift) @ (i*32 + 15), 15, 0, 2pi);
			Pen.addArc( (90 - shift) @ (i*32 + 15), 15, 0, 2pi);
			Pen.fill;
			Pen.stringCenteredIn("NTMI-005", u.bounds.extent.asRect, f, Color.white)
		}
	});

	g.mini.modePop = EZPopUpMenu(w, Rect(210, 230, 120, 30), "mod",
		q.inph.modes, labelWidth: 36).font_(f);

	g.mini.mainVol = MView(1, w, Rect(210, 280, 120, 30)).label_(\mainvol);
	g.mini.mainVol.uv.resize_(1);
	g.mini.mainVol.dict.myspec_([0, 4, \amp].asSpec).font_(f);

	[\nufo, \nano, \gpad, \uc4].do { |name, i|
		var but = Button(w, Rect((i % 2) * 60 + 350, i div: 2 * 30 + 5, 60, 30)).states_([
			[ name, Color.black, Color.grey(0.7) ],
			[ name, Color.white, Color.green(0.8) ]
		]).font_(f);
		g.mini.put(name, but);
	};

	ServerMeterView(s, w, 350@60, 2, 2);

	Button(w, Rect(350, 280, 50, 30)).states_([["Butz"]]).font_(f);

	g.mini.skip.stop;
	g.mini.skip = SkipJack({
		// "miniskip...".postln;
		if (g.mini.w.notNil and: { g.mini.w.isClosed.not }) {
			MFdef(\miniGuiUpdate).value
		}
	}, 0.3, false, "mini");

	// RETURN WINDOW!
	g.mini.w;
});
