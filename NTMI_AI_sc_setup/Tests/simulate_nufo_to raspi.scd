/*
////// f0s trick to free 57120 by force if necessary:
Platform.case(
	\linux, {
		unixCmd("kill -9" + ("fuser -n udp 57120 | awk '{print $1}'").unixCmdGetStdOut.asInteger);
	}, {  //osx and windows
		unixCmd("kill -9" + ("lsof -ti :57120").unixCmdGetStdOut.asInteger);
	}
);

// get broadcast address
"ifconfig".unixCmdGetStdOut.findRegexp("(?=(?<=broadcast )|(?<=Bcast:))(?:[0-9]{1,3}[.]){3}[0-9]{1,3}")[0][1];
// get my own IP
"ifconfig".unixCmdGetStdOut.findRegexp("(?:[0-9]{1,3}[.]){3}[0-9]{1,3}(?=(?=.{10,30}broadcast )|(?=.{1,10}Bcast:))")[0][1];

///// get my network name - macOS only
/// need to know which device is active, then ask:
"networksetup -getairportnetwork en0".unixCmdGetStdOut.split($:).last.drop(1).drop(-1).cs;
network sends alive message, with network SSID/name;

*/


~mb18_hyper5 = NetAddr("192.168.8.169", NetAddr.langPort);

~raspi_hyper5 = NetAddr("192.168.8.175", 57120);

~raspi_hyper5.sendMsg(\hello, "are you listening?"); // works

MKtl('ntmi').device.oscFuncDictionary.keys(Array).sort.cs;
// [ 'battery', 'bt_1', 'bt_2', 'bt_3', 'bt_4', 'bt_5', 'bt_6', 'bt_7', 'bt_8', 'caps', 'enc', 'imu' ]

// the fast ones we want: \imu, \caps;


// to send sim to a second machine (raspi), change addrs to mb18:
// MKtl('ntmi').device.updateSrcDstAddr(~mb18_hyper5.hostname, ~mb18_hyper5.port);

// on first machine, send to raspi
~ntmiDestAddr = ~raspi_hyper5;

// to send to myself, do
MKtl('ntmi').device.updateSrcDstAddr(~mb18_hyper5.hostname, ~mb18_hyper5.port);
~ntmiDestAddr = ~mb18_hyper5;

(
(
Tdef(\simImu, {
	var coll = MKtl('ntmi').collAt(\imu);
	var elems =  coll.elements;
	var msgName = coll.elemDesc.oscPath;
	var dataGens = elems.collect { |elem|
		var spec = elem.deviceSpec;
		var min = spec.minval, max = spec.maxval, range = max - min;
		Pbrown(min, max, range * 0.05).asStream;
	};
	inf.do { |i|
		var data = dataGens.collect(_.next).round(0.01);
		// "simImu sends:".postln;
		// data.postln;
		~ntmiDestAddr.sendMsg(msgName, *data);
		0.04.wait;
	}
}).play;
);

(
Tdef(\simCaps, {
	var coll = MKtl('ntmi').collAt(\caps);
	var elems =  coll.elements;
	var msgName = coll.elemDesc.oscPath;
	var dataGens = elems.collect { |elem|
		var spec = elem.deviceSpec;
		var min = spec.minval, max = spec.maxval, range = max - min;
		Pbrown(min, max, range * 0.05).asStream;
	};
	inf.do { |i|
		var data = dataGens.collect(_.next).round(0.01);
		// "simImu sends:".postln;
		// data.postln;
		~ntmiDestAddr.sendMsg(msgName, *data);
		0.04.wait;
	}
}).play;
);

// a bit crude!
// could be smarter by modeling shift-actions too.
(
Tdef(\simButs, {
	var buts = MKtl('ntmi').elAt(\bt).elements;
	inf.do { |i|
		buts.do { |elem, i|
			var currval, newval;
			if (0.01.coin) {
				elem.name.postln;
				elem.value_(1-elem.value);
				~ntmiDestAddr.sendMsg(elem.elemDesc.oscPath, i, elem.value);
				defer ({
					elem.value_(1-elem.value);
					~ntmiDestAddr.sendMsg(elem.elemDesc.oscPath, i, elem.value);
				}, 0.2)
			}
		};
		0.3.wait;
	}
}).play;
)
)
