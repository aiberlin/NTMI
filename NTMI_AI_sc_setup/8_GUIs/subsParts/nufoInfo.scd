var nufoView = UserView(NTMI.g.main.nufoInfoZone, NTMI.g.main.nufoInfoZone.bounds.moveTo(0, 0));
nufoView.background_(NTMI.g.butGrey);
NTMI.g.main.nufoView = nufoView;

nufoView.drawFunc_({ |uv|
	var bounds = uv.bounds.extent.asRect;
	Pen.addRect(bounds).color_(Color.white).stroke;
	Pen.addRect(bounds.copy.width_(bounds.width * (NTMI.bat.percent ? 0 * 0.01)));
	Pen.color_(Color.green(0.75, 0.8)).fill;
	Pen.stringCenteredIn(
		(NTMI.wifiStr ? "wifi ?")
		++ "\n" ++ (NTMI.frame.rateStr ? "nufo rate ?")
		++ "\n" ++ (NTMI.bat.string ? "nufo bat ?"),
		bounds,
		NTMI.g.font.copy.size_(NTMI.g.font.size * 0.8),
		Color.white
	);
	// "nufoView.drawFunc".postln;
});
