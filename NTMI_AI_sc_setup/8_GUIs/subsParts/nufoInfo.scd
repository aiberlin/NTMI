var font = NTMI.g.font;
var nufoZone = NTMI.g.main.nufoZone;
var halfHeight = nufoZone.bounds.height * 0.5;
var butRect = nufoZone.bounds.extent.asRect.height_(halfHeight);

var nufoView = UserView(nufoZone, butRect)
.background_(NTMI.g.butGrey);
NTMI.g.main.nufoView = nufoView.postln;

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
		font,
		Color.white
	);
	// "nufoView.drawFunc".postln;
});

NTMI.g.main.caliBut = Button(nufoZone, butRect.top_(halfHeight))
.states_([
	["CALIBRATE\ntouch + move?", Color.white, NTMI.g.butGrey],
	["CALIBRATING\ntouch + move", Color.black, Color.yellow],
	["touch + move\ncalibrated", Color.white, NTMI.g.butGrey],

]).font_(font)
.action_({ |but|
	but.value_(1);
	NTMI.nufo.calibrate(1, { |ok| but.value_(if (ok, 2, 0).postln) })
});
