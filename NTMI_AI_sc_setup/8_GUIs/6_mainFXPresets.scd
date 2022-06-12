///// todo: move to ProxyChainPreset ...

g.makeGui.mainFX = {
	q.mfx.font = Font(g.fontName, 18);


	q.mfx.highKeys = [];
	q.mfx.srcKeys = q.mFX.slotNames;
	q.mfx.maxItems = (Window.availableBounds.height - 50 / 20).round.asInteger;

	try { q.mfx.win.close };
	q.mfx.win = Window('mainFX',
		Rect(0,0, 520, min(800, Window.availableBounds.height - 20));
		).front;
	q.mfx.win.addFlowLayout;

	// ////// ******* SKETCH FOR PXPRESETGUI *********
	// q.mfx.pcnum = EZNumber(q.mfx.win, Rect(0, 0, 100, 30), 'vfxChpre', [0, 99, \lin, 1], { |nb|
	// 	nb.value_(nb.value.asInteger.wrap(0, q.mfx.pcpop.items.size - 1));
	// 	q.mfx.pcpop.valueAction_(nb.value);
	// }, labelWidth: 60).font_(q.mfx.font);
	// q.mfx.pcnum.numberView.keyDownAction = { |nv, char|
	// 	if (char == $r) {
	// 		q.mfx.pcpop.valueAction_(q.mfx.pcpop.items.size.rand);
	// 	}
	// };
	//
	// q.mfx.pcpop = EZPopUpMenu(q.mfx.win, Rect(0, 0, 200, 30), \, [\a, \b, \c], { |ezp|
	// 	q.mfx.pcnum.value_(ezp.value);
	// 	"not working yet ... ".post; ezp.item.postcs;
	// }, labelWidth: 5).font_(q.mfx.font);
	//
	// q.mfx.storeBut = Button(q.mfx.win, Rect(0,0,60,30))
	// .states_([["STO"]]).font_(q.mfx.font)
	// .action_({ "store by name - dialog ... ".postln; });
	// q.mfx.delBut = Button(q.mfx.win, Rect(0,0,60,30))
	// .states_([["DEL"]]).font_(q.mfx.font)
	// .action_({ "deleting by name - select view ... ".postln; });
	// ////// ******* SKETCH FOR PXPRESETGUI *********

	q.mfx.prepop = EZPopUpMenu(q.mfx.win, Rect(0,0, 320, 30), \mainPresetz, q.mfx.preNames, { |ezp|
		MFdef(\mainPre).(ezp.item);
	}, labelWidth: 120);
	q.mfx.prepop.font_(q.mfx.font);

	[ "¿x?", "prev", "next" ].collect { |label, i|
		Button(q.mfx.win, Rect(0,0,50,30))
		.states_([[label]]).font_(q.mfx.font)
		.action_({
			MFdef(\mainPreStep).([nil, -1, 1]@i)
		});
	};


	// q.mfx.slotPrePop = EZPopUpMenu(q.mfx.win, Rect(0, 0, 100, 30), \, q.mFX.slotNames.array, { |ezp|
	// 	var newpre = q.mfx.pxPres[ezp.item];
	// 	q.mfx.pxPreGui.object = newpre;
	// 	q.mfx.setHighKeys(ProxyChain.atSrcDict(ezp.item).paramNames);
	// }, labelWidth: 5); // .font_(q.mfx.font);
	//
	// q.mfx.pxPreGui = NdefPresetGui(parent: q.mfx.win);
	//
	// q.mfx.slotPrePop.valueAction_(11);
	//
	q.mfx.mgui = q.mfx.chain.gui(
			min(q.mfx.maxItems, 50),
			parent: q.mfx.win);
	q.mfx.win.bounds_(q.mfx.win.bounds.moveTo(790, 1200));
	q.mfx.win.alpha_(0.85);

	q.tuneNameView(q.mfx.mgui.editGui);

	// not fully working yet - needs to be triggered
	q.mfx.setHighKeys = { |dict, highKeys|
		q.mfx.highKeys = highKeys;
		q.mfx.mgui.editGui.paramGui.paramViews.do { |pv|
			if (highKeys.includes(pv.label)) {
				pv.background_(Color.green(0.8))
			} {
				pv.background_(Color.new255(204, 216, 178, 127))
			}
		}
	};

	q.mfx.skippa = SkipJack({
		if (q.mfx.prepop.item != q.mfx.currDomain) {
			q.mfx.prepop.value = q.mfx.domainIndex
		};
		q.mFX.proxyChain.proxy.cleanNodeMap;
	}, 0.5, { q.mfx.win.isClosed });

};

