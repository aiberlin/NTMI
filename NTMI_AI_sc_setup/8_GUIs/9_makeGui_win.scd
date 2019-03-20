
// maybe put this in mainstage?

g.makeGui.z_CLOSEALL = {
	Window.allWindows.do { |w| if (w != g.utilWin) { try { w.close } } }
};

g.makeGui.a_makeGuiWin = {
	g.closeGuis("makeGui");
	g.makeGuiWin = Window("makeGuiWin",
		Rect(5,
			Window.screenBounds.height - (g.makeGui.size * 35) - 350,
			170, (g.makeGui.size * 35)
		)
	)
	.userCanClose_(false).alwaysOnTop_(true).background_(Color.red).front;
	g.makeGuiWin.addFlowLayout;

	g.makeGui.keys(SortedList).do { |key|
		Button(g.makeGuiWin, 160@30)
		.font_(Font("Monaco", 18))
		.states_([[key, Color.white, Color.grey(0.8, 0.4) ]]).action_ { g.makeGui[key.postcs].value }
	};
};
g.makeGui.a_makeGuiWin;
