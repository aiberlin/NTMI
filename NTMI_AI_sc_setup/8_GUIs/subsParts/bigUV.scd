NTMI.g.main.bigUV.drawFunc.add(\circleFXName, { |uv|
	var center = uv.bounds.extent * 0.5;
	Pen.translate(center.x, center.y);
	Pen.addArc(0@0, center.y * 0.98, 0, 2pi);
	// shape:
	Pen.color_(Color.white);
	Pen.width = 3;
	Pen.stroke;

	if (NTMI.usesMainFX) {
		var mainIndex = NTMI.mfx.domainIndex;
		var domainName = NTMI.mfx.preNames[mainIndex];
		"bigUV updating.".postln;

		Pen.rotate(mainIndex.linlin(-1, NTMI.mfx.preNames.size, 0.5pi, -0.5pi));
		Pen.scale(1.618, 1.618);
		Pen.stringCenteredIn(domainName,
			Rect.aboutPoint(0@0, center.x, 40),
			NTMI.g.fatfont,
			Color.grey(1.0, 0.3)
		);
	};
});

// only update if using mainFX
if (NTMI.usesMainFX) {
	MFdef('mainPreStep').add(\updateMain, {
		defer {
			if (NTMI.usesMainFX) {
				NTMI.g.main.bigUV.refresh;
			};
		}
	});
}