
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
	[char, char.toUpper].do { |char|
		KeyPlayer(\prez).putDown(char, { |char|
			// randomize Settings using the key's ascii number as random seed
			NTMI.slots.nowPlaying.do({|px|
				var pres = NdefPreset(px);
				"%: rand w % seed %\n".postf(px.key, NTMI.zoom, char.asUnicode);
				pres.setRand(NTMI.zoom, seed: char.asUnicode);
			})
		});
	};
};


// change the amount of randomisation with the '+ -' keys
(
// keyplayer for preset  random orbits
/// var amount = 1; //now: NTMI.zoom

NTMI.keys(Array).sort;

NTMI.keypl.probStep = {|dict, inc=0.1|
	"// new Probability: ".post;
	NTMI.setZoom((NTMI.zoom + inc).clip(0.05, 1.0).postln);
};
KeyPlayer(\prez).put($-, { |char| NTMI.keypl.probStep(-0.1) });
KeyPlayer(\prez).put($=, { |char| NTMI.keypl.probStep(0.1) });
KeyPlayer(\prez).put($+, { |char| NTMI.keypl.probStep(0.1) });
KeyPlayer(\prez).put($[, { |char| NTMI.keypl.probStep(-0.25) });
KeyPlayer(\prez).put($], { |char| NTMI.keypl.probStep(0.25) });
);

KeyPlayer(\prez).putDown($., { |char|
	var nowPlaying = NTMI.slots.nowPlaying;
	"// toggle Ndefs:".post;
	if (nowPlaying.size > 0) {
		"% off\n".postf(nowPlaying);
		NTMI.keypl.werePlaying = nowPlaying;
		nowPlaying.do(_.stop);
	} {
		"% ON\n".postf(NTMI.keypl.werePlaying);
		NTMI.keypl.werePlaying.do { |px| px.play.resume }
	}
});


// (
// KeyPlayer(\prez).put($/, {NTMI.slots.nowPlaying.do({|px|
// 	var pres = NdefPreset(px);
// 	pres.morphTask.play
// 	})
// })
// )