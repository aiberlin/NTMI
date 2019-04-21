q.addrSC = NetAddr.localAddr.port_(8000);

OSCdef.trace(false);

/* test buttons from remote:
q.addrSC.sendMsg('/inputs/digital', 0, 2.rand);
q.addrSC.sendMsg('/inputs/digital', 1, 2.rand);
q.addrSC.sendMsg('/inputs/digital', 2, 2.rand);
q.addrSC.sendMsg('/inputs/digital', 3, 2.rand);
*/

/*
// has weird crosstalk compensation and bending curve on values
q.addrSC.sendMsg('/inputs/analogue', *(0!16));
q.addrSC.sendMsg('/inputs/analogue', *(0.5!16));
q.addrSC.sendMsg('/inputs/analogue', *({0.75.rand}!16));
*/

MFdef(\switchToSim).add(\mode, {
	var oscdict = MKtl(\xosc).device.oscFuncDictionary;
	oscdict.do { |oscfunc|
		oscfunc.srcID.hostname_("127.0.0.1").port_(NetAddr.langPort)
	};
	"*** XOSC switchToSim: srcID is now % !\n\n".postf(oscdict.choose.srcID.cs);
	Tdef(\xoscSimulator).stop.play;
});


MFdef(\switchToXOSC).add(\mode, {
	var info = MKtl(\xosc).desc.fullDesc.netAddrInfo;
	var oscdict = MKtl(\xosc).device.oscFuncDictionary;
	oscdict.do { |oscfunc|
		oscfunc.srcID.hostname_(info.ipAddress).port_(info.srcPort)
	};
	"*** XOSC switchToSim: srcID is now % !\n\n".postf(oscdict.choose.srcID.cs);
	Tdef(\xoscSimulator).stop;
});


Tdef(\xoscSimulator).set(\dt, 0.2);

Tdef(\xoscSimulator, { |ev|

	var imuvals = 0.5 ! 9, imuRawVals;
	var anavals = 0 ! 16;
	var tempval = 20;
	var imuspecs = MKtl(\xosc).elAt(\imu9).collect(_.deviceSpec);

	inf.do { |i|
		// send OSC messages for analog and imu at typical rates,
		// random drift unless played otherwise by some sim interface.

		imuvals = imuvals.collectInPlace { |val| (val + 0.2.rand2 * 0.95).fold2(8.0).round(0.01) };
		tempval = (tempval + 3.rand2).fold(0, 100);

		anavals = anavals.collectInPlace { |val, i| (val + 0.05.rand2).fold(0, 1).round(0.01) };

		// zoom - pretend pot rand jitter to be filtered
		anavals.put(7, q.zoom);

		imuvals.round(0.001).postln;
		imuRawVals = imuvals.collect { |val,i| imuspecs[i].map(val) };
		imuRawVals.round(0.001).postln;
		"".postln;
		q.addrSC.sendMsg(\imu, *(imuRawVals ++ tempval));
		q.addrSC.sendMsg('/inputs/analogue', *anavals);

		ev.dt.wait;

	}
});
//
// //////// start simulation from xosc GUI:
// MKtl(\xosc).elAt(\inD, \15).action = { |bt|
// 	if (bt.value > 0) {
// 		"*** starting sim: ".post;
// 		MFdef(\switchToSim).value;
// 	}
// };
// MKtl(\xosc).elAt(\inD, \16).action = { |bt|
// 	if (bt.value > 0) {
// 		"*** stopping sim: ".post;
// 		MFdef(\switchToXOSC).value;
// 	}
// };