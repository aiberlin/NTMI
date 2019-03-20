/*
**** sketch for influx weights gui:
left top: draw invals as grey horiz blocks and green line
right top: weights grid as grey squares
right bot: outvals as grey vert blocks and green line
left bot - what to put there?

Window.closeAll;
TODO:
split in 4 UserViews that rescale, keeping proportions as is
update inVals UV when invals change,
outvals when outvals change

// hm, cant bench graphics costs?
bench { u.refresh };

*/
(
u = UserView(nil, 300@300).name_("influx weight").front;
u.background_(Color.grey);
q.inphlux.inNames.do { |name| q.inphlux.set(name, 0.8.rand2) };

(
u.drawFunc = { arg uv;
	var inph = q.inphlux;
	var bounds = uv.bounds;
	var wid = bounds.width, hi = bounds.height;
	var lWid = wid * 0.38, rWid = wid * 0.62;
	var tHi = hi * 0.62, bHi = hi * 0.38;
	var numIns = inph.inNames.size;
	var numOuts = inph.outNames.size;

	var vstep = tHi / numIns;
	var hstep = lWid / numOuts;

	/// left TOP : draw invals
	inph.inNames.do { |name, i|
		Pen.addRect(Rect(0, vstep * i, lWid, vstep));
		Pen.color = Color.grey(inph.inValDict[name].biuni);
		Pen.fill;
	};
	//
	/// left TOP : draw invals
	inph.inNames.do { |name, i|
		var x = inph.inValDict[name].biuni * lWid;
		var y = vstep * (i + 0.5);
		if (i == 0) { Pen.moveTo(x@y) } { Pen.lineTo(x@y) };
	};
	Pen.color_(Color.green).width_(3).stroke;

	// right top: weights
	vstep = tHi / numIns;
	hstep = rWid / numOuts;
	q.inphlux.weights.do { |column, i|
		column.do { |val, j|
			Pen.color = Color.grey(val.biuni);
			Pen.addRect(Rect(lWid + (i * hstep), j * vstep, hstep, vstep)).fill;
		};
	};

	/// right bottom: outvals
	inph.outNames.do { |name, i|
		Pen.addRect(Rect(lWid + (i * hstep), tHi, hstep, bHi));
		Pen.color = Color.grey(inph.outValDict[name].biuni);
		Pen.fill;
	};
	/// right bottom: outvals
	inph.outNames.do { |name, i|
		var x = hstep * (i + 0.5) + lWid;
		var y = inph.outValDict[name].biuni * bHi + tHi;
		if (i == 0) { Pen.moveTo(x@y) } { Pen.lineTo(x@y) };
	};
	Pen.color_(Color.green).width_(3).stroke;

};
u.refresh;
Tdef(\x, { loop { u.refresh; 0.2.wait } }).clock_(AppClock).play;
)
)


