// Sketch for miniature GUI for raspi-box screens:
// designed for small fixed size, 3.5 inch, 480x320 pixels.
//// still very incomplete!

/*
NTMI.skeys
NTMI.g.mini.skeys
WinBounds.showOrMake('miniNTMI');
NTMI.g.mini.guiUpdate.value;

*/

/* mini butz sketch:
Butz(\NTMI).remove('-Config-');
Butz(\NTMI).remove('-Tutorial-');
Butz(\NTMI).remove('-interfaces-');
Butz.style.font = Butz.style.font.size_(12);
Butz.numButz = 12;

Window.closeAll;
Butz.show;
*/

Butz(\NTMI).add('miniNTMI', { WinBounds.showOrMake('miniNTMI')});

NTMI.g.mini = NTMI.g.mini ? ();

NTMI.g.mini.guiUpdate = MFunc([\slots, {
	// "slots...".postln;
}]);


NTMI.g.mini.guiUpdate.add(\devices, {
	// show which MKtls are physically connected:
	// nufo, nanoK2, uc4, gamepad
	// devices found?".postln;
});

NTMI.g.mini.drawNufo = MFunc([\draw, {
	// draw pad values,
	// orientation star,
	// and network name on little uv in center
}]);


NTMI.g.mini.guiUpdate.add(\modeZoom, {

	var mini = NTMI.g.mini;
	var mainvol = MFdef(\mainVolGet).value.unbubble;

	if (mini.mainVol.value != mainvol) {
		mini.mainVol.value = mainvol
	};

	if (mini.mainPop.value != NTMI.mfx.domainIndex) {
		mini.mainPop.value = NTMI.mfx.domainIndex
	};

	// inphlux mode to color and mview labels and values

	if (mini.backCol != NTMI.inph.currPresetCol) {
		// "refresh win color.".postln;
		mini.backCol = NTMI.inph.currPresetCol;
		mini.w.background_(NTMI.inph.currPresetCol);
	};

	if (NTMI.inph.presIndex != mini.infpre.value) {
		mini.infpre.value = NTMI.inph.presIndex
	};
	// zoom
	if ( NTMI.zoom.absdif( mini.zoom.value) > 0.001 ) {
		mini.zoom.value = NTMI.zoom
	};
	// mode

	if (NTMI.inph.mode != mini.modePop.item) {
		mini.modePop.value = NTMI.inph.modes.indexOf(NTMI.inph.mode).postln;
	};
});

WinBounds.addMake(\miniNTMI, {

	var g = NTMI.g, mini = g.mini;
	var w = Window("miniNTMI", Rect(300, 300, 480, 320)).front;
	var f = Font(g.fontName, 18);

	var popPreVols, pops, prePops, vols;
	var popMain, infPreKnob, zoomKnob;
	var nufoUV, popMode, mvVol;
	var nufoBut, nanoBut, gpadBut, uc4But;



	w.background_(Color.red(0.8, 0.8));
	g.mini.w = w;

	popPreVols = NTMI.slots.actives.collect { |ndef, i|
		var pop, prePop, mvol;
		var mychoices = NTMI.slots.choices[i];
		var myndef = NTMI.slots.actives[i];
		var ndefpre = NdefPreset(myndef);

		pop = PopUpMenu(w, Rect(5, 60 + 2 * i + 5, 100, 30)).items_(mychoices)
		.value_(mychoices.indexOf(myndef.key))
		.font_(f)
		.action_({ |pop|
			NTMI.slots.addActive(i, Ndef(pop.item));
		});

		prePop = PopUpMenu(w, Rect(5 + 100, 60 + 2 * i + 5, 100, 30))
		.items_(ndefpre.getSetNames).value_(ndefpre.currIndex)
		.action_({ |ppop|
			ndefpre.setCurr(ppop.item).setProxy(ppop.item);
			// dont step, just add influx offset
			NTMI.pre.stepNdefInf(myndef, 0);

		})
		.font_(f);

		mvol = MView(ndef.vol, w, Rect(5, 60 + 2 * i + 5 + 30, 200, 30));
		mvol.dict.font_(f)
		.myspec_(\amp.asSpec);
		mvol.uv.resize_(1);

		mvol.value = myndef.vol;
		mvol.action.add(\set, { |mv|
			NTMI.slots.actives[i].vol = mv.value.postln;
		});

		[pop, prePop, mvol]
	};

	#pops, prePops, vols = popPreVols.flop;
	g.mini.pops = pops;
	g.mini.prePops = prePops;
	g.mini.vols = vols;

	// MainFX:
	g.mini.mainPop = EZPopUpMenu(w, Rect(5, 280, 120, 30), "FX:",
		NTMI.mfx.preNames,
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
		NTMI.inph.modes, labelWidth: 36).font_(f);

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
			g.mini.guiUpdate
		}
	}, 0.3, false, "mini");

	// RETURN WINDOW!
	g.mini.w;
});
