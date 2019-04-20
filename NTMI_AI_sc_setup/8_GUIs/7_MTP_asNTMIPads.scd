// Quarks.install("MultiTouchPad");

/*

OSCdef(\imu).func.value([\blabla] ++ (0.1!10)) ; // 8 times calcOutVals
OSCdef(\xana).func.value([\qwer] ++ (0.2!16)); // only once


*/

MTP.progpath = (q.dir.base +/+ "macos_binaries/");

g.makeGui.xoscMTPads = {
	q = q ? ();
	q.mtp = q.mtp ? ();
	q.mtp.skip.stop;
	q.mtp.skip = SkipJack ({
		if ( MTP.isRunning) {
			if (q.inph.mode == \touch) {
				MKtl(\xosc).elAt(\pads8).value_(q.mtp.padvals);
				MFdef(\touchToInph).value;
			} {
				MKtl(\xosc).elAt(\imu9).value_(q.mtp.imuvals);

			};

		};
	}, 0.05);

	MTP.start.gui;
	MTP.resetActions;

	MTP.guiWin.bounds_(Rect.aboutPoint(Window.screenBounds.center + (0 @ -60), 260, 190));
	MTP.uview.background_(Color.grey(0.4, 0.6));
	MTP.guiWin.view.alpha_(0.8);

	MFdef(\mtp).add(\pad, { |id, xys|
		var mypadindex, myimukey, numfingers;
		var imukeys = [ 'accel', 'gyro', 'magnet' ];
		var convertedSize;

		if (q.inph.mode == \touch) {
			mypadindex = q.mtp.padmap[id];
			mypadindex ?? {
				mypadindex = q.mtp.pads.detectIndex { |pt|
					hypot(pt.x - xys[0], pt.y - xys[1]) < 0.08;
				};
				if (mypadindex.notNil) {
					q.mtp.padmap.put(id, mypadindex);
				};
			};
			if (mypadindex.notNil) {
				q.mtp.padvals.put(mypadindex, (xys[2] * 0.7).clip(0, 1));
				// q.mtp.padvals.round(0.001).postln;
			};
		} {
			myimukey = q.mtp.imumap[id];
			myimukey ?? {
				numfingers = MTP.fingersDict.size;
				if (numfingers < 4) {
					myimukey = imukeys.detect { |key| q.mtp.imumap.includes(key).not };
					q.mtp.imumap.put(id, myimukey);
				};
			};

			convertedSize = (xys[2] * 0.25 * (id % 2).unibi).biuni;

			MKtl(\xosc).elAt(myimukey).valueAction_(
				xys.put(2, convertedSize));

			MFdef(\imuFunc).value;
		};
	});

	MTP.touchAction = MFdef(\mtp);
	MTP.setAction = MFdef(\mtp);

	MTP.keydownDict.put($m, {
		MFdef(\imuMode).value;
		try { MTP.uview.refresh };
	});

	MTP.untouchAction = { |id|
		// " stop id: %\n".postf(id);
		var mypadindex = q.mtp.padmap[id];
		var myimukey = q.mtp.imumap[id];

		mypadindex !? { q.mtp.padvals.put(mypadindex, 0) };
		q.mtp.padmap[id] = nil;
		myimukey !? {
			MKtl(\xosc).elAt(myimukey).valueAction_([0.5, 0.5, 0.5]);
			MFdef(\imuFunc).value;
		};
		q.mtp.imumap[id] = nil;
		MTP.refresh;
	};

	q.mtp.pads = [0.1@0.2, 0.3@0.3, 0.4@0.5, 0.42@0.72];
	q.mtp.pads = q.mtp.pads ++ q.mtp.pads.collect { |pad| pad.copy.x = 1 - pad.x };
	q.mtp.radius = 0.08;
	q.mtp.padvals = 0 ! 8;
	q.mtp.imuvals = 0.5 ! 9;
	q.mtp.padmap = ();
	q.mtp.imumap = ();


	// only do the finger drawing part of it, with little mods:
	MTP.uview.drawFunc = { |uv|
		var bounds = uv.bounds;
		var extent = bounds.extent;
		var center = bounds.center;
		var halfFing = MTP.fingerSize * 0.5;
		var star, font = Font("Monaco", extent.x * 0.08);
		var white = Color.white.alpha_(0.6);
		var black = Color.black.alpha_(0.6);

		[
			"simulate xosc input:",
			"'.' to stop",
			"[space] to start",
			"M toggles Touch/Move"
		].do { |string, i|
			var hiunit = extent.y * 0.13;
			Pen.stringCenteredIn(string,
				bounds.copy.top_(hiunit * i).height_(hiunit),
				font,
				black
			)
		};

		if (q.inph.mode == \touch) {
			q.mtp.pads.do { |padc, i|
				var rect =
				Pen.addArc(padc * extent, 0.08 * extent.x, 0, 2pi);

				Pen.color_(white).fill;
				Pen.stringCenteredIn(
					i.asString,
					Rect.aboutPoint(padc * extent, 0.16 * extent.x, 0.16 * extent.x),
					font,
					color: black
				);
			};
		} {
			// "move mode vis".postln;
			star = g.main.movevals.collect { |val, i|
				Polar(val.linlin( 0, 1, 40, 240), i / 9 * 2pi).asPoint + center;
			};
			// star.postln;
			Pen.color = Color.yellow; Pen.width = 3;
			star.wrapExtend(10).doAdjacentPairs { |p1, p2| Pen.line(p1, p2); };
			Pen.stroke;
			star.do { |p1| Pen.line(p1, center); };
			Pen.color = white; Pen.width = 1.5;
			Pen.stroke;
		};

		// draw finger touchpoints and info for them
		MTP.fingersDict.keysValuesDo { |key, fItem|
			var x = bounds.width - halfFing * fItem[0];
			var y = bounds.height - halfFing * fItem[1];
			var fingSize = MTP.fingerSize * fItem[2];

			// random color, fill instead of stroke
			Pen.color = Color.rand;
			Pen.fillOval( Rect(x, y, fingSize, fingSize));

			Pen.stringCenteredIn(
				MTP.fingerStrings[key] ? key.asString,
				Rect.aboutPoint(x@y, 60, 30)
			);
		};
	};
	// main win responds to same commands as MTP:

	g.main.w.view.keyDownAction = { |view, key|
		MTP.keydownDict[key].value(view, key);
	};

};

