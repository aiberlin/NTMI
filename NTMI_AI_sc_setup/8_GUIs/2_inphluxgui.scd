/*
ToDo :
- InfluxKtlGui could also show:
// config
--- outProcs? which ones?
--- outOffsets (per out)? name?

g.makeGui.inphlux;

include preset number and and inScaler in  SkipJack !

*/

var q, g;
NTMI.g = NTMI.g ? (); // global dict
q = NTMI.q;
g = NTMI.g;

WinBounds.addMake('inphlux', { |dict, name = \inphlux|
	var bnds = g.bounds;
	var size = 170;
	var size2 = size * 2;

	var w, presl, insc, font, fontbig, infComp;

	font = Font(g.fontName, 13);
	fontbig = Font(g.fontName, 16);

	q.inph.ioWin = w = Window("inphlux",
		Rect.aboutPoint(
			(bnds.width * 0.5) @ (bnds.height - size),
			size2,
			size);
	).front;
	q.inph.ioWin.background_(Color.grey(0.8));
	q.inph.ioWin.alpha_(0.8);

	infComp = CompositeView(w, (size2@size2) .asRect);
	// infComp.bounds.postln;
	infComp.resize_(4);
	infComp.addFlowLayout;

	q.inph.ioUV = UserView(q.inph.ioWin,
		Rect(size2, 0, size2, size2)
	).resize_(5);
	q.inph.ioUV.background_(Color.grey(0.5));




	StaticText(infComp, 330@20).string_("seeds:" + q.inph.randSeeds).align_(\center).font_(font);
	presl = EZSlider(infComp, 330@20, \preset, [0, q.inph.randSeeds.lastIndex, \lin, 1], { |ez|
		NTMI.inph.setWPreIndex(ez.value.asInteger);
		q.inphlux.calcOutVals;
	}, q.inph.presIndex, labelWidth: 60, numberWidth: 30);
	presl.font_(font);

	insc = EZSlider(infComp, 330@20, \inScaler, \zoom.asSpec, { |ez|
		q.setZoom(ez.value);
		ez.value_(q.zoom);
	}, q.inphlux.inScaler, labelWidth: 60, numberWidth: 40).font_(font);

	q.inph.ktlgui = InfluxKtlGui(q.inphlux, 5, infComp, Rect(0,0,300, 280));
	// hide attachButtons:
	q.inph.ktlgui.attachButtons[0].parent.children.drop(5).do(_.visible_(false));

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
					fontbig, green2);
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
				Pen.color = Color.grey(inph.outValDict[name].biuni);
				Pen.fill;
			};

			inph.outNames.do { |name, i|
				var rect = Rect(lWid + (i * 0.4 * hstep), tHi, hstep, bHi);
				Pen.stringCenteredIn(name.asString,
					rect.copy.width_(lWid * i.linlin(0, 17, 0.1, 1.9))
					.height_(vstep * 2)
					.top_(rect.top - (vstep * 0.5) + (vstep * 0.9 * i)),
					fontbig, green2);
			};

			/// left bottom: info text

			Pen.stringCenteredIn(
				"click to post,\n"
				"click-drag\n"
				"to set inputs",
				Rect(0, tHi, lWid, bHi),
				Font(Font.defaultMonoFace, 14 * wid / 340),
				Color.white
			);

			/// right bottom: outvals as line

			inph.outNames.do { |name, i|
				var x = hstep * (i + 0.5) + lWid;
				var y = hi - (inph.outValDict[name].biuni * bHi);
				if (i == 0) { Pen.moveTo(x@y) } { Pen.lineTo(x@y) };
			};
			Pen.color_(Color.green).width_(3).stroke;

		};
		SkipJack({
			q.inph.ioUV.refresh;
			presl.value = NTMI.inph.presIndex;
			insc.value = NTMI.inphlux.inScaler;
		}, 0.2, { q.inph.ioWin.isClosed }, "inphIOW");
	);

	(
		MFdef(\infMouse).add(\base, { |uv, x, y, mod=0|
			////// three possible actions:
			////// 1. on inputs, post input name and value,
			////// 1+ if shift, move = drag value
			////// 2. on weights, post weight indices and value
			////// 3. on outs, post name, index, value
			var uvbounds = uv.bounds;
			var uvW = uvbounds.width, uvH = uvbounds.height;
			var isUp = y <= (uvH * 0.62);
			var isLeft = x <= (uvW * 0.38);
			var indexY, indexX;
			// "isUp % isLeft %\n".postf(isUp, isLeft);

			if (isUp) {
				indexY = (y / (uvH * 0.62) * q.inphlux.inNames.size).asInteger;
				if (isLeft) {
					var newval;
					var inName = q.inphlux.inNames.clipAt(indexY);
					if (NTMI.inph.canSet) {
						newval = (x / (uvW * 0.38)).unibi;
						"influx in '%' -> %\n".postf(inName, newval.round(0.0001));
						q.inphlux.set(inName, newval);
					} {
						"influx in % '%' : %\n".postf(indexY, inName,
							q.inphlux.inValDict[inName].round(0.0001));

						NTMI.inph.canSet = true;
					};
				} {
					indexX = (x - (uvW * 0.38) / (uvW * 0.62)
						* q.inphlux.inNames.size).asInteger;
					"influx weight [%][%]: %\n".postf(
						indexX, indexY, q.inphlux.weights[indexX][indexY].round(0.0001));
				}
			} {
				if (isLeft.not) {
					var outName;
					indexX = (x - (uvW * 0.38) / (uvW * 0.62)
						* q.inphlux.inNames.size).asInteger;
					outName = q.inphlux.outNames.clipAt(indexX);
					"influx out % '%' : %\n".postf(indexX, outName,
						q.inphlux.outValDict[outName].round(0.0001)
					)

				};
			}
		});
		NTMI.inph.canSet = false;
		q.inph.ioUV.mouseDownAction = MFdef(\infMouse);
		q.inph.ioUV.mouseMoveAction = MFdef(\infMouse);
		q.inph.ioUV.mouseUpAction = { NTMI.inph.canSet = false };
	);

	q.inph.ioWin;

});
