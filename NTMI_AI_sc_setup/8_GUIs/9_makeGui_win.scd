/// maybe put this in mainstage?

var numButs = g.makeGui.size;

g.utilWin = Window("q.makeGui",
	Rect(5, Window.screenBounds.height - (numButs * 35) - 350, 170, 350)
).userCanClose_(false).alwaysOnTop_(true).front;
g.utilWin.addFlowLayout;
g.makeGui.keys(SortedList).do { |key|
	Button(g.utilWin, 160@30).states_([[key]]).action_ { g.makeGui[key.postcs].value }
};
