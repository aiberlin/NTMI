q.makeGui.inphlux = {
	q.inphGui = InfluxKtlGui(q.inphlux);
	q.inphGui.skipjack.dt = 1/10;

	// call this somewhere in skipjack, or when changes happen

	q.inph.updateGui = {
		q.ndefs.do { |ndef, i|
			// compare names of current q.ndefs with gui labels
			var but = q.inphGui.attachButtons[i];
			var key = ndef.key;
			var isOnValue = q.inphlux.action.activeNames.includes(key).binaryValue;
			if (but.states[0][0].asSymbol != key) {
				q.inphGui.attachToButton(i, ndef);
			};

			if (but.value != isOnValue) {
				but.value_(isOnValue)
			};
		};
	};
};

/*
q.inph.updateGui
*/

/*
q.inphWGui = InfluxIOWGui(q.inphlux, [9+8, 18]).moveTo(700, 20);
q.inphWGui.skipjack.dt = 1/20;
*/
