/*
send x, y relative data from webpage to NTMI.

todo:
- fully unify with other interfaces as MKtl(\webMouse) etc;

- think through polyphony:
-- multiple webpages sending
-- mutlitouch on each page
-- multiple NTMI systems receiving, and sending display info back
*/




NTMI.webMouse = NTMI.webMouse ? ();
NTMI.webMouse.zoom = 1;
NTMI.webMouse.influxMode = \setRel;

NTMI.webMouse.setRel = {
	"NTMI.webMouse.influxMode: \setRel".postln;
};
NTMI.webMouse.setAbs = {
	"sorry, webMouse has no setAbs!".postln;
	NTMI.webMouse.setRel;
};

NTMI.myname = NTMI.myname ? unixCmdGetStdOut("hostname").reject(_ == Char.nl).asSymbol;
NTMI.mypwd = NTMI.mypwd ? "senha";

NTMI.localAddr = NetAddr.localAddr;
// for testing on a single computer:
NTMI.webMouse.sendLocally = true;


// check whether default OSCRouterClient server is reachable:
// (without access, startup can hang for 20-30 secs...)
unixCmd("ping bgo.la -c 1", { |okNum|
	if (okNum == 0) {
		NTMI.oscar = OSCRouterClient(NTMI.myname, "ntmi",
			userPassword: NTMI.mypwd, groupPassword: "senha");
		NTMI.oscar.join;
	} {
"NTMI.webMouse: we have no internet connection,
so we cannot make NTMI.oscar!
Replacing with localAddr.".warn;
		NTMI.oscar = NTMI.localAddr;
	}
});


(
OSCdef('/mouse', {|msg, time, sender|
	[sender, msg.round(0.001)].postln;
	MFdef(\setRelInf).(msg[[1, 2]].asInteger, msg[[3, 4]], NTMI.webMouse.zoom * NTMI.zoom);
}, '/mouse')
);

MFdef(\sendStatus).add(\getData, {
	var ndefdata = NTMI.ndefs.collect { |ndef|
		var meter = ProxyMeter.all.detect { |mt| mt.arProxy == ndef };
		var ampVals = if (meter.notNil) { meter.ampVals } { [0,0] };
		var data = ndef.getHalo.namesToInflux.collect(ndef.getUni(_));
		// ndef, ndef sound level,
		[ ndef.key, ampVals[0].sqrt, ampVals[1].sqrt, \paramUniVals ]
		++ data
	};
	var chunkSizes = ndefdata.collect(_.size);
	var fullData = (chunkSizes ++ ndefdata).flat;

	NTMI.oscar.sendMsg(\slotStatus, NTMI.myname, *fullData);
	// send to self for testing
	if (NTMI.webMouse.sendLocally) {
		NTMI.localAddr.sendMsg(\slotStatus, NTMI.myname, *fullData);
	};
	fullData
});


NTMI.webMouse.skip.stop;
NTMI.webMouse.skip = SkipJack({
	MFdef(\sendStatus).value;
}, 0.1);

/*
MFdef(\sendStatus).value.first.printAll;
*/

// receiver test:
OSCdef(\slotStatus, { |msg|
	var senderName = msg[1];
	var sizes = msg[(2..5)];
	var fullData = msg.drop(6);
	var chunks = fullData.clumps(sizes);
	// msg.keep(2).postln;
	// msg.round(0.01).postln;
	// chunks.round(0.01).printAll;
	NTMI.webMouse.chunks = chunks;
	MFdef(\drawNdefs).value;
}, \slotStatus);

WinBounds.addMake(\webMouse, {
	var win = Window("webmouse", Rect(200, 600, 200, 400)).front;
	NTMI.webMouse.win = win;
	NTMI.webMouse.uv = UserView(win, win.view.bounds).front;
	NTMI.webMouse.uv.drawFunc = { NTMI.webMouse[\drawFunc].value };
	NTMI.webMouse.uv.mouseDownAction = { |uv, x, y|
		NTMI.webMouse[\downAction].value(uv, x, y)
	};
	NTMI.webMouse.uv.mouseMoveAction = { |uv, x, y|
		NTMI.webMouse[\moveAction].value(uv, x, y)
	};
	win
});

MFdef(\drawNdefs).add(\draw, { defer { NTMI.webMouse.uv.refresh }});

(
NTMI.webMouse.sendChans = { NTMI.inphlux.inNames.size.rand } ! 2;

NTMI.webMouse.downAction = { |uv, x, y|
	NTMI.webMouse.xy = [x, y];
};

NTMI.webMouse.moveAction = { |uv, x, y|
	var newxy = [x, y];
	var diffs = ((newxy - NTMI.webMouse.xy) / uv.bounds.extent.asArray);
	var msgList = (NTMI.webMouse.sendChans ++ diffs).flat;
	NTMI.webMouse.xy = [x, y];

	// send to local NTMI for testing
	if (NTMI.webMouse.sendLocally) {
		NTMI.localAddr.sendMsg("/mouse", *msgList);
	};
};

NTMI.webMouse.drawFunc = {
	NTMI.webMouse.chunks.do { |chunk, i|
		var name = chunk[0];
		var preVol = chunk[1], postVol = chunk[2];
		var zone = Rect(0,0, 200, 100);
		var paramVals = chunk[4..];
		var pHi = 80 / paramVals.size;

		// [name, i].postln;
		// chunk.round(0.001).postln;
		Pen.color = Color.rand(0.85, 0.9);
		Pen.fillRect(zone); // background

		Pen.color = Color.blue(1, 0.5); Pen.fillRect(Rect(0, 0, 200 * preVol,20));
		Pen.color = Color.green;  Pen.fillRect(Rect(0, 0, 200 * postVol,20));

		Pen.color = Color.rand(0.65, 0.7);
		paramVals.do { |val, i|
			var rect = Rect(0, i * pHi + 20, 200 * val, pHi);
			Pen.fillRect(rect);
		};

		Pen.stringCenteredIn(name.asString, zone, Font("Monaco", 24), Color.black, \center);
		Pen.translate(0, 100);
	};
};
);

WinBounds.showOrMake(\webMouse);