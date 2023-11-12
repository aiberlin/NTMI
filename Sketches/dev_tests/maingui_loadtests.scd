w = Window("test", Window.availableBounds).front;
u = UserView(w, Rect(100, 100, 450, 550)).front;

q.inph.mode = \full;

x.stop;
x = SkipJack({ u.refresh }, 0.04);
x.dump

u.drawFunc = { |uv|
	var bounds = uv.bounds.moveTo(0,0);
	var center = bounds.center;
	var centPadsL, padsLPos, centPadsR, padsRPos;
	var star;

	if ([\full, \touch].includes(q.inph.mode)) {
		centPadsL = center.copy.x_(center.x - (center.y * 1.8));
		centPadsR = center.copy.x_(center.x + (center.y * 1.8));
		padsLPos = [ -0.6, -0.2, 0.2, 0.6].collect { |angle|
			Polar(center.y * 1.5, angle * 0.8).asPoint + centPadsL;
		};

		padsRPos = [ 0.6, 0.2, -0.2, -0.6].collect { |angle|
			Polar(center.y * -1.5 + pi, angle * 0.8).asPoint + centPadsR;
		};

		// 4 left, 4 right touchpads
		(padsLPos ++ padsRPos).collect { |pt, i|
			Pen.addArc(pt, 60, 0, 2pi);
			Pen.color_(g.main.padCols[i]);
			Pen.fill;
			// Pen.stringCenteredIn(i.asString, Rect.aboutPoint(pt, 60, 60),
			// 	font: Font(Font.defaultMonoFace, 96),
			// color: Color.black);
		};
	};

	// visualize move mode as star of 9;
	if ([\full, \move].includes(q.inph.mode)) {
		// "move mode vis".postln;
		star = g.main.movevals.collect { |val, i|
			Polar(val.linlin( 0, 1, 40, 240), i / 9 * 2pi).asPoint + center;
		};
		// star.postln;
		Pen.color = Color.yellow; Pen.width = 3;
		star.wrapExtend(10).doAdjacentPairs { |p1, p2| Pen.line(p1, p2); };
		Pen.stroke;
		star.do { |p1| Pen.line(p1, center); };
		Pen.color = Color.white; Pen.width = 1.5;
		Pen.stroke;
	};

};
