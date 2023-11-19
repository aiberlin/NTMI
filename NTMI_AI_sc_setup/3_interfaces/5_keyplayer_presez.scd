// keyplayer for preset  random orbits
/// var amount = 1; //now: NTMI.zoom
var probSwitch, volSwitch;

///////////////////////////////////////////////////////////////
// The KeyPlayer GUI  //////////////////////////////////////////
//////////////////////////////////////////////////////////////
NTMI.keypl = NTMI.keypl ? ();


///////////////////////////////////////////////////////////////
// The KeyPlayer Tab  //////////////////////////////////////////
//////////////////////////////////////////////////////////////

KeyPlayer(\prez);
KeyPlayer(\prez).makeLoop;

/////// works
"1234567890".do { |char, i|
	KeyPlayer(\prez).putDown(char, { |char|
		// randomize Settings using the key's ascii number as random seed
		NTMI.slots.nowPlaying.do({ |px|
			var pres = NdefPreset(px);
			var newSet = pres.getSetNames.wrapAt(char.digit);
			pres.setCurr( newSet ).setProxy(newSet);
		})
	});
};

// "!@#$%^&*()".do { |char, i|
// 	KeyPlayer(\prez).putDown(char, { |char|
// 		// randomize Settings using the key's ascii number as random seed
// 		NTMI.slots.nowPlaying.do({|px|
// 			var pres = NdefPreset(px);
// 			pres.xsetCurr( pres.getSetNames.wrapAt(i+1) ); // xsetCurr OK
// 		})
// 	});
// };

"zxcvbnmasdfghjklqwertyuiop".do { |char, i|
	KeyPlayer(\prez).putDown(char, { |char|
		// randomize Settings using the key's ascii number as random seed
		NTMI.slots.nowPlaying.do({|px|
			var pres = NdefPreset(px);
			pres.setRand(NTMI.zoom, seed: char.asUnicode);
			// pres.currSet.postcs;
		})
	});
};

"zxcvbnmasdfghjklqwertyuiop".do { |char, i|
	char = char.toUpper;
	KeyPlayer(\prez).putDown(char, { |char|
		// randomize Settings using the key's ascii number as random seed
		NTMI.slots.nowPlaying.do({|px|
			var pres = NdefPreset(px);
			pres.xsetRand(NTMI.zoom, seed: char.toLower.asUnicode);  // xsetRand not OK
			// pres.currSet.postcs;
		})
	});
};


// change the amount of randomisation with the '+ -' keys
(
probSwitch = {|inc=0.1|
	"new Probability: ".post;
	NTMI.setZoom((NTMI.zoom + inc).clip(0.05, 1.0).postln);
};
KeyPlayer(\prez).put($-, { |char| probSwitch.value(-0.1) });
KeyPlayer(\prez).put($=, { |char| probSwitch.value(0.1) });
KeyPlayer(\prez).put($[, { |char| probSwitch.value(-0.25) });
KeyPlayer(\prez).put($], { |char| probSwitch.value(0.25) });
);

KeyPlayer(\prez).putDown($., { |char|
	"toggle play Ndefs!".postcln;
	NTMI.slots.nowPlaying.do({|px|
		if(px.monitor.isPlaying){px.stop;}{px.play.resume;  }
	})
});


// (
// KeyPlayer(\prez).put($/, {NTMI.slots.nowPlaying.do({|px|
// 	var pres = NdefPreset(px);
// 	pres.morphTask.play
// 	})
// })
// )