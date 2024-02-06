// rescale stethoscope height

var stethoBounds = NTMI.g.main.stethoBounds;

// stetho needs to be in a new-style layout for resizing...
try { NTMI.g.main.stetho.view.remove };
NTMI.g.main.stetho = Stethoscope(s, NTMI.numChans, view: NTMI.g.main.w.view);

// only rescales height, leaves topLine alone
NTMI.g.scaleStetho = { |g, stetho, height = 230|
	var scopeV = stetho.scopeView;
	var yzoomSl  = stetho.view.children[5];
	var cycleSl = stetho.view.children[6];
	var deltaHeight = (cycleSl.bounds.bottom - height);
	scopeV.bounds = scopeV.bounds.height_(scopeV.bounds.height - deltaHeight);
	cycleSl.bounds = cycleSl.bounds.top_(cycleSl.bounds.top - deltaHeight);
	yzoomSl.bounds = yzoomSl.bounds.height_(height - 30 - 20);
};

// resize quick and dirty
defer ({
	NTMI.g.main.stetho.view.bounds_(stethoBounds);
	NTMI.g.scaleStetho(NTMI.g.main.stetho, stethoBounds.height - 4);

}, 0.1);

