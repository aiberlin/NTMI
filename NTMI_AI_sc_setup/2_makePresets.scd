		MFdef(\makePresets).add(\load, {
			forkIfNeeded {
				"\n\n*** NTMI loading process folder %:\n".postf("2_process");
				// find matching paths in pool first
				q.process = q.process ? ();
				q.process.procPath = (q.dir.userPOOL +/+ "2_process/*.scd");
				q.process.foundPaths = q.process.procPath.pathMatch;
				q.process.foundNames = q.process.foundPaths.collect { |p|
					p.basename.splitext[0].asSymbol
				};

				// list all candidate files
				"// found % process paths at \n%\n".postf(
					q.process.foundPaths.size, q.process.procPath.cs);
				"// post them with: \nq.process.foundNames.cs".postln;

				0.5.wait;

				if (q.prefs.active.processNames.isNil) {
					"loading all % found paths:\n".postf(q.process.foundNames.size);
					q.process.namesToLoad = q.process.foundNames;
				} {
					"loading predefined paths in q.prefs.active.processNames:\n";
					q.process.namesToLoad =
					q.prefs.active.processNames.sect(q.process.foundNames);
				};

				q.process.allNames = q.process.namesToLoad;

				// load preferred processNames, or all:
				q.process.namesToLoad.do { |name|
					q.load(name ++ ".scd", q.dir.userPOOL +/+ "2_process");
					s.sync;
					0.05.wait;
				};

				q.ndef = q.ndef ? ();
				q.ndef.groups = q.ndef.groups ? ();

				q.ndef.groups.put(\NTMI,
					q.process.namesToLoad.collect(Ndef.all[s.name][_]));

				q.load("2a_preset*.scd");

				0.2.wait;
				// activate the ndefs given in prefs:
				q.ndefs = q.prefs.active.defaultActives.collect(Ndef(_));
				"\n\n".postln;
			};
		});
