//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// make 4 NdefGuis for them
// these show changes for all of them

(
q.ndgwin = Window("The 4 Ndefs", Rect(600, 0, 400, 800)).front;
q.ndgwin.addFlowLayout;
q.ndefGuis = q.ndefs.keep(4).collect { |px, i|
	var gui = NdefGui(px, 8, q.ndgwin);
	q.ndgwin.view.decorator.nextLine.shift(0, 10);
	gui.skipjack.dt = 0.03;
	gui;
};
q.ndgwin.bounds = q.ndgwin.bounds.moveTo(450, 500);
);