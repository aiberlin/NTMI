// rescale stethoscope height

NTMI.g.scaleStetho = { |g, stetho, height = 200|
	var scopeV = stetho.scopeView;
	var cycleSl = stetho.view.children[5];
	var yzoomSl = stetho.view.children[6];
	scopeV.bounds = scopeV.bounds.height_(height);
	cycleSl.bounds = cycleSl.bounds.height_(height);
	yzoomSl.bounds = yzoomSl.bounds.top_( 30 + height);
};

// stetho needs to be in a new-style layout for resizing...
NTMI.g.main.stetho = Stethoscope(s, NTMI.numChans, view: NTMI.g.main.w.view);
// resize quick and dirty
defer ({
	NTMI.g.main.stetho.view.bounds_(Rect(130, 0.0, 250.0, 250.0));
	NTMI.g.scaleStetho(NTMI.g.main.stetho, 230 * NTMI.g.screenScale);

}, 0.1);