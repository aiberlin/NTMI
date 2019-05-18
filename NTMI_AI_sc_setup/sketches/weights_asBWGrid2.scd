(
w = Window("Influx").front;
w.layout = VLayout(
	HLayout(
		~utext = UserView().background_(Color.rand),
		~uouts = UserView().background_(Color.rand),
	),
	HLayout(
		~uins = UserView().background_(Color.rand),
		~uwg = UserView().background_(Color.rand),
	)
);

(
~utext .drawFunc = { |uv|
	var bounds = uv.bounds.moveTo(0,0);
	Pen.stringCenteredIn("2d Slider \ninterface here?", bounds);
};
/// right bottom: outvals
~uouts.drawFunc = { |uv|
	var bounds = uv.bounds.moveTo(0,0);
	var width = bounds.width, height = bounds.height;

	var influx = q.inphlux;
	var outNames = influx.outNames;
	var numCols = outNames.size;
	var font = Font("Monaco", width / numCols * 1.5);

	var colstep = bounds.width / numCols;
	var lineCol = Color.green(1, 0.8);
	var nameCol = Color.green(0.9, 0.8);

	// outvals as colors
	influx.outNames.do { |name, i|
		var rect = Rect(0 + (i * colstep), 0, colstep, height);
		Pen.addRect(rect);
		Pen.color = Color.grey(1 - influx.outValDict[name].biuni);
		Pen.fill;
		Pen.stringCenteredIn(name.asString, rect, font, nameCol);
	};
	/// right bottom: outvals as line

	influx.outNames.do { |name, i|
		var x = colstep * (i + 0.5);
		var y = influx.outValDict[name].biuni * height;
		if (i == 0) { Pen.moveTo(x@y) } { Pen.lineTo(x@y) };
	};
	Pen.color_(lineCol).width_(3).stroke;

	Pen.stringCenteredIn("OUTVALS", bounds.copy.top_(width * 0.25), font, Color.white);
};
);

~uins.drawFunc = { |uv|
	var bounds = uv.bounds.moveTo(0,0);
	Pen.stringCenteredIn("inputs here", uv.bounds.extent.asRect)
};
~uwg.drawFunc = { |uv|
	var bounds = uv.bounds.moveTo(0,0);
	Pen.stringCenteredIn("weights here", uv.bounds.extent.asRect)
};
);