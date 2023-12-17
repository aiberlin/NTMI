

/* flatcat visualization:


//// show flatcat viz on main GUI!
NTMI.g.main.imuUV.drawFunc = MFdef(\drawFlatcat);
NTMI.g.main.imuUV.animate_(true);

// or in its own window:
WinBounds.showOrMake(\flatcatViz);


//////////////
from tail to head,
motors are     2,  1,  0
segments are 3,  2,  1,  0
segments are 12, 6, 6, 10.5 long
joints are 2cm in from tailside
center of weight is in segment2, so keep segment2 flat
all segments are 2cm thick

// test different values
q.flatcat.vals.keysValuesDo { |k, v| q.flatcat.vals.put(k, 0) };  // flat stretch
q.flatcat.vals.keysValuesDo { |k, v| q.flatcat.vals.put(k, 0.33) };
q.flatcat.vals.keysValuesDo { |k, v| q.flatcat.vals.put(k, -0.25) };
q.flatcat.vals.keysValuesDo { |k, v| q.flatcat.vals.put(k, -0.5) }; // ouch

q.flatcat.vals.keysValuesDo { |k, v| q.flatcat.vals.put(k, 0.5.rand2) };

// slight variation:
q.flatcat.vals.keysValuesDo { |k, v|
q.flatcat.vals.put(k, (v + 0.05.rand2).clip2(0.5))
};


// -> let running flatcat set q.flatcat.vals!

// unsafe - this crashes GT gui in main thread on macOS

NTMI.g.main.imuUV.drawFunc = { MFdef(\drawFlatcat).value };
// NTMI.g.main.imuUV.animate_(true);

*/

(
q = q ? ();
q.flatcat = q.flatcat ? ();


// put values to show here:
q.flatcat.vals = (
	angle0: -0.3,
	angle1: 0.1,
	angle2: -0.2,
	curr0: -0.05,
	curr1: 0.3,
	curr2: 0.1
);

// assume flatcat is already running:
MFdef(\flatcat).add(\vizdata, {
	// get flatcat data from  for visualizer
	q.flatcat.vals.keysValuesDo { |k, v|
		q.flatcat.vals.put(k, MKtl(\flatcat).elAt(k).deviceValue);
	};
});

MFdef(\drawFlatcat).add(\draw,  {
	var colorLine = Color.black,
	colorBody = Color.grey(1.0, 0.5),
	colorUp = Color.red,
	colorDown = Color.blue;

	var joint1 = 0@0; // stays fixed and in center of image
	var joint2 = -60@0; // stays fixed, because seg2 stays horizontal
	var joint0 = -60@0; // moves

	var angle0 = q.flatcat.vals.angle0;
	var angle1 = q.flatcat.vals.angle1;
	var angle2 = q.flatcat.vals.angle2;

	var curr0 = q.flatcat.vals.curr0;
	var curr1 = q.flatcat.vals.curr1;
	var curr2 = q.flatcat.vals.curr2;

	// draw current force as ring segment + arrow
	var drawCurrent = { |curr=0|
		Pen.color = if (curr > 0, colorUp, colorDown);
		Pen.addAnnularWedge(0@0, 16, 20, pi, curr * 2pi);
		Pen.fill;
		// plus arrow tip triangle
		Pen.rotate(curr * 2pi + pi).translate(18, 0);
		Pen.moveTo(7@0).lineTo(-7@0).lineTo(0@ 10 * curr.sign).lineTo(7@0);
		Pen.fill;
	};

	// go to center = joint1 for segment2
	Pen.translate(210, 200);

	Pen.push;
	// draw joint 1 is in center
	Pen.addOval(Rect.aboutPoint(0@0, 5,5));

	// segment 2 is fixed:
	Pen.addRoundedRect(Rect(-80, -10, 60 - 5, 20), 5, 5);
	Pen.color = colorBody; Pen.fill;
	Pen.addRoundedRect(Rect(-80, -10, 60 + 30, 20), 5, 5);
	Pen.addRoundedRect(Rect(-80, -10, 60 - 5, 20), 5, 5);
	Pen.color = colorLine; Pen.stroke;
	drawCurrent.(curr1);
	Pen.pop;

	// tail segment - move to joint2
	Pen.push;
	Pen.translate(joint2.x, joint2.y);
	// tail segment 2 can rotate - 0.5 is 0.5pi:
	Pen.rotate(angle2 * pi);

	Pen.addRoundedRect(Rect(-120 - 20, -10, 120 - 5, 20), 5, 5);
	Pen.color = colorBody; Pen.fill;

	Pen.addOval(Rect.aboutPoint(0@0, 5,5)); // joint2
	Pen.addRoundedRect(Rect(-120 - 20, -10, 120 + 30, 20), 5, 5);
	Pen.addRoundedRect(Rect(-120 - 20, -10, 120 - 5, 20), 5, 5);
	Pen.color = colorLine; Pen.stroke;
	drawCurrent.(curr2);
	Pen.pop;
	//
	// upper mid segment1
	Pen.push;
	// Pen.translate(65, 0);
	// tail segment 2 can rotate - 0.5 is 0.5pi:
	Pen.rotate(angle1 * -pi);
	Pen.addRoundedRect(Rect(-20, -10, 60 - 5, 20), 5, 5);
	Pen.color = colorBody; Pen.fill;

	Pen.addOval(Rect.aboutPoint(0@0, 5,5));
	Pen.addRoundedRect(Rect(-20, -10, 60 + 30, 20), 5, 5);
	Pen.addRoundedRect(Rect(-20, -10, 60 - 5, 20), 5, 5);
	Pen.color = colorLine; Pen.stroke;

	// head segment0
	Pen.translate(60, 0);
	// tail segment 2 can rotate - 0.5 is 0.5pi:
	Pen.rotate(angle0 * -pi);
	Pen.addRoundedRect(Rect(-20, -10, 105 + 30, 20), 5, 5);
	Pen.color = colorBody; Pen.fill;

	Pen.addOval(Rect.aboutPoint(0@0, 5,5));
	Pen.addRoundedRect(Rect(-20, -10, 105 + 30, 20), 5, 5);
	Pen.color = colorLine;
	Pen.stroke;
	drawCurrent.(curr0);

});

WinBounds.addMake(\flatcatViz, {
	var w = Window("flatcatViz", 400@400).front;
	var u = UserView(w, 400@400);
	u.animate_(true);

	q.flatcat.w = w;
	q.flatcat.u = u;

	u.drawFunc = MFdef(\drawFlatcat);
	w
});
)