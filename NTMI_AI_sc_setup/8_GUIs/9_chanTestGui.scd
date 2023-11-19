

NTMI.g.makeGui.chanTest = {

	q.chantest.win = Window("chanTest").front;
	q.chantest.win.addFlowLayout;

	Button(q.chantest.win, Rect(0,0,120,30)).states_([["STOP"]])
	.action_({
		q.chantest.pink.end;
		q.chantest.task.stop;

	});
	q.chantest.butz = (1..8).collect { |i|
		Button(q.chantest.win, Rect(0,0,30,30)).states_([[i], [i, Color.black, Color.green]])
		.action_({ q.chantest.pink.play(i - 1) });
	};

	q.chantest.taskgui = TdefGui(q.chantest.task, 4, q.chantest.win);
	q.chantest.taskgui.name = "looptest";

	q.chantest.pinkgui = NdefGui(q.chantest.pink, 4, q.chantest.win);
	q.chantest.pinkgui.name_("PINK");
	q.chantest.win
};
