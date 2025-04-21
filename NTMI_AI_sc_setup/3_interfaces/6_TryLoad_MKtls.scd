/*

Logic for loading polyphonic interfaces:

- find all present devices for the protocols to be used

- identify files to use for each present device
- if NTMI.connectFoundInterfaces:
-- run each file for each found device;
-- if multiples, use separate names for multiples.
-> also for ferrari wired/wireless!
*** test that it works for multiples!

For single devices:
running single file should also work.
Handover is by shortterm global variable:
NTMI.currInfo = info;
LoadMe(filename, NTMI.dir.setup +/+ "3_interfaces/optionals");
NTMI.currInfo = nil;

// test loading all interfaces:
(thisProcess.nowExecutingPath.dirname +/+ "optionals/" ++ "*.scd").loadPaths;


// unify interface loading functions:
// 1 - load a specific interface file with a given name
// 2 - make a showOrMake func if not there yet
// make findConnect optional
// 3 - findConnect: check which files match with present devices
// identify if singles or

NTMI.prevFoundInfos = nil;
MFdef(\findConnect).();

MKtlLookup.all.printAll;

NTMI.interfacesToLoad = ["ferrari", "nUFO"];
NTMI.run;

*/

NTMI.interfaces = NTMI.interfaces ? ();

NTMI.findOptionals = {
	NTMI.optionals = (NTMI.dir.setup +/+ "3_interfaces/optionals/""*.scd").pathMatch;
	"\n\n*** Found % optional interface files: ".postf(NTMI.optionals.size);
	NTMI.optionalNames = NTMI.optionals.collect {|p| p.basename.splitext[0].asSymbol };
	NTMI.optionalNames.printcsAll;
	"\n\n".postln;
};

NTMI.findOptionals;

// to be used for selecting interface files by protocol
NTMI.allInterfaceNames = (
	\osc: [
		"nUFO",
		"flatcat"
	],
	\midi: [
		// midi
		"nanoKtl",
		"xtm",
		"uc4",
		"mu8",
		"en16",
	],

	\hid: [
		"dual_ana_32",
		"dual_ana_4",
		"ferrari",
		"shbobo_shnth"
	],
	\other: [
		"kraken", // serial
		"webMouse" // gui/osc
	],
);

