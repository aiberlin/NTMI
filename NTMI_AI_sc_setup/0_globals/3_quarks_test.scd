
var requiredQuarks, installedQuarks, missingQuarks;

"loading quarks test: ".postln;

if (Platform.userAppSupportDir.endsWith("SuperCollider")) {
	requiredQuarks = [
		"JITLibExtensions",
		"adclib",
		"Influx",
		// "KtlLoop",
		"Modality-toolkit",
		// "MultiTouchPad",
		// "Standalone",
		"Vowel",
		"PaneView",
		// "TabbedView", "TabbedView2_QT", "TabbedView2"
	].collect(_.asSymbol);

	installedQuarks = Quarks.installed.collect { |qu| qu.name.asSymbol };

	missingQuarks = requiredQuarks.difference(installedQuarks);
	if (missingQuarks.notEmpty) {
		"*** NTMI project folder cannot load - install missing quarks first: ".post;
		missingQuarks.postcs;
		"*** STOPPING HERE!".postln;
		this.halt;
	};

	"... all needed quarks present HERE!".postln;

} {
	// standalone app should have all quarks installed ...
};
