// the OSC port number flatcat sends on
thisProcess.openUDPPort(8999);

NTMI.flatcat = NTMI.flatcat ? ();

NTMI.flatcat.loadMe = NTMI.flatcat.loadMe ? {
	// load flatcat setup/connection file
	LoadMe("SpecialUses/flatcat/flatcat2NTMI_better.scd", NTMI.dir.setup);
	LoadMe("SpecialUses/flatcat/flatcat_trigchange.scd", NTMI.dir.setup);
	// load flatcat visualisation file
	LoadMe("SpecialUses/flatcat/flatcat_viz.scd", NTMI.dir.setup);
	// and show the flatcat visualisation on the main window
	defer { NTMI.g.main.imuUV.animate_(true).drawFunc = NTMI.flatcat[\draw] };
};

OSCdef(\detectFlatcat, { |msg, time, senderAddr, recvPort|
	NTMI.flatcat.loadMe;
	"*** detected Flatcat - updating source to: %\n".postf(senderAddr);
	MKtl(\flatcat).device.updateSrcAddr(senderAddr.ip, senderAddr.port);
	OSCdef(\detectFlatcat).disable;
	"*** updated to:".post;
	MKtl(\detectFlatcat).device.source.postln;
}, \flatcat).enable;

