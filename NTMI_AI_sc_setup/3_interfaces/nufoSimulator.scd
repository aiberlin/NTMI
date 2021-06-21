/*
// all together
Tdef(\sim_nUFO).play;

// or individually:s
Tdef(\simButs).play;
Tdef(\simCaps).play;
Tdef(\simImu).play;
}).play;
*/

q.net = q.net ? ();
////// f0s trick to free 57120 by force if necessary:
q.net.freeDefPort = {
	Platform.case(
		\linux, {
			unixCmd("kill -9"
				+ ("fuser -n udp 57120 | awk '{print $1}'").unixCmdGetStdOut.asInteger);
		}, {  //osx and windows
			unixCmd("kill -9" + ("lsof -ti :57120").unixCmdGetStdOut.asInteger);
		}
	);
};

// get broadcast address
q.net.getBroad = {
	"ifconfig".unixCmdGetStdOut
	.findRegexp("(?=(?<=broadcast )|(?<=Bcast:))(?:[0-9]{1,3}[.]){3}[0-9]{1,3}")[0][1];
};

q.net.getMyIP = {
	// get my own IP
	var res = "ifconfig".unixCmdGetStdOut
	.findRegexp("(?:[0-9]{1,3}[.]){3}[0-9]{1,3}(?=(?=.{10,30}broadcast )|(?=.{1,10}Bcast:))");
	if (res.notEmpty) { res[0][1] } {
		"*** NO NETWORK FOUND! q.net.getMyIP returns localhost: 127.0.0.1".postln;
		"127.0.0.1"
	};
};

///// get my network name - macOS only
/// need to know which device is active, then ask:
Platform.case(\osx, {
	q.net.getWifiName = {
		"networksetup -getairportnetwork en0".unixCmdGetStdOut.split($:).last.drop(1).drop(-1).cs;
		// network sends alive message, with network SSID/name;
	}
});

//// NetAddr("192.168.8.169", NetAddr.langPort);
q.net.myIP = NetAddr(q.net.getMyIP, NetAddr.langPort);

/*
// example: raspi in adc home network
q.net.secondIP = NetAddr("192.168.8.175", 57120);

// on second machine, open OSCdef.trace on other machine, then test-send:
q.net.secondIP.sendMsg(\helloNTMI, "are you listening?");
*/

MKtl('ntmi').device.oscFuncDictionary.keys(Array).sort.cs;
// [ 'battery', 'bt_1', 'bt_2', 'bt_3', 'bt_4', 'bt_5', 'bt_6', 'bt_7', 'bt_8', 'caps', 'enc', 'imu' ]

// the fast ones we want: \imu, \caps;
// to send sim to a second machine (raspi), change addrs to mb18:
// MKtl('ntmi').device.updateSrcDstAddr(~mb18_hyper5.hostname, ~mb18_hyper5.port);

// on first machine, send to raspi
q.net.ntmiTestAddr = q.net.secondIP;

// to send to myself, do
q.net.ntmiTestAddr = q.net.myIP;
MKtl('ntmi').device.updateSrcDstAddr(q.net.myIP.hostname, q.net.myIP.port).source;


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
		q.net.ntmiTestAddr.sendMsg(msgName, *data);
		0.04.wait;
	}
});
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
		q.net.ntmiTestAddr.sendMsg(msgName, *data);
		0.04.wait;
	}
});
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
				q.net.ntmiTestAddr.sendMsg(elem.elemDesc.oscPath, i, elem.value);
				defer ({
					elem.value_(1-elem.value);
					q.net.ntmiTestAddr.sendMsg(elem.elemDesc.oscPath, i, elem.value);
				}, 0.2)
			}
		};
		0.3.wait;
	}
});
);
Tdef(\sim_nUFO, {
	[Tdef(\simButs), Tdef(\simCaps), Tdef(\simImu)].do(_.play);
});
)
