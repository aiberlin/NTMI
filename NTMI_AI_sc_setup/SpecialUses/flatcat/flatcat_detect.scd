// the OSC port number flatcat sends on
thisProcess.openUDPPort(8999);

OSCdef(\detectFlatcat, { |msg, time, senderAddr, recvPort|

	defer {
		if (MKtl.all.flatcat.isNil) {
			// load all flatcat setup/connection file
			LoadMe("SpecialUses/flatcat/flatcat*.scd", NTMI.dir.setup);
		};
		"*** detected Flatcat - updating source to: %\n".postf(senderAddr);
		MKtl(\flatcat).device.updateSrcAddr(senderAddr.ip, senderAddr.port);
		OSCdef(\detectFlatcat).disable;

		"*** updated to:".post;
		MKtl(\detectFlatcat).device.source.postln;
	};

}, \flatcat).enable;

