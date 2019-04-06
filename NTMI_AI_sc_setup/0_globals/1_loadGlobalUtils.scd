// RUN this entire file from elsewhere to have convenience functions //

q = q ? ();

// limit to sounding ndefs
q.getNdefs = { Ndef.dictFor(s).envir.select({ |ndef| ndef.rate == \audio }).asArray.sort { |px1, px2| px1.key < px2.key } };
q.getTdefs = { Tdef.all.values.asArray.sort { |px1, px2| px1.key < px2.key } };
q.getPdefs = { Pdef.all.values.asArray.sort { |px1, px2| px1.key < px2.key } };

q.getInfluxDestins = {
	// automagically attach all existing proxies to GUI Buttons. (max. 5 for now..)
	q.getNdefs ++ q.getTdefs ++ q.getPdefs
};

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

