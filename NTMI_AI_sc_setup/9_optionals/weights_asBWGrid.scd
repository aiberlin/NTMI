x = UserView(nil, 300@300).name_("influx weight").front;
x.drawFunc = { |uv|
	var bounds = uv.bounds;
	var vstep = bounds.width / q.inphlux.weights.size;
	var hstep = bounds.height / q.inphlux.inNames.size;
	q.inphlux.weights.do { |line, i|
		line.do { |val, j|
			Pen.color = Color.grey(val.biuni);
			Pen.addRect(Rect(i * vstep, j * hstep, vstep, hstep)).fill;
		};
	};
};