q.utilWin = Window("q.makeGui", Rect(0,0,200,300)).front.userCanClose_(false).alwaysOnTop_(true);
q.utilWin.addFlowLayout;
q.makeGui.keys(SortedList).do { |key|
	Button(q.utilWin, 190@30).states_([[key]]).action_ { q.makeGui[key.postcs].value }
};