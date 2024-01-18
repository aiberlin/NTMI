/*
// tests for display when changing imu/pad values:
NTMI.nUFO.padVals = { 1.0.rand } ! 8;
NTMI.nUFO.padVals = 1.0.rand ! 8;
NTMI.nUFO.padVals = 0 ! 8;

NTMI.nUFO.rawImuBiValues = { 1.0.rand } ! 9;
NTMI.nUFO.calibImuVals = NTMI.nUFO.rawImuBiValues;

NTMI.nUFO.rawImuBiValues = 0.5 ! 9;
NTMI.nUFO.calibImuVals = NTMI.nUFO.rawImuBiValues;

NTMI.nUFO.rawImuBiValues = 1 ! 9;
NTMI.nUFO.calibImuVals = NTMI.nUFO.rawImuBiValues;

NTMI.g.main.movevals = 0.25!9;


NTMI.g.main.imuUV = UserView(nil, 666@666).front;
NTMI.g.main.imuUV.drawFunc = NTMI.g.main.imuUVMFunc;


nUFO pad dimensions:
area outerpads: w: 12.5, h: 9.5
area innerpads: w: 9.3, h: 4.9
pad diameter: 2.2
(12.5 - 1.1) / 12.5; // 0.91 padLeft, R
9.3 - 1.1 / 12.5; // 0.66, padML, R
9.5 - 1.1 / 9.5; // padTop Bot
4.9 1.1 / 9.5; // padMTop Bot
2.2 / 12.5
2.2 / 9.5
*/

NTMI.nUFO.rawImuBiValues = 0.5 ! 9;
NTMI.nUFO.padVals = NTMI.nUFO.padVals ? 0!8;

NTMI.g.main.padCols = Color.grey(0.62, 0.38) !8;
NTMI.g.main.movevals = 0.5!9;


// geometry is for fixed size of 666,
// whole drawFunc scales once.

(
// small UV in the middle for cheaper pads/axes drawing
NTMI.g.main.imuUVMFunc.add(\imuPad, { |uv|
	var main = NTMI.g.main;
	var width = 666, height = 666;
	var bounds = Rect(0,0,width, height);
	var center = bounds.center;

	var myscaleW = uv.bounds.width / 666;
	var myscaleH = uv.bounds.height / 666;

	var padCenters, toCenter = 0.05;
	var padLeft = width * (0.095 + toCenter), padRight = width * (0.895 - toCenter);
	var padMLeft = width * (0.2 + toCenter), padMRight = width * (0.8 - toCenter);
	var padTop = height * 0.15, padBot = height * 0.85;
	var padMTop = height * 0.37, padMBot = height * 0.63;
	var padSize = min(width * 0.088, height * 0.115) * 1.2;

	var star;

	// "uvbounds: % center: %, scaleW: %, myscaleH: % \n"
	// .postf(bounds, center, myscaleW.round(0.001), myscaleH.round(0.001));

	Pen.scale(myscaleW, myscaleH);

	if ([\full, \touch, \binary, \binMove, \off].includes(NTMI.nUFO.mode)) {
		padCenters = [
			// left side - top, midtop,  midbottom, bottom
			padLeft@padTop, padMLeft@padMTop, padMLeft@padMBot, padLeft@padBot,
			// right side, same
			padRight@padTop, padMRight@padMTop, padMRight@padMBot, padRight@padBot
		];

		Pen.width_(2);
		// 4 left, 4 right touchpads
		padCenters.collect { |pt, i|
			Pen.addArc(pt, padSize, 0, 2pi);
			Pen.color_(main.padCols[i]);
			Pen.fill;

			// rings white
			Pen.addOval(Rect.aboutPoint(pt, padSize, padSize));
			Pen.color_(Color.white).stroke;
		};
	};

	// visualize move mode as star of 9;
	if ([\full, \move, \binMove].includes(NTMI.nUFO.mode)) {
		// "move mode vis".postln;
		star = main.movevals.collect { |val, i|
			// offset -1.25 means noseDown is lowest star axis
			Polar(val.linlin( 0, 1, 40, 240), i -1.25 / -9 * 2pi).asPoint + center;
		};			// star.postln;
		Pen.color = Color.yellow; Pen.width = 3;
		star.wrapExtend(10).doAdjacentPairs { |p1, p2| Pen.line(p1, p2); };
		Pen.stroke;
		star.do { |p1| Pen.line(p1, center); };
		Pen.color = Color.white; Pen.width = 1.5;
		Pen.stroke;
	};
});

// NTMI.g.main.imuUV.refresh;
);

NTMI.g.main[\winUpdate].add(\imuPad, {
	var main = NTMI.g.main;

	if (NTMI.g.hasnUFO) {
		// only if values changed!
		if (NTMI.nUFO.rawImuBiValues != NTMI.nUFO.rawImuBiValuesOLD
			or: { NTMI.nUFO.padVals != NTMI.nUFO.padValsOLD }) {

			main.movevals = NTMI.nUFO.calibImuVals ? main.movevals;
			if ([\binary, \binMove].includes(NTMI.nUFO.mode)) {
				main.padCols = NTMI.bin.bins.collect { |val, i|
					Color.white.alpha_(val);
				};
			} {
				main.padCols = NTMI.nUFO.padVals.collect { |val, i|
					// now opposite Color.hsv
					Color.fromArray(NTMI.inph.currCounterCol * val);
					// was always yellow
					// Color.yellow(val).alpha_(val);
				};
			};
			main.imuUV.refresh;
		};
		NTMI.nUFO.rawImuBiValuesOLD = NTMI.nUFO.rawImuBiValues;
		NTMI.nUFO.padValsOLD = NTMI.nUFO.padVals;
	};
});