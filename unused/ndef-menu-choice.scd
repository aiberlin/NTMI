// ToDo: re-write all popup lists REMOVING the 3 other selected items.having same Ndef on 2 slots makes no sense.
// q.allSoundNames shd be Symbols, cavolo!
/*
q.ndefs;
a = q.allSoundNames; // this shd be Symbols, cavolo!
a.removing( q.ndefs[0].key.asString )
a.[0].class;

a = (0..10);
a = a.removing(6)

#####
i = 1; // aktueller slotIndex
j = q.ndefs.copy;
j.removeAt(i);
j; // die jezt rausfiltern aus der akt. choice

a = q.allSoundNames;
j.do{|ndef, ii|
q.allSoundNames = q.allSoundNames.removing( ndef.key )
};
#####
*/

q.choiceNewNdefFunc = {|env, slotIndex, choiceIndex, key|
	Routine{
		// var a = q.allSoundNames[slotIndex];
		var path = q.allSoundPaths.detect{|path| path.contains(key) };
		var choiceNdef = Ndef(key.asSymbol);
		var choiceOldNdef = q.ndefs[slotIndex];

		path.load;
		0.2.wait; // hmmm.. asynch .. how to know ?

		q.ndefs = q.ndefs.put(slotIndex, choiceNdef);
		q.ndefs[slotIndex].set(\amp, 0).play(vol: 0.25);

		//////////// GUIGUIGUI /////////
		q.ndefs.do { |ndef, i| // in 0_inphlux - needed?
			q.inphGui.attachToButton(i, ndef);
		};
		q.ndefGuis.do { |g, i| g.object = q.ndefs[i] };
		//////////// GUIGUIGUI /////////

//		q.maPresetWin.getHalo(\butRow)
//		q.maPresetWin == 	q.ndefPresetGlobalWin ;

		// breaks if multiple slots have same Ndef selected !
		if( q.ndefs.includes( choiceOldNdef ).not ){
			0.1.wait;
			choiceOldNdef.end(2);
			2.wait;
			choiceOldNdef.clear;
		};

		// if no other Error, store
		File.use(q.choiseNdefs_storePath, "w", { |file| file.write(q.ndefs.collect(_.key).cs) } );


	}.play(AppClock);
	[ slotIndex, choiceIndex, key].postcln;

};

Window.allWindows.do({|c|c.name.postcln})