(
// function to load one interface via its file(s):
NTMI.tryLoadMKtl = { |dict, name, filepath, reload = false|
	name = name.asSymbol;
	filepath = filepath ? "3_interfaces/optionals/%.scd".format(name);
	if (LoadMe.isRelative(filepath)) {
		filepath = (NTMI.dir.setup +/+ filepath);
	};
	if (MKtl.all[name].isNil or: reload) {
		MKtl.all[name].free;
		"trying LoadMe(filepath);".postln;
		try { LoadMe(filepath) } {
			"*** NTMI.tryLoadMKtl FAILED! \n"
			"name: %, filepath: % \n".postf(name.cs, filepath.cs);
		};
	};
	if (MKtl.all[name].notNil) {
		NTMI.interfaces.put(name, MKtl.all[name])
	};
};

NTMI.makeMKtl = { |q, defaultName, descName, currInfo, makeHalo=true|
	// support multiple identical interfaces as passed in from TryLoad:
	if (currInfo.notNil) {
		var mktlName = NTMI.currInfo.mktlName;
		var multiIndex = NTMI.currInfo.multiIndex;
		("NTMI.currInfo: " + NTMI.currInfo.cs).postln;
		MKtl.all[mktlName].free;
		// clear currInfo, because we used it
		NTMI.currInfo = nil;
		// and make the multiple
		m = MKtl(mktlName, descName, false, multiIndex: multiIndex);
	} {
		// just one single interface, real or virtual:
		// no need for NTMI.currInfo, just use default name.
		m = MKtl(defaultName, descName);
	};
	m;
	if (m.getHalo.isNil and: makeHalo) {
		NTMI.makeMKtlHalo(m);
	};
};

Spec.add(\xZoom, [0, 4, \amp]);

NTMI.baseMKtlHalo = (
	influxMode: \setRel,
	zoom: 1,
	setRel: { |halo|
		halo[\influxMode] = \setRel;
		"% influxMode: %\n".postf(halo.mktl, halo[\influxMode]);
	},
	setAbs: { |halo|
		halo[\influxMode] = \setAbs;
		"% influxMode: %\n".postf(halo.mktl, halo[\influxMode]);
	}
);

NTMI.makeMKtlHalo = { |q, mk|
	var halo;
	if (mk.notNil) {
		if (mk.getHalo.isNil) {
			mk.addHalo(\zoom, 1);
		};
		halo = mk.getHalo;
		halo.mktl = mk;
		// use proto for defaults and overwrite in MKtl halos:
		halo.proto = NTMI.baseMKtlHalo;
		NTMI.q[mk.name] = halo;
	};
	mk
};


/*
NTMI.tryLoadMKtl("ferrari");
NTMI.tryLoadMKtl("nanoKtl");
*/

"NTMI.interfacesToLoad: %\n\n".postf(NTMI.interfacesToLoad);
NTMI.interfacesToLoad.do { |name| NTMI.tryLoadMKtl(name) };

NTMI.interfacesToShow = NTMI.interfacesToShow ? NTMI.optionalNames;

NTMI.filesForFoundInfos = Dictionary[
	// midi
	"nanoKONTROL2" -> "nanoKtl",
	"Faderfox UC4" -> "uc4",
	"Music Thing 8mu" -> "mu8",
	"intech-grid" -> "en16",
	"X-TOUCH MINI" -> "xtm",
	// hid
	"SHNTH_SHBOBO" -> "shbobo_shnth",
	"Run'N' Drive_Thrustmaster" -> "ferrari",
	"Run'N' Drive Wireless_Thrustmaster" -> "ferrari",
	"Thrustmaster dual analog 4_Mega World" -> "dual_analog_4",
	"Thrustmaster dual analog 3_2_Thrustmaster" -> "dual_analog_3_2",
	"Thrustmaster dual analog 4_Thrustmaster" -> "dual_analog_4",
	"Thrustmaster dual analog 3_2_Mega World" -> "dual_analog_3_2",
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
		newInfos.do { |info, i|
			var filename, mktlName;
			if (info.isKindOf(Dictionary)) {
				"\*** Multiples found:".postln;
				info.postcs;
				filename = NTMI.filesForFoundInfos[info.deviceName];
				"finename: %\n".postf(filename);
				if (filename.notNil) {
					"...loading multi file:".postln;
					info.put(\multiIndex, info.destPortIndex ? info.srcPortIndex);
					mktlName = filename.splitext.first;
					// not working yet: first of several mktls
					// should be e.g. 'uc4', not 'uc4_0'.
					// if (i > 0) {
					mktlName = "%_%".format(mktlName, info.at(\multiIndex));
					// };
					info.put(\mktlName, mktlName.asSymbol).postcs;

					// hand info over to interface code file:
					NTMI.currInfo = info;
					NTMI.tryLoadMKtl(filename);
					NTMI.currInfo = nil;
				};
			} {

				filename = NTMI.filesForFoundInfos[info];
				if (filename.notNil) {
					// info is just a string
					"\nsupported single found:".postln;
					NTMI.currInfo = (
						deviceName: info,
						descFileName: MKtlDesc.filenamesForIDInfo(info);
					).postcs;

					"...loading single file...".postln;
					NTMI.tryLoadMKtl(filename);
				};
				NTMI.currInfo = nil;
			};
		};
	};

	// NTMI.prevFoundInfos = foundInfos;
	newInfos
});
if (NTMI.connectFoundInterfaces) {
	MFdef(\findConnect).();
};
);
