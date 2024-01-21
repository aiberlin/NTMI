/*
MKtl.all[\flatcat].free;
*/

// the OSC port number flatcat sends on
thisProcess.openUDPPort(8999);

OSCdef(\detectFlatcat, { |msg, time, senderAddr, recvPort|

	fork ({
		if (MKtl.all.flatcat.isNil) {
			"*** new flatcat detected! loading setup.".postln;
			LoadMe("SpecialUses/flatcat/*flatcat*.scd", NTMI.dir.setup);
		};
		"*** detected flatcat - updating source to: %\n".postf(senderAddr.cs);
		if (MKtl(\flatcat).hasDevice) {
			MKtl(\flatcat).device.updateSrcAddr(senderAddr.ip, senderAddr.port);
			"*** updated to: ".post;
			MKtl.all[\flatcat].device.source.postcs;
			OSCdef(\detectFlatcat).disable;
		}
	}, AppClock);

}, \flatcat).enable;


