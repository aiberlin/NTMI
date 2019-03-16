// RUN this entire file from elsewhere to have convenience functions //

q = q ? ();

// helpful things to find all the files in this setup folder:
q.utilDir = thisProcess.nowExecutingPath.dirname;
q.topDir = q.utilDir.dirname;
q.fulldirnames = (q.topDir +/+ "*/").pathMatch;
q.dirnames = q.fulldirnames.collect { |path| path.basename };

"/// q.topDir: %\n".postf(q.topDir);
"/// q.dirnames: ".postln;
q.dirnames.printAll;

//
if (q.hasGui) { "warnWin.scd".loadRelative };

// limit to sounding ndefs
q.getNdefs = { Ndef.dictFor(s).envir.select({ |ndef| ndef.rate == \audio }).asArray.sort { |px1, px2| px1.key < px2.key } };
q.getTdefs = { Tdef.all.values.asArray.sort { |px1, px2| px1.key < px2.key } };
q.getPdefs = { Pdef.all.values.asArray.sort { |px1, px2| px1.key < px2.key } };

q.getInfluxDestins = {
	// automagically attach all existing proxies to GUI Buttons. (max. 5 for now..)
	q.getNdefs ++ q.getTdefs ++ q.getPdefs
};


// new function to load code files which can wait and posts loading time info:
q.load = { |q, filename, preText = "", postText = "", dirsup = 0, wait = 0.1|
	forkIfNeeded ({
		var here = "".resolveRelative;
		var loadDur, t0 = Main.elapsedTime;
		dirsup.do { here = here.dirname };
		"*** loading % : %\n".postf(filename, preText);
		(here +/+ filename).loadPaths.postln;
		if (s.serverRunning) { try { s.sync } };
		loadDur = (Main.elapsedTime - t0).round(0.001);
		"... loading took % secs. %\n---\n\n".postf(loadDur, postText);
		wait.wait;
		"";
	}, AppClock)
};

// load snd
q.loadRel = { |q, filename, levelsUp = 1, folder = "*"|
	var paths, result;
	var dir = thisProcess.nowExecutingPath;
	levelsUp.do { dir = dir.dirname };
	dir = dir +/+ folder;
	paths = (dir +/+ filename ++"*").postln.pathMatch;
	paths.size.switch (
		0, { "q.loadRel - no file found.".postln; },
		1, { "found single file, loading:".postln;
			result = paths.first.load; },
		{ "multiple matches - please find unique path: ".postln;
			paths.printAll;
	});
	result;
};

""; // dont post q
