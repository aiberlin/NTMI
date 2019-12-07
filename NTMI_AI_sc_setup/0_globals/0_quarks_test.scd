
var requiredQuarks, installedQuarks, missingQuarks;

"".postln;

if (Platform.userAppSupportDir.endsWith("SuperCollider")) {
	requiredQuarks = [
		"JITLibExtensions",
		"adclib",
		"Influx",
		"KtlLoop",
		"KeyPlayer",
		"Modality-toolkit",
		"Vowel",
		// "MultiTouchPad", // macOS only
		// "Standalone",    // in Standalones only
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
	// standalone app versions should have all quarks installed -
	[
	//	[ \Plinkyplonk, "NopeyDopey" ], /// test
		[ \NdefPreset, "JITLibExtensions" ],
		[ \MFdef,      "adclib" ],
		[ \Influx,         "Influx" ],
		[ \KtlLoop,        "KtlLoop" ],
		[ \MKtl,           "Modality-toolkit" ],
		[ \Vowel,          "Vowel" ],
	].do { |pair|
		if (pair[0].asClass.isNil) {
			"*** Quark '%' seems to be missing! \n please install it somehow ... *** \n\n".postf(pair[1])
		}
	};
}
