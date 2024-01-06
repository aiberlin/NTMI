/*
Test main window for multiple screen sizes, e.g.:
Tdef(\guiTest).getHalo(\allExtents)

remaining problem:
in 4/3 ratio, the pads are very wide
and the mviews not wide enough

// test all these in a row:
Tdef(\guiTest).set(\winExtent, nil).play;

// test individual ones
Tdef(\guiTest).set(\winExtent, (1920@1080)).play;

Tdef(\guiTest).set(\winExtent, (1512@944)).play;

Tdef(\guiTest).set(\winExtent, (1280@800)).play;

Tdef(\guiTest).set(\winExtent, (1024@768)).play;

Tdef(\guiTest).set(\winExtent, (800@480)).play;

Tdef(\guiTest).set(\winExtent, (640@480)).play;

Tdef(\guiTest).set(\winExtent, (480@320)).play;

// see layout in the abstract, no subviews
(
NTMI.g.main.skipper.stop;
NTMI.g.main.w.view.children.do { |c| c.children.do(_.remove) };
NTMI.g.main.w.view.children.do(_.background_(Color.rand));
)
Butz.curr_(\interfaces).show
*/

Tdef(\guiTest).addHalo(\allExtents, [
	(1920@1080), (1512@944), (1280@800), (1280@720),
	(1024@768), (800@480), (640@480), (480@320)
]);

Tdef(\guiTest).addHalo(\allExtents, [
	(1920@1080), (1512@944), (1280@800), (1280@720),
	(1024@768), (800@480), (640@480), (480@320)
]);

Tdef(\guiTest).getHalo(\allExtents).do { |ext|
	(ext.x / ext.y).asFraction(5).postln;
};


Tdef(\guiTest).addHalo(\makeGui, {
	Tdef(\guiTest).gui(2).parent.moveTo(0,0).alwaysOnTop_(true)
});

Tdef(\guiTest, { |env|

	(env.winExtent ? Tdef(\guiTest).getHalo(\allExtents)).do { |winExtent|
		var winName = "Main_NTMI at: %x%".format(*winExtent.asArray).postcs;
		Window.closeAll;
		Tdef(\guiTest).getHalo.makeGui;

		NTMI.g.clear;
		NTMI.g.bounds = winExtent.asRect;
		LoadMe("8_GUIs/*scd", NTMI.dir.setup);
		// NTMI.g.printInterface("NTMI.g.");
		NTMI.g.sortedKeysValuesDo { |k, v| [k,v].postln }; "";

		Butz.show;
		Butz(\NTMI).run(\Main_NTMI);
		Window.find(\Main_NTMI).name_(winName);
		3.wait;
	};
	"Tdef(\\guiTest) done.".postln;
}).clock_(AppClock);
