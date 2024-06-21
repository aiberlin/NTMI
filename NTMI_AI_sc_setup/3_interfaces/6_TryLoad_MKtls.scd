
/*   // load all interfaces:
(thisProcess.nowExecutingPath.dirname +/+ "interfaces/" ++ "*.scd").loadPaths;

should respect usesMidi and usesHid flags

MFdef(\findConnect).();

*/

(

MFdef(\findConnect).add(\findConnect, {
	var foundInfos, newInfos, filenames = List[];
	var protocols = [\midi, \hid];
	if (NTMI.usesMidi.not) { protocols.remove(\midi) };
	if (NTMI.usesHid.not) { protocols.remove(\hid) };

	if(protocols.isEmpty) {
		"MFdef('findConnect'): - no protocols available. \n"
		" Please set NTMI.usesMidi or NTMI.usesHid to true.".postln;
	} {

		"MFdef('findConnect'):\n"
		"- find supported MKtl devices and connect them.".postln;

		MKtl.find(protocols);
		foundInfos = MKtlLookup.all.asArray.collect(_.idInfo)
		.select(_.isString)
		.reject(_.contains("_Apple"))
		.reject(_ == "")
		.asArray.sort;

		case { foundInfos.isEmpty } {
			"no infos found - done.".postln;
		} { NTMI.prevFoundInfos == foundInfos } {
			"no new infos - done.".postln;
		} {
			"*** MFdef('findAndLoad') - new infos found:".postln;
			newInfos = foundInfos.select { |info|
				(NTMI.prevFoundInfos ? []).includesEqual(info).not
			};
			newInfos.postcs;

			newInfos.do { |entry|
				if (entry == "nanoKONTROL2") { filenames.add("nanoKtl.scd") };
				if (entry == "Faderfox UC4") { filenames.add("uc4.scd") };
				if (entry == "Run'N' Drive_Thrustmaster" ) { filenames.add("ferrari.scd") };
			};

			if (filenames.isEmpty and: MKtl.all.nanoKtl.isNil) {
				"loading as default: ".post;
				filenames.add("7_nanoKtl.scd".postcs);
			};

			filenames.do { |filename| try {
				LoadMe(filename, NTMI.dir.setup +/+ "3_interfaces/optionals")
			} };
		}
	};

	NTMI.prevFoundInfos = foundInfos;
	newInfos

});
MFdef(\findConnect).();
)
