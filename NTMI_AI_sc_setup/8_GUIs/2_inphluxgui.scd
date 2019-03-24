/*
ToDo :
- InfluxKtlGui - also show:
// dyn:
--- inVals, outvals
X inScaler
X preset number/name,
--- weights
// config
--- outProcs?
--- outOffsets (per out)? name?
-- fix:
--- numIns, numOuts => shape
*/

g.makeGui.inphluxWeights = {
	q.inph.iow = InfluxIOWGui(q.inphlux, q.inphlux.weights.shape.reverse).moveTo(700, 20);
	defer ({ q.inph.iow.parent.bounds_(Rect(700, 20, 400, 800)) }, 0.3);
};

g.makeGui.inphlux = {
	if (g.foundToFront("inphluxWeights").not) {

		var w, e, f, insc;

		w = Window("inphluxWeights", Rect(200, 200, 350, 350)).front;
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
	}
};

/*
q.inph.updateGui

*/

/*
q.inphWGui = InfluxIOWGui(q.inphlux, [9+8, 18])
q.inphWGui.skipjack.dt = 1/20;
*/
