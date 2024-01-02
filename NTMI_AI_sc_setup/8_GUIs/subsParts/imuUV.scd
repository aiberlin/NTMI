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
*/

NTMI.nUFO.rawImuBiValues = 0.5 ! 9;
NTMI.nUFO.padVals = NTMI.nUFO.padVals ? 0!8;

NTMI.g.main.padCols = Color.grey(0.62, 0.38) !8;
NTMI.g.main.movevals = 0.5!9;


// possible fixes here:
// do basic geometry of locations only once rel to center,
// move to center, then scale,
// and only paint the ones that are needed.

// small UV in the middle for cheaper pads/axes drawing
NTMI.g.main.imuUVMFunc.add(\imuPad, { |uv|
	var main = NTMI.g.main;
	var myscale = Window.screenBounds.width / 1680;
	var bounds = uv.bounds.moveTo(0, 0);
	var center = bounds.center / myscale; // reverse scale
	var centPadsL, padsLPos, centPadsR, padsRPos;
	var star;

	Pen.scale(myscale, myscale);

	if ([\full, \touch, \binary].includes(NTMI.nUFO.mode)) {
		// draw pad circles
		centPadsL = center.copy.x_(center.x - (center.y * 1.8));
		centPadsR = center.copy.x_(center.x + (center.y * 1.8));
		padsLPos = [ -0.6, -0.2, 0.2, 0.6].collect { |angle|
			Polar(center.y * 1.5, angle * 0.8).asPoint + centPadsL;
		};

		padsRPos = [ 0.6, 0.2, -0.2, -0.6].collect { |angle|
			Polar(center.y * -1.5 + pi, angle * 0.8).asPoint + centPadsR;
		};

		Pen.width_(2);
		// 4 left, 4 right touchpads
		(padsLPos ++ padsRPos).collect { |pt, i|
			Pen.addArc(pt, 60, 0, 2pi);

			Pen.color_(main.padCols[i]);
			Pen.fill;
			// rings white
			Pen.addOval(Rect.aboutPoint(pt, 60, 60));
			Pen.color_(Color.white).stroke;
		};
	};

	// visualize move mode as star of 9;
	if ([\full, \move].includes(NTMI.nUFO.mode)) {
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


NTMI.g.main[\winUpdate].add(\imuPad, {
	var main = NTMI.g.main;

	if (NTMI.g.hasnUFO) {
		// only if values changed!
		if (NTMI.nUFO.rawImuBiValues != NTMI.nUFO.rawImuBiValuesOLD
			or: { NTMI.nUFO.padVals != NTMI.nUFO.padValsOLD }) {

			main.movevals = NTMI.nUFO.calibImuVals ? main.movevals;
			if (NTMI.nUFO.mode == \binary) {
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