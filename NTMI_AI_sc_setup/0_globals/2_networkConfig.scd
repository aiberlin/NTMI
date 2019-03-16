

"\n**********  Network Config:  **********\n".postln;

q.getMyIPs = {
		var confstr = unixCmdGetStdOut("ifconfig");
		var labelStarts = confstr.findAll("inet");
		var strings = labelStarts.collect { |start|
			confstr.copyRange(start + 5, start + 5 + 20) };
		var cands = strings.collect { |str|
			str.split($ ).select { |st| st.size > 7 }
		}.flatten(1);
		cands.select(_.every("1234567890.".includes(_)));
};

q.getMyIPs;

// q.myIPs = OSCMon.getMyIPs;
NetAddr.broadcastFlag_(true);
if (NetAddr.langPort != 57120) {
	q.warnWin(
		"NetAddr.langPort should be 57120, but it is %!".format(NetAddr.langPort)
		++ "\nBetter reboot SC.",
		"NetAddr.langPort is wrong!");
};

q.broad = NetAddr("255.255.255.255", NetAddr.langPort);

"network setup : \n"
"IP addresses : % \n".postf(q.myIPs);
"NetAddr.langPort : % \n".postf(NetAddr.langPort);
"q.broad : % \n".postf(q.broad);
"\n********************\n".postln;
