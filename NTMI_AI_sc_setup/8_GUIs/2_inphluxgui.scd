/*
ToDo :
- InfluxKtlGui could also show:
// config
--- outProcs? which ones?
--- outOffsets (per out)? name?

g.makeGui.inphlux;

include preset number and and inScaler in  SkipJack !

*/


g.makeGui.inphlux = { |dict, name = \inphlux|
	var bnds = Window.availableBounds;
	var size = 170;
	var size2 = size * 2;

	var w, e, f, insc, infComp;

	q.inph.ioWin = w = Window("inphluxInOut",
		Rect.aboutPoint(
			(bnds.width * 0.5) @ (bnds.height - size),
			size2,
			size);
	).front;
	q.inph.ioWin.background_(Color.grey(0.8));
	q.inph.ioWin.alpha_(0.8);

	infComp = CompositeView(w, (size2@size2) .asRect);
	infComp.bounds.postln;
	infComp.addFlowLayout;

	q.inph.ioUV = UserView(q.inph.ioWin,
		Rect(size2, 0, size2, size2)
	).resize_(5);
	q.inph.ioUV.background_(Color.grey(0.5));


	f = Font("Monaco", 13);
	StaticText(infComp, 330@20).string_("seeds:" + q.inph.randSeeds).align_(\center).font_(f);
	e = EZSlider(infComp, 330@20, \preset, [0, q.inph.randSeeds.lastIndex, \lin, 1], { |ez|
		q.inphlux.setwPre(q.inph.randSeeds[ez.value.asInteger]);
		q.inphlux.calcOutVals;
	}, q.inph.presIndex, labelWidth: 60, numberWidth: 30);
	e.font_(f);
	insc = EZSlider(infComp, 330@20, \inScaler, \zoom.asSpec, { |ez|
		q.setZoom(ez.value);
		ez.value_(q.zoom);
	}, q.inphlux.inScaler, labelWidth: 60, numberWidth: 40).font_(f);

	q.inph.ktlgui = InfluxKtlGui(q.inphlux, 5, infComp, Rect(0,0,300, 280));

	q.inph.ktlgui.nameView.bounds_(Rect(2.0, 2.0, 160, 20.0));
	q.inph.ktlgui.nameView.align_(\center);
	q.inph.ktlgui.name = "inphlux";
	g.tuneNameView(q.inph.ktlgui);

	q.inph.resetBut = Button(q.inph.ktlgui.zone, Rect(166, 2.0, 160, 20.0))
	.states_([['resetInvals', Color.white, Color.red]])
	.action_({ q.inphlux.resetInvals });

	q.inph.resetBut.bounds_(Rect(166, 2.0, 160, 20.0));
	// call this somewhere in skipjack, or when changes happen
	q.inph.updateGui = {
		q.ndefs.do { |ndef, i|
			// compare names of current q.ndefs with gui labels
			var but = g.inphGui.attachButtons[i];
			var key = ndef.key;
			var isOnValue = q.inphlux.action.activeNames.includes(key).binaryValue;
			if (but.states[0][0].asSymbol != key) {
				g.inphGui.attachToButton(i, ndef);
			};

			if (but.value != isOnValue) {
				but.value_(isOnValue)
			};
		};
	};

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
	);

	q.inph.ioWin;

};
