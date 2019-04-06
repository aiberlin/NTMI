/*
ToDo :
- InfluxKtlGui - also show:
// dyn:
--- inVals, outvals
X inScaler?
X preset number/name,
--- weights
// config
--- outProcs? which ones?
--- outOffsets (per out)? name?
-- fix:
--- numIns, numOuts => shape
*/

g.makeGui.inphluxWeights = { |dict, name = \inphluxWeights|
	q.inph.iow = InfluxIOWGui(q.inphlux, q.inphlux.weights.shape.reverse).moveTo(700, 20);
	q.inph.iow.parent.name_(name);
	defer ({ q.inph.iow.parent.bounds_(Rect(700, 20, 400, 960)) }, 0.3);
	q.inph.iow.inValsGui.orderedNames = q.inphlux.inNames;
	q.inph.iow.outValsGui.orderedNames = q.inphlux.outNames;
};

g.makeGui.inphlux = { |dict, name = \inphlux|

	var w, e, f, insc;

	w = Window(name, Rect(200, 200, 350, 350)).front;
	w.view.addFlowLayout;

	f = Font("Monaco", 13);
	StaticText(w, 330@24).string_("seeds:" + q.inph.randSeeds).align_(\center).font_(f);
	e = EZSlider(w, 330@30, \preset, [0, q.inph.randSeeds.lastIndex, \lin, 1], { |ez|
		q.inphlux.setwPre(q.inph.randSeeds[ez.value.asInteger]);
		q.inphlux.calcOutVals;
	}, q.inph.presIndex, labelWidth: 60, numberWidth: 30);
	e.font_(f);
	insc = EZSlider(w, 330@30, \inScaler, [0.05, 1, \lin, 0.05], { |ez|
		q.setZoom(ez.value);
		ez.value_(q.zoom);
	}, labelWidth: 60, numberWidth: 40).font_(f);

	q.inph.ktlgui = InfluxKtlGui(q.inphlux, 5, w, Rect(0,0,300, 280));

	// call this somewhere in skipjack, or when changes happen
	q.inph.updateGui = {
		q.ndefs.do { |ndef, i|
			// compare names of current q.ndefs with gui labels
			var but = g.inphGui.attachButtons[i];
			var key = ndef.key;
			var isOnValue = q.inphlux.action.activeNames.includes(key).binaryValue;
			if (but.states[0][0].asSymbol != key) {
				g.inphGui.attachToButton(i, ndef);
			};

			if (but.value != isOnValue) {
				but.value_(isOnValue)
			};
		};
	};
};
