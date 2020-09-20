
////// function to make a randomOrbitz KeyPlayerGui if needed

(
g.makeGui.randomOrbitz = { |dict, name = \allPresets|

	KeyPlayer.gui.object_(KeyPlayer(\ro));
	KeyPlayer.gui.parent.bounds_(KeyPlayer.gui.parent.bounds.height_(300));

	///////// on separate window:
	//// q.ro.uv = UserView().front.name_("rand");
	///////// on KeyPlayerGui window:
	q.ro.uv = UserView(KeyPlayer.gui.parent, Rect(0, 200, 420, 100));
	q.ro.uv.background_(Color.grey(0.95));
	q.ro.uv.drawFunc = { |uv|
		Pen.stringCenteredIn(q.ro.str, (uv.bounds.extent * (1@0.5)).asRect, q.ro.font);
		Pen.stringCenteredIn("rd:" + q.ro.lastval, uv.bounds.extent.asRect, q.ro.bigFont);
	};
	KeyPlayer.gui.parent.name = "randomOrbitz";
	KeyPlayer.gui.parent;
}
);
