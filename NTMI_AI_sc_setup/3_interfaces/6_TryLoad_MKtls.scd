/*   // load all interfaces:
(thisProcess.nowExecutingPath.dirname +/+ "interfaces/" ++ "*.scd").loadPaths;


MFdef(\findConnect).();

*/

(
MFdef(\findConnect).add(\findConnect, {
	var foundInfos, newInfos, filenames = List[];

	"MFdef('findConnect'):\n"
	"- find present supported MKtl devices \n"
	"- and connect them.".postln;

	MKtl.find;
	foundInfos = MKtlLookup.all.asArray.collect(_.idInfo)
	.select(_.isString)
	.reject(_.contains("_Apple"))
	.reject(_ == "")
	.asArray.sort;

	("Found: " + foundInfos.cs).postln;

	if (NTMI.prevFoundInfos == foundInfos) {
		"no new infos - done.".postln;
	} {
		"*** MFdef('findAndLoad') - new infos found:".postln;
		newInfos = foundInfos.select { |info|
			(NTMI.prevFoundInfos ? []).includesEqual(info).not
		};
		newInfos.postcs;

		newInfos.do { |entry|
			if (entry == "nanoKONTROL2") { filenames.add("7_nanoKtl.scd") };
			if (entry == "Faderfox UC4") { filenames.add("2_uc4.scd") };
			if (entry == "Run'N' Drive_Thrustmaster" ) { filenames.add("3_ferrari.scd") };
		};

		if (filenames.isEmpty and: MKtl.all.nanoKtl.isNil) {
			"loading as default: ".post;
			filenames.add("7_nanoKtl.scd".postcs);
		};

		filenames.do { |filename| try {
			LoadMe(filename, NTMI.dir.setup +/+ "3_interfaces/optionals")
		} };
	};

	NTMI.prevFoundInfos = foundInfos;
	newInfos

});
MFdef(\findConnect).();
)
