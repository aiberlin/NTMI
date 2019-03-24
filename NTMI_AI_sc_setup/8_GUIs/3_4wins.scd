//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// make 4 NdefGuis for them
// these show changes for all of them

g.makeGui.ndg4 = {
	if (g.foundToFront("The 4 Ndefs").not) {
		g.closeGui("The 4 Ndefs");
		g.ndgwin = Window("The 4 Ndefs", Rect(600, 0, 400, 800)).front;
		g.ndgwin.addFlowLayout;
		g.ndefGuis = q.ndefs.keep(4).collect { |px, i|
			var gui = NdefGui(px, 8, g.ndgwin);
			g.ndgwin.view.decorator.nextLine.shift(0, 10);
			gui.skipjack.dt = 0.03;
			gui;
		};
		g.ndgwin.bounds = g.ndgwin.bounds.moveTo(450, 500);
	}
};

