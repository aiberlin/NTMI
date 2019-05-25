
var requiredQuarks, installedQuarks, missingQuarks;

"".postln;

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
	// standalone app versions should have all quarks installed ...
};
