// ////////// --------- this should go into post preferences!

// obsolete for anything else than our private setups' masterFX.

// ~trioPlayers = ["arik", "laVulega", "isakhan"];
q.me = q.me ??  {unixCmdGetStdOut("whoami").split(Char.nl).first.asSymbol}; // got it at 00_loadMe

// do all MasterFX stuff PER PERSON
// get current values with and make sure to .add or .remove FX Blocks
/*
q.mFX.pxChain.proxy.document
*/
(
\laVulega: {
	q.mFX.pxChain.add('0OnePolBal', 1);
	q.mFX.pxChain.add('1holz', 0.5);
	q.mFX.pxChain.add('1ixiDist', 0.18);
	// q.mFX.pxChain.add('4ixiVerb', 0.125);
	q.mFX.pxChain.add('5LPF', 0.6);
	q.mFX.pxChain.add('7Delay', 0.125);
	q.mFX.pxChain.remove('0_DBComp');

	q.mFX.pxChain.proxy.set('delayTime1', 0.42, 'delayTime2', 0.76, 'wet130', 0.6, 'combdecay', 6.8, 'wet20', 1, 'wet70', 0.18, 'wet150', 0.125, 'pregain', 1.46, 'wet30', 1, 'freqL', 700.0, 'wet170', 1, 'ixivAmp', 0.25, 'wet110', 0.125, 'ampLimit', 0.74, 'apDecay', 5.678, 'postgain', 1.0, 'dFreq', 2200, 'llag', 2.0, 'fadeTime', 3, 'predelay', 0.2, 'wet10', 1.0, 'mod', 0.6);

	q.ndefs.do{|nd, i|
		nd.vol_( #[ 0.25, 0.1, 0.4, 0.25][i])

	};

},
\arik: {
	q.mFX.pxChain.add('3AdCVerb', 0.1);
	q.mFX.pxChain.add('3ring', 0.1);
	q.mFX.pxChain.add('5HPF', 0.1);
},

\isakhan:  {
	q.mFX.pxChain.add('0OnePolBal', 1);
	q.mFX.pxChain.add('1holz', 0.5);
	q.mFX.pxChain.add('1ixiDist', 0.18);
    //q.mFX.pxChain.add('4ixiVerb', 0.125);
	q.mFX.pxChain.add('5LPF', 0.6);
	//q.mFX.pxChain.add('7Delay', 0.125);
	q.mFX.pxChain.remove('0_DBComp');


	q.mFX.pxChain.proxy.set('delayTime1', 0.42, 'delayTime2', 0.76, 'wet130', 0.6, 'combdecay', 6.8, 'wet20', 1, 'wet70', 0.18, 'wet150', 0.125, 'pregain', 1.46, 'wet30', 1, 'freqL', 700.0, 'wet170', 1, 'ixivAmp', 0.25, 'wet110', 0.125, 'ampLimit', 0.74, 'apDecay', 5.678, 'postgain', 1.0, 'dFreq', 2200, 'llag', 2.0, 'fadeTime', 3, 'predelay', 0.2, 'wet10', 1.0, 'mod', 0.6);

	q.ndefs.do{|nd, i|
		nd.vol_( #[ 0.25, 0.25, 0.4, 0.1][i])

	};
}
)[q.me].value;


/*
{
	q.mFX.pxChain.add('3ring', 0.1);
	q.mFX.pxChain.add('5LPF', 0.1);
}
*/