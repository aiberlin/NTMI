/*

Logic for loading polyphonic interfaces:
- find all present devices


- identify files to use for each present device
- run each file for each found device;
- if multiples, use separate names for multiples.
*** test that it works for multiples!

for individual devices:
running single file should also work.
how best to hand over name and idInfo?

// test loading all interfaces:
(thisProcess.nowExecutingPath.dirname +/+ "optionals/" ++ "*.scd").loadPaths;
-- nufo fails with device not found

should respect usesMidi and usesHid flags

NTMI.prevFoundInfos = nil;
MFdef(\findConnect).();

MKtlLookup.all.printAll;

*/

(
MKtl.all.postln;

NTMI.filesForFoundInfos = Dictionary[
	// midi
	"nanoKONTROL2" -> "nanoKtl.scd",
	"Faderfox UC4" -> "uc4.scd",
	"Music Thing 8mu" -> "mu8.scd",
	// hid
	"Run'N' Drive_Thrustmaster" -> "ferrari.scd",
	"Run'N' Drive Wireless_Thrustmaster" -> "ferrari.scd",
	"Thrustmaster dual analog 4_Thrustmaster" -> "dual_analog_4.scd",
	"Thrustmaster dual analog 3.2_Thrustmaster" -> "dual_analog_3.2.scd"
];

MFdef(\findConnect).add(\findConnect, {

	var foundInfos, newInfos;
	var protocols = List[];
	if (NTMI.usesHid) {
		Platform.case(\windows) {
			"HID on windows is not working in SC3.13.0.".warn
		} {
			protocols.add(\hid)
		}
	};
	if (NTMI.usesMidi) { protocols.add(\midi) };

	MKtl.find(protocols);

	foundInfos = MKtlLookup.allFor(protocols).asArray.collect(_.idInfo);

	case { foundInfos.isEmpty } {
		"no infos found - done.".postln;
	} { NTMI.prevFoundInfos == foundInfos } {
		"no new infos found - done.".postln;
	} {
		"*** MFdef('findConnect') - found new infos:".postln;
		newInfos = foundInfos.select { |info|
			(NTMI.prevFoundInfos ? []).includesEqual(info).not
		};
		newInfos.do { |info|
			var filename, mktlName;
			if (info.isKindOf(Dictionary)) {
				"\nmultiple found:".postln;
				info.postln;
				filename = NTMI.filesForFoundInfos[info.deviceName].postln;
				if (filename.notNil) {
					"...loading multi file:".postln;
					info.put(\multiIndex, info.destPortIndex ? info.srcPortIndex);
					info.put(\mktlName,
						"%_%".format(
							filename.splitext.first, info.at(\multiIndex)
						).asSymbol
					).postln;
					// hand info over to interface code file:
					NTMI.currInfo = info;
					LoadMe(filename, NTMI.dir.setup +/+ "3_interfaces/optionals");
					NTMI.currInfo = nil;
				};
			} {
				// info is a string
				"\nsingle found:".postln;
				info.postln;
				filename = NTMI.filesForFoundInfos[info].postln;
				if (filename.notNil) {
					"...loading single file...".postln;
					LoadMe(filename, NTMI.dir.setup +/+ "3_interfaces/optionals")
				};
			};
		};
	};

	NTMI.prevFoundInfos = foundInfos;
	newInfos
});
MFdef(\findConnect).();
)
