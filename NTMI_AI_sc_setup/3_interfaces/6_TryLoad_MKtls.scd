/*   // load all interfaces:
(thisProcess.nowExecutingPath.dirname +/+ "interfaces/" ++ "*.scd").loadPaths;
*/

(
var here = thisProcess.nowExecutingPath.dirname;
var foundInfos, fullpath;
var filenames = List[];

// MKtl.find(\midi);
foundInfos = MKtlLookup.all.asArray.collect(_.idInfo)
.select(_.isString)
.reject(_.contains("_Apple"))
.reject(_ == "")
.asArray.sort;

"look for presence of supported MKtl interfaces;
load them if found, or else load beatstep by default.".postln;

if (foundInfos.notEmpty) {
	"---\n*** Found % MKtl devices: %".postf(foundInfos.size);
	// foundInfos.printcsAll;
	"---".postln;
	foundInfos.do { |entry|
		if (entry == "nanoKONTROL2") { filenames.add("7_nanoktl.scd") };
		if (entry == "Faderfox UC4") { filenames.add("2_uc4.scd") };
		if (entry == "Run'N' Drive_Thrustmaster" ) {
			filenames.add("3_ferrari.scd") };
	};
};

if (filenames.isEmpty) {
	// use beatstep as default when nothing found:
	"... no supported MKtl device found, default to nanoKtl2.".postln;
	filenames.add("7_nanoktl.scd")
};

filenames.do { |filename| try {
	LoadMe(filename, here +/+ "optionals")
} };
)