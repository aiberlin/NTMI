/*
*/
// replaced by 	q.mtx.actives
q.active = q.active ?? {()};
q.active.presWin = Set.new;
try{ q.active.presWin.add(q.ndefs.first) };
// here, we need a bloody single item, not a set !
// try{ q.active.presWin = (q.ndefs.first) };

// (global func to get all playable Proxies ) // but there is also q.getInfluxDestins and q.ndefs == q.getInfluxDestins
q.getActivePxsAsList = { |q, space|
	var names = space.envir.select { |px| px.rate == \audio }.keys.asArray.sort;
	// names.collect({|n| p[n]});
	names
};

(
q.makeMeAPreset = { |q, px|
	var pp, w, ppg, ng, shrink = -60;

	var namesToStoreNoAmp = px.controlKeys.reject( _ == \amp); // everything except amp
	// var xpos = px.getHalo(\scene) ? 0;
	var name = px.key;
	var presPath = (thisProcess.nowExecutingPath.dirname.dirname +/+ "2_processes/presets/" +/+ name ++ ".pxpreset.scd");

	pp = NdefPreset(px, namesToStoreNoAmp);	// <- dont store amp along
//	px.addHalo(\orderedNames, namesToStoreNoAmp); // take amp out of influx names

	// must be in folder of preset file or fails... or link to preset file loc.!
	if(File.exists(presPath)){"\n** going to load preset % from file %\n".postf(name, presPath)};
//	pp.setPath(presPath);
	pp.storePath_(presPath); // <<<< this solves it !!!!
	pp.loadSettings(presPath);
	if(pp.settings.notNil){ // load first real preset ...
		pp.setCurr(pp.settings.wrapAt(1).key);
	}{ "sorry, no settings there yet".warn };
	px.addHalo(\ndefPreset, pp);
}
);

// making all the presets here
q.getInfluxDestins.do({|px, i|	q.makeMeAPreset(px); 0.1.wait; });

// increments and stores a ransom seed per ndefPreset.
q.incrementSeed = {|q, px, inc=1|
	var preset = px.getHalo(\ndefPreset);
	var seed = px.getHalo(\seed) ? 0;
	if(preset.notNil){
		seed = seed + inc;
		postf("nu seed: %\n", seed);
		px.addHalo(\seed, seed);
		seed;
	}{ "%: sorry, no preset present.\n".postf(px) }
};

