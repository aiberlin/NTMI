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

g.makeGui.inphluxInOut = {
	q.inph.ioWin = Window("inphluxInOut", {
		var bnds = Window.availableBounds;
		var size = bnds.width * 0.1;
		Rect.aboutPoint(
			(bnds.width * 0.5) @ (bnds.height - size),
			size, size)
	}.value;
	).front;
	q.inph.ioWin.background_(Color.grey(0.5));
	q.inph.ioWin.alpha_(0.9);


	q.inph.ioUV = UserView(q.inph.ioWin,
		q.inph.ioWin.view.bounds
	).resize_(5);

	(
		q.inph.ioUV.drawFunc = { arg uv;
			var inph = q.inphlux;
			var bounds = uv.bounds;
			var wid = bounds.width, hi = bounds.height;
			var lWid = wid * 0.38, rWid = wid * 0.62;
			var tHi = hi * 0.62, bHi = hi * 0.38;
			var numIns = inph.inNames.size;
			var numOuts = inph.outNames.size;

			var font = Font("Monaco", 16);
			var green1 = Color.green(1.0);
			var green2 = Color(0, 0.8, 0.2);

			var vstep = tHi / numIns;
			var hstep = lWid / numOuts;

			/// left TOP : draw invals
			inph.inNames.do { |name, i|
				var rect = Rect(0, vstep * i, lWid, vstep);
				Pen.addRect(rect);
				Pen.color = Color.grey(inph.inValDict[name].biuni);
				Pen.fill;
			};
			// write inNames
			inph.inNames.do { |name, i|
				var rect = Rect(0, vstep * i, lWid, vstep);
				Pen.stringCenteredIn(name.asString,
					rect.copy.width_(lWid * i.linlin(0, 17, 0.1, 1.9))
					.height_(vstep * 1.5)
					.top_(rect.top - (vstep * 0.25)),
					font, green2);
			};

			/// left TOP : draw invals line
			inph.inNames.do { |name, i|
				var x = inph.inValDict[name].biuni * lWid;
				var y = vstep * (i + 0.5);
				if (i == 0) { Pen.moveTo(x@y) } { Pen.lineTo(x@y) };
			};
			Pen.color_(green1).width_(3).stroke;

			// right top: weights
			vstep = tHi / numIns;
			hstep = rWid / numOuts;
			q.inphlux.weights.do { |column, i|
				column.do { |val, j|
					Pen.color = Color.grey(val.biuni);
					// Pen.color = Color.hsv(val.linlin(-1, 1, 0.6666, 0.9999), 1, 1);
					Pen.addRect(Rect(lWid + (i * hstep), j * vstep, hstep, vstep)).fill;
				};
			};

			/// right bottom: outvals as blocks
			vstep = bHi / numIns;
			hstep = rWid / numOuts ;
			inph.outNames.do { |name, i|
				var rect = Rect(lWid + (i * hstep), tHi, hstep, bHi);
				Pen.addRect(rect);
				Pen.color = Color.grey(1 - inph.outValDict[name].biuni);
				Pen.fill;
			};

			inph.outNames.do { |name, i|
				var rect = Rect(lWid + (i * 0.4 * hstep), tHi, hstep, bHi);
				Pen.stringCenteredIn(name.asString,
					rect.copy.width_(lWid * i.linlin(0, 17, 0.1, 1.9))
					.height_(vstep * 2)
					.top_(rect.top - (vstep * 0.5) + (vstep * 0.9 * i)),
					font, green2);
			};

			/// right bottom: outvals as line

			inph.outNames.do { |name, i|
				var x = hstep * (i + 0.5) + lWid;
				var y = inph.outValDict[name].biuni * bHi + tHi;
				if (i == 0) { Pen.moveTo(x@y) } { Pen.lineTo(x@y) };
			};
			Pen.color_(Color.green).width_(3).stroke;

			// Pen.stringCenteredIn(name.asString, rect, Font("MOnaco", 16), Color.green);
		};
		SkipJack({ q.inph.ioUV.refresh }, 0.2, { q.inph.ioWin.isClosed }, "inphIOW");
	)
};