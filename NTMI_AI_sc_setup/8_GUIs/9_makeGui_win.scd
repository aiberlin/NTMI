var numButs = q.makeGui.size;

q.utilWin = Window("q.makeGui",
	Rect(5, Window.screenBounds.height - (numButs * 35) - 350, 170, 350)
).front.userCanClose_(false).alwaysOnTop_(true);
q.utilWin.addFlowLayout;
q.makeGui.keys(SortedList).do { |key|
	Button(q.utilWin, 160@30).states_([[key]]).action_ { q.makeGui[key.postcs].value }
};
