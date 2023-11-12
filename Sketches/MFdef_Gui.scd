MFdef(\mainWinUpdate).activeNames;

MFdef(\mainWinUpdate).enable(\imuPad);

(
~mfgui = { |mf|
	var w = Window(mf.cs, Rect(100, 100, 300, 200)).front;
	var modebuts, funcbuts;
	var updateFuncbuts = {
		funcbuts.do { |but, i|
			but.value = mf.activeNames.postln.includes(but.states[0][0].asSymbol)
		};
	};
	w.view.layout = HLayout(
		VLayout(
			StaticText(w).string_("modes"),
			*modebuts = mf.modes.keys(Array).sort.collect { |modeName|
				Button(w).states_([[ modeName ], [modeName, Color.white, Color.red]])
				.action_({ |bt|
					mf.mode = modeName;
					mf.activeNames.postcs;
					updateFuncbuts.value;
				})
			}
		),
		VLayout(
			StaticText(w).string_("funcs"),
			*funcbuts = mf.orderedNames.collect {|funcName|
				Button(w).states_([[ funcName ], [funcName, Color.white, Color.red]])
				.action_({ |bt|
					if (bt.value > 0) {
						mf.enable(funcName)
					} {
						mf.disable(funcName)
					};
					mf.activeNames.postcs;
				})
			}
		)
	);
	updateFuncbuts.value;
};
~mfgui.value(MFdef(\mainWinUpdate));
)