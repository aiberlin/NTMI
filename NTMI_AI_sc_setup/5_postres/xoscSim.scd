///////// simulate all messages from xosc ///////////

/*
Tdef(\xoscSimulator).play;

MKtl(\xosc).device.oscFuncDictionary.keys

q.addrSC = ().sendMsg = { |q ... msg| msg.postcs };

OSCdef.trace(true, true);
OSCdef.trace(false, true);

*/

// send to this address, the port xosc sends to:
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

///// switch address inside MKtl for simulation, so MKtl responds
MFdef(\switchToSim).add(\mode, {
	var oscdict = MKtl(\xosc).device.oscFuncDictionary;
	oscdict.do { |oscfunc|
		oscfunc.srcID.hostname_("127.0.0.1").port_(NetAddr.langPort)
	};
	"*** XOSC switchToSim: srcID is now % !\n\n".postf(oscdict.choose.srcID.cs);
	Tdef(\xoscSimulator).stop.play;
});


///// switch back address to listen to real xosc sending
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
Tdef(\xoscSimulator).set(\zoom, 0.7);

Tdef(\xoscSimulator, { |ev|

	var anavals = 0 ! 16;
	var digivals = 0 ! 16;
	var imuvals = 0.5 ! 9, imuRawVals;
	var tempval = 50;
	var batval = 50;
	var imuspecs = MKtl(\xosc).elAt(\imu9).collect(_.deviceSpec);

	loop {
		// ten seconds of pads & imu
		(10 / ev.dt).do { |i|
			// send OSC messages for analog and imu at typical rates,
			// random drift unless played otherwise by some sim interface.

			// imuvals and temperature:
			imuvals = imuvals.collectInPlace { |val| (val + 0.2.rand2 * 0.95).fold2(8.0).round(0.01) };
			tempval = if (ev.dt.coin) { tempval = rrand(40, 60) };
			// imuvals.round(0.001).postln;

			// map backwards to get realistic raw values:
			imuRawVals = imuvals.collect { |val,i| imuspecs[i].map(val) };
			// imuRawVals.round(0.001).postln; "".postln;
			q.addrSC.sendMsg(\imu, *(imuRawVals ++ tempval));
			q.addrSC.sendMsg('/inputs/analogue', *anavals);

			anavals = anavals.collectInPlace { |val, i| (val + 0.05.rand2).fold(0, 1).round(0.01) };

			// zoom - pretend pot rand jitter to be filtered
			anavals.put(7, ev.zoom + 0.001);

			// send battery value
			if (i % 10 == 0) {
				batval = rrand(3.5, 4.0).round(0.001);
				q.addrSC.sendMsg('/battery', batval);
			};
			ev.dt.wait;
		};

		// ten seconds of random buttons
		(10 / ev.dt).do { |i|
			// randomly press button for a while
			if ((ev.dt).coin) {
				var randindex = 7.rand;
				digivals[randindex] = 0;
				q.addrSC.sendMsg('/inputs/digital', *digivals);
				defer ({ digivals[randindex] = 1 }, rrand(0.2, 1.0));
			};
			// send battery value
			if (i % 10 == 0) {
				batval = rrand(3.5, 4.0).round(0.001);
				q.addrSC.sendMsg('/battery', batval);
			};
			ev.dt.wait;
		};

	}


});
