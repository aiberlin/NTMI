
/*   // load all interfaces:
(thisProcess.nowExecutingPath.dirname +/+ "interfaces/" ++ "*.scd").loadPaths;

should respect usesMidi and usesHid flags

MFdef(\findConnect).();



*/
NTMI.prevFoundInfos = [];

(
NTMI.interfaces = NTMI.interfaces ? ();
NTMI.interfaces.loaded = NTMI.interfaces.loaded ? ();

NTMI.interfaces.knownFiles = (
	'nanoKONTROL2': "7_nanoKtl.scd",
	'Faderfox UC4': "2_uc4.scd",
	'Music Thing m0 Plus': "mu8.scd",

	'Run\'N\' Drive_Thrustmaster': "3_ferrari.scd",
	'Thrustmaster dual analog 3.2_Thrustmaster': "11_dual_analog_3.2.scd",
	'Thrustmaster dual analog 3.2_Mega World': "11_dual_analog_3.2.scd",
	'Thrustmaster dual analog 4_Mega World': "10_dual_analog_4.scd"
);

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
			newInfos = foundInfos.select { |info|
				(NTMI.prevFoundInfos ? []).includesEqual(info).not
			};
			"*** MFdef('findAndLoad') - new infos found:".postln;
			newInfos.postcs;

			newInfos.do { |entry|
				var found = NTMI.interfaces.knownFiles.at(entry.asSymbol);
				if (entry.notNil) { filenames.add(found.postln) };
				"found file % for interface %\n".postf(found, entry);
			};

			if (filenames.isEmpty and: MKtl.all.nanoKtl.isNil) {
				"loading as default: ".post;
				filenames.add("7_nanoKtl.scd".postcs);
			};

			filenames.do { |filename| try {
				var loadedMKtl = LoadMe(filename, NTMI.dir.setup +/+ "3_interfaces/optionals");
				if (loadedMKtl.notNil) {
					"loadedMKtl: %\n".postf(loadedMKtl);
					NTMI.interfaces.loaded.put(loadedMKtl.name, loadedMKtl);
				}
			} };
		}
	};

	NTMI.prevFoundInfos = foundInfos;
	// return loaded mktls:
	"*** NTMI.interfaces.loaded (MKtls): \n%\n".postf(NTMI.interfaces.loaded);

});
MFdef(\findConnect).();
)
