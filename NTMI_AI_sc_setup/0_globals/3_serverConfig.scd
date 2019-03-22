
// "\n**********  loading serverConfig:  **********".postln;

// Server.default = s = Server.local;

// tweak for fast response and rare complaints:
// default is 0.2 secs, which feels slow;
// less than 0.03 may introduce many late messages from server.
// latency nil means do things immediately, but will compromise timing:
// it quantizes to the hardwareBufferSize border.
s.latency = 0.05;

// // hardware setup first
s.options
//.device_("2882 [3712]")	// device name
.numInputBusChannels_(18)		//
.numOutputBusChannels_(18)		//
.blockSize_(64)					//  .kr bus rate, default is 64 samples
.hardwareBufferSize_(64*2)		// take fastest power of two hardware allows
.memSize_(8192 * 16)
;

// "Setting server options: ".postln;
if (s.serverRunning) {
	q.warnWin(
		"Server options were set when s was running already!"
		" Settings will not take effect until server is rebooted:"
		"\ns.reboot;",
		"Server options!"
	);
};


// recording options:
s
.recChannels_(q.numChans ? 2)			// record numChans
.recSampleFormat_("float"); // in float to recover from clipping

"*** to see server settings, do: \nq.postServerOptions;\n".postln;

q.postServerOptions = {
	"********** Server info : **********".postln;
	"s.name: % \n"
	"s.address: % \n"
	"s.latency: % \n"
	.postf(s.name, s.addr, s.latency);
	"server options:".postln;
	s.options.dump;
	"********************".postln;
	"serverConfig loaded.".postln;
	"********************".postln;
};


