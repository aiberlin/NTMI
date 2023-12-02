if (NTMI.g.main.fxZone.isNil or: {
	NTMI.g.main.fxZone.isClosed }) {
	var w = Window("mainFXBut", Rect(0, 0, 394.0, 79.0)).front;
	NTMI.g.main.fxZone = w.view;
};

NTMI.g.main.mfxBut = Button(
	NTMI.g.main.fxZone,
	NTMI.g.main.fxZone.bounds.extent
).states_([
	["MainFX\n<<  RAND  >>", Color.white, NTMI.g.butGrey],
]).font_(NTMI.g.font)

.mouseDownAction_({ |bt, x, y, mod|
	var zone = x div: (bt.bounds.width div: 3);
	var stepVal = [-1, nil, 1][zone];
	MFdef('mainPreStep').value(stepVal);
	// [bt, x, y, mod].postcs;
});
