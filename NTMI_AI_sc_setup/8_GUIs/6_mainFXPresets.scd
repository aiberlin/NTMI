///// todo: move completely to ProxyChainPreset ...


WinBounds.addMake(\mainFX, {
	NTMI.mfx.font = Font(NTMI.g.fontName, 18);

	NTMI.mfx.highKeys = [];
	NTMI.mfx.srcKeys = NTMI.mFX.slotNames;
	NTMI.mfx.maxItems = (Window.availableBounds.height - 50 / 20).round.asInteger;

	try { NTMI.mfx.win.close };
	NTMI.mfx.win = Window('mainFX',
		Rect(0,0, 520, min(800, Window.availableBounds.height - 20));
		).front;
	NTMI.mfx.win.addFlowLayout;

	// ////// ******* SKETCH FOR PXPRESETGUI *********
	// NTMI.mfx.pcnum = EZNumber(NTMI.mfx.win, Rect(0, 0, 100, 30), 'vfxChpre', [0, 99, \lin, 1], { |nb|
	// 	nb.value_(nb.value.asInteger.wrap(0, NTMI.mfx.pcpop.items.size - 1));
	// 	NTMI.mfx.pcpop.valueAction_(nb.value);
	// }, labelWidth: 60).font_(NTMI.mfx.font);
	// NTMI.mfx.pcnum.numberView.keyDownAction = { |nv, char|
	// 	if (char == $r) {
	// 		NTMI.mfx.pcpop.valueAction_(NTMI.mfx.pcpop.items.size.rand);
	// 	}
	// };
	//
	// NTMI.mfx.pcpop = EZPopUpMenu(NTMI.mfx.win, Rect(0, 0, 200, 30), \, [\a, \b, \c], { |ezp|
	// 	NTMI.mfx.pcnum.value_(ezp.value);
	// 	"not working yet ... ".post; ezp.item.postcs;
	// }, labelWidth: 5).font_(NTMI.mfx.font);
	//
	// NTMI.mfx.storeBut = Button(NTMI.mfx.win, Rect(0,0,60,30))
	// .states_([["STO"]]).font_(NTMI.mfx.font)
	// .action_({ "store by name - dialog ... ".postln; });
	// NTMI.mfx.delBut = Button(NTMI.mfx.win, Rect(0,0,60,30))
	// .states_([["DEL"]]).font_(NTMI.mfx.font)
	// .action_({ "deleting by name - select view ... ".postln; });
	// ////// ******* SKETCH FOR PXPRESETGUI *********

	NTMI.mfx.prepop = EZPopUpMenu(NTMI.mfx.win, Rect(0,0, 320, 30), \mainPresetz, NTMI.mfx.preNames, { |ezp|
		MFdef(\mainPre).(ezp.item);
	}, labelWidth: 120);
	NTMI.mfx.prepop.font_(NTMI.mfx.font);

	[ "¿x?", "prev", "next" ].collect { |label, i|
		Button(NTMI.mfx.win, Rect(0,0,50,30))
		.states_([[label]]).font_(NTMI.mfx.font)
		.action_({
			MFdef(\mainPreStep).([nil, -1, 1]@i)
		});
	};


	// NTMI.mfx.slotPrePop = EZPopUpMenu(NTMI.mfx.win, Rect(0, 0, 100, 30), \, NTMI.mFX.slotNames.array, { |ezp|
	// 	var newpre = NTMI.mfx.pxPres[ezp.item];
	// 	NTMI.mfx.pxPreGui.object = newpre;
	// 	NTMI.mfx.setHighKeys(ProxyChain.atSrcDict(ezp.item).paramNames);
	// }, labelWidth: 5); // .font_(NTMI.mfx.font);
	//
	// NTMI.mfx.pxPreGui = NdefPresetGui(parent: NTMI.mfx.win);
	//
	// NTMI.mfx.slotPrePop.valueAction_(11);
	//
	NTMI.mfx.mgui = NTMI.mfx.chain.gui(
			min(NTMI.mfx.maxItems, 50),
			parent: NTMI.mfx.win);
	NTMI.mfx.win.bounds_(NTMI.mfx.win.bounds.moveTo(790, 1200));
	NTMI.mfx.win.alpha_(0.85);

	NTMI.tuneNameView(NTMI.mfx.mgui.editGui);

	// not fully working yet - needs to be triggered
	NTMI.mfx.setHighKeys = { |dict, highKeys|
		NTMI.mfx.highKeys = highKeys;
		NTMI.mfx.mgui.editGui.paramGui.paramViews.do { |pv|
			if (highKeys.includes(pv.label)) {
				pv.background_(Color.green(0.8))
			} {
				pv.background_(Color.new255(204, 216, 178, 127))
			}
		}
	};

	NTMI.mfx.skippa = SkipJack({
		if (NTMI.mfx.prepop.item != NTMI.mfx.currDomain) {
			NTMI.mfx.prepop.value = NTMI.mfx.domainIndex
		};
		NTMI.mFX.proxyChain.proxy.cleanNodeMap;
	}, 0.5, { NTMI.mfx.win.isClosed });

	NTMI.mfx.win;
});

