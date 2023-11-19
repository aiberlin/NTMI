
////// function to make a randomOrbitz KeyPlayerGui if needed

(
WinBounds.addMake('randomOrbitz', {

	NTMI.g.kpgui = KeyPlayerGui(KeyPlayer(\ro));
	NTMI.g.kpgui.parent.bounds_(NTMI.g.kpgui.parent.bounds.height_(300));

	///////// on separate window:
	//// NTMI.ro.uv = UserView().front.name_("rand");
	///////// on KeyPlayerGui window:
	NTMI.ro.uv = UserView(NTMI.g.kpgui.parent, Rect(0, 200, 420, 100));
	NTMI.ro.uv.background_(Color.grey(0.95));
	NTMI.ro.uv.drawFunc = { |uv|
		Pen.stringCenteredIn(NTMI.ro.str, (uv.bounds.extent * (1@0.5)).asRect, NTMI.ro.font);
		Pen.stringCenteredIn("rd:" + NTMI.ro.lastval, uv.bounds.extent.asRect, NTMI.ro.bigFont);
	};
	NTMI.g.kpgui.parent.name = "randomOrbitz";
	NTMI.g.kpgui.parent;
})
);
