/*
send x, y relative data from webpage to NTMI.

// for debugging on single machine
NTMI.webMouse.sendLocally = true;
NTMI.webMouse.sendLocally = false;

Todo:
- think through polyphony:
-- multiple webpages sending
-- multitouch on each page
-- multiple NTMI systems receiving, and sending display info back
*/

NTMI.webMouse = NTMI.webMouse ? ();
NTMI.webMouse.zoom = 1;
NTMI.webMouse.influxMode = \setRel;
NTMI.webMouse.setRel = {
	"NTMI.webMouse.influxMode: \setRel".postln;
};

NTMI.webMouse.setAbs = {
	"*** no setAbs! ".post; NTMI.webMouse.setRel;
};
// make a dummy MKtl for webMouse
MKtl.all.webMouse.free;
MKtl(\webMouse,
	(idInfo: \webMouse, protocol: \dummy, elementsDesc: (elements: [])),
	tryOpenDevice: false
);

NTMI.webMouse.sendLocally = false; // for debugging on single machine


(
OSCdef('/mouse', {|msg, time, sender|
	var funcKeys = MFdef(\setRelInf).activeNames.reject(_ == \xflux);
	// [sender, msg.round(0.001)].postln;
	// make sure we dont resend, to avoid feedback
	MFdef(\setRelInf).valueAt(funcKeys, msg[[1, 2]].asInteger, msg[[3, 4]], NTMI.webMouse.zoom * NTMI.zoom);
}, '/mouse')
);

MFdef(\sendStatus).add(\getData, {
	var ndefdata = NTMI.ndefs.collect { |ndef|
		var meter = ProxyMeter.all.detect { |mt| mt.arProxy == ndef };
		var ampVals = if (meter.notNil) { meter.ampVals } ? [0,0];
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
	var win = Window("\webMouse", Rect(200, 600, 200, 400)).front;
	win.alpha_(NTMI.g.alpha);
	NTMI.webMouse.win = win;
	NTMI.webMouse.uv = UserView(win, win.view.bounds).front;
	NTMI.webMouse.uv.clearOnRefresh = false;
	NTMI.webMouse.uv.resize_(5);

	NTMI.webMouse.uv.drawFunc = { |uv| NTMI.webMouse[\drawFunc].value(uv) };
	NTMI.webMouse.uv.mouseDownAction = { |uv, x, y|
		NTMI.webMouse[\downAction].value(uv, x, y)
	};
	NTMI.webMouse.uv.mouseMoveAction = { |uv, x, y|
		NTMI.webMouse[\moveAction].value(uv, x, y)
	};
	NTMI.webMouse.uv.mouseUpAction = { |uv, x, y|
		NTMI.webMouse[\upAction].value(uv, x, y)
	};
	win
});

MFdef(\drawNdefs).add(\draw, { defer { NTMI.webMouse.uv.refresh }});

(
NTMI.webMouse.sendChans = { NTMI.inphlux.inNames.size.rand } ! 2;
NTMI.webMouse.downCount = 0;
NTMI.webMouse.downAction = { |uv, x, y|
	NTMI.webMouse.xy = [x, y];
	NTMI.webMouse.downCount = 1;
};
NTMI.webMouse.upAction = { |uv, x, y|
	// dont count if < 0
	NTMI.webMouse.downCount = 0;
};


NTMI.webMouse.moveAction = { |uv, x, y|
	var newxy = [x, y];
	var diffs = ((newxy - NTMI.webMouse.xy) / uv.bounds.extent.asArray);
	var msgList = (NTMI.webMouse.sendChans ++ diffs).flat;
	NTMI.webMouse.xy = [x, y];
	NTMI.oscar.sendMsg("/mouse", *msgList);
	// send to local NTMI for testing
	if (NTMI.webMouse.sendLocally) {
		NTMI.localAddr.sendMsg("/mouse", *msgList);
	};
};

NTMI.webMouse.drawFunc = { |uv|
	var radii, mouseXY, white = Color.white;
	var bounds = uv.bounds, width = bounds.width, height = bounds.height / 4;
	var zone = Rect(0,0, width, height / 4);
	var nameRandHi = height / 2;
	Pen.push;
	NTMI.webMouse.chunks.do { |chunk, i|
		var name = chunk[0];
		var preVol = chunk[1], postVol = chunk[2];
		var paramVals = chunk[4..];
		var pHi = 80 / paramVals.size;

		// [name, i].postln;
		// chunk.round(0.001).postln;
		Pen.color = Color.grey(0.3, 0.05);
		Pen.fillRect(zone); // background

		Pen.color = Color.blue(1, 0.5); Pen.fillRect(Rect(0, 0, width * preVol,20));
		Pen.color = Color.green(1, 0.5);  Pen.fillRect(Rect(0, 0, width * postVol,20));

		Pen.color = Color.rand(0.65, 0.8).alpha_(0.5);
		paramVals.do { |val, i|
			var rect = Rect(0, i * pHi + 20, width * val, pHi - 1.5);
			Pen.fillRect(rect);
		};
		Pen.push;
		Pen.rotate(0.3.rand2, *zone.center.asArray);
		Pen.translate(nameRandHi.rand2, nameRandHi.rand2);
		Pen.stringCenteredIn(name.asString, zone, Font("Monaco", 24), white, \center);
		Pen.pop;
		Pen.translate(0, height);
	};
	Pen.pop;

	if (NTMI.webMouse.downCount > 0) {
		mouseXY = NTMI.webMouse.xy.asPoint;
		NTMI.webMouse.downCount = NTMI.webMouse.downCount + 1;
		radii = [0, 5, 10, 15] + NTMI.webMouse.downCount % 20;
		radii.do { |rad|
			Pen.addArc(mouseXY, rad, 0, 2pi)
		};
		Pen.width = 3;
		Pen.color = Color.green;
		Pen.stroke;
	};
};
);

WinBounds.showOrMake(\webMouse);