g.makeGui.masterFX = {
	q.vfx.font = Font("Optima", 18);

	q.vfx.highKeys = [];
	q.vfx.srcKeys = q.mFX.slotNames;

	try { q.vfx.win.close };
	q.vfx.win = Window('masterFX', Rect(0,0, 520, 800)).front;
	q.vfx.win.addFlowLayout;

	////// ******* SKETCH FOR PXPRESETGUI *********
	q.vfx.pcnum = EZNumber(q.vfx.win, Rect(0, 0, 100, 30), 'vfxChpre', [0, 99, \lin, 1], { |nb|
		nb.value_(nb.value.asInteger.wrap(0, q.vfx.pcpop.items.size - 1));
		q.vfx.pcpop.valueAction_(nb.value);
	}, labelWidth: 60).font_(q.vfx.font);
	q.vfx.pcnum.numberView.keyDownAction = { |nv, char|
		if (char == $r) {
			q.vfx.pcpop.valueAction_(q.vfx.pcpop.items.size.rand);
		}
	};

	q.vfx.pcpop = EZPopUpMenu(q.vfx.win, Rect(0, 0, 200, 30), \, [\a, \b, \c], { |ezp|
		q.vfx.pcnum.value_(ezp.value);
		"not working yet ... ".post; ezp.item.postcs;
	}, labelWidth: 5).font_(q.vfx.font);

	q.vfx.storeBut = Button(q.vfx.win, Rect(0,0,60,30))
	.states_([["STO"]]).font_(q.vfx.font)
	.action_({ "store by name - dialog ... ".postln; });
	q.vfx.delBut = Button(q.vfx.win, Rect(0,0,60,30))
	.states_([["DEL"]]).font_(q.vfx.font)
	.action_({ "deleting by name - select view ... ".postln; });
	////// ******* SKETCH FOR PXPRESETGUI *********


	q.vfx.prepop = EZPopUpMenu(q.vfx.win, Rect(0,0, 350, 30), \mastaPresetz, q.vfx.preNames, { |ezp|
		MFdef(\mastaPre).(ezp.item);
	}, labelWidth: 140);
	q.vfx.prepop.font_(q.vfx.font);


	Button(q.vfx.win, Rect(0,0,60,30))
	.states_([["¿x?"]]).font_(q.vfx.font)
	.action_({
		q.vfx.prepop.value_(q.vfx.prepop.items.size.rand);
	});

	q.vfx.slotPrePop = EZPopUpMenu(q.vfx.win, Rect(0, 0, 100, 30), \, q.mFX.slotNames.array, { |ezp|
		var newpre = q.vfx.pxPres[ezp.item];
		q.vfx.pxPreGui.object = newpre;
		q.vfx.setHighKeys(ProxyChain.atSrcDict(ezp.item).paramNames);
	}, labelWidth: 5); // .font_(q.vfx.font);

	q.vfx.pxPreGui = NdefPresetGui(parent: q.vfx.win);

	q.vfx.slotPrePop.valueAction_(11);
	//
	q.vfx.mgui = q.vfxCh.gui(50, parent: q.vfx.win);
	q.vfx.win.bounds_(q.vfx.win.bounds.moveTo(790, 1200));
	q.vfx.win.alpha_(0.85);

	// not fully working yet - needs to be triggered
	q.vfx.setHighKeys = { |dict, highKeys|
		q.vfx.highKeys = highKeys;
		q.vfx.mgui.editGui.paramGui.paramViews.do { |pv|
			if (highKeys.includes(pv.label)) {
				pv.background_(Color.green(0.8))
			} {
				pv.background_(Color.new255(204, 216, 178, 127))
			}
		}
	};
};