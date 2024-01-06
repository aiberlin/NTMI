var font = NTMI.g.font;
var nUFOZone = NTMI.g.main.nUFOZone;
var halfHeight = nUFOZone.bounds.height * 0.5;
var butRect = nUFOZone.bounds.extent.asRect.height_(halfHeight);

var nUFOView = UserView(nUFOZone, butRect)
.background_(NTMI.g.butGrey);
NTMI.g.main.nUFOView = nUFOView.postln;

nUFOView.drawFunc_({ |uv|
	var bounds = uv.bounds.extent.asRect;
	Pen.addRect(bounds).color_(Color.white).stroke;
	Pen.addRect(bounds.copy.width_(bounds.width * (NTMI.nUFO.bat.percent ? 0 * 0.01)));
	Pen.color_(Color.green(0.75, 0.8)).fill;
	Pen.stringCenteredIn(
		(NTMI.wifiStr ? "wifi ?")
		++ "\n" ++ (NTMI.nUFO.frame.rateStr ? "nUFO rate ?")
		++ "\n" ++ (NTMI.nUFO.bat.string ? "nUFO bat ?"),
		bounds,
		font,
		Color.white
	);
	// "nUFOView.drawFunc".postln;
});

NTMI.g.main.caliBut = Button(nUFOZone, butRect.top_(halfHeight))
.states_([
	["CALIBRATE\ntouch + move?", Color.white, NTMI.g.butGrey],
	["CALIBRATING\ntouch + move", Color.black, Color.yellow],
	["touch + move\ncalibrated", Color.white, NTMI.g.butGrey],

]).font_(font)
.action_({ |but|
	but.value_(1);
	NTMI.nUFO.calibrate(1, { |ok| but.value_(if (ok, 2, 0).postln) })
});
