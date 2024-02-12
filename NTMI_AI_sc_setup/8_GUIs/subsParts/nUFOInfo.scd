var font = NTMI.g.font;
var nUFOZone = NTMI.g.main.nUFOZone;
var bounds = nUFOZone.bounds;
var hi = bounds.height;
var uvRect = bounds.extent.asRect.height_(hi * 0.5);
var caliRect = bounds.extent.asRect.top_(hi * 0.5).height_(hi * 0.3);
var n2iRect = bounds.extent.asRect.top_(hi * 0.8).height_(hi * 0.2);

var nUFOView = UserView(nUFOZone, uvRect)
.background_(NTMI.g.butGrey);
NTMI.g.main.nUFOView = nUFOView;

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

});

NTMI.g.main.caliBut = Button(nUFOZone, caliRect)
.states_([
	["CALIBRATE\ntouch + move?", Color.white, NTMI.g.butGrey],
	["CALIBRATING\ntouch + move", Color.black, Color.yellow(1.0, 0.8)],
	["touch + move\ncalibrated", Color.white, NTMI.g.butGrey],

]).font_(font)
.action_({ |but|
	but.value_(1);
	NTMI.nUFO.calibrate(1, { |ok| but.value_(if (ok, 2, 0)) })
});

(
NTMI.g.main.nUFO2InfBut = Button(nUFOZone, n2iRect)
.states_([
	["nUFO->influx is OFF", Color.black, NTMI.g.butGrey],
	["nUFO->influx is ON", Color.black, Color.green(0.7, 0.7)]
]).front.font_(Font(NTMI.g.fontName, NTMI.g.font.size * 0.7))
.value_(1)
.action_({ |bt|
	var funcs = [\imu, \caps].collect { |key|
		MKtl(\nUFO).device.oscFuncDictionary[key]
	};
	if (bt.value == 0) { funcs.do(_.disable) } { funcs.do(_.enable) };
	NTMI.g.main.nUFO2InfBut.value;
});
)
