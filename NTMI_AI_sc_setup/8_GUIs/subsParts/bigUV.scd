NTMI.g.main.bigUV.drawFunc.add(\circleFXName, { |uv|
	var center = uv.bounds.extent * 0.5;
	Pen.translate(center.x, center.y);
	Pen.addArc(0@0, center.y * 0.98, 0, 2pi);
	// shape:
	Pen.color_(Color.white);
	Pen.width = 3;
	Pen.stroke;


	if (NTMI.usesMainFX) {
		var fontScaler = uv.bounds.height / 900 * 1.618;
		var mainIndex = NTMI.mfx.domainIndex ? -1;
		var domainName = NTMI.mfx.preNames[mainIndex] ? "¿-?";
		"bigUV updating.".postln;

		Pen.rotate(mainIndex.linlin(-1, NTMI.mfx.preNames.size, 0.5pi, -0.5pi));
		Pen.scale(fontScaler, fontScaler);
		Pen.stringCenteredIn(domainName,
			Rect.aboutPoint(0@0, center.x, 40),
			NTMI.g.fontFat,
			Color.fromArray(NTMI.inph.currCounterCol).alpha_(0.4)
		);
	};
});

NTMI.g.main.bigUVUpdate = {
	defer {
		if (NTMI.usesMainFX) {
			NTMI.g.main.bigUV.refresh;
		};
	}
};

// only update if using mainFX
if (NTMI.usesMainFX) {
	MFdef('mainPre').add(\updateMain, { NTMI.g.main.bigUVUpdate });
}