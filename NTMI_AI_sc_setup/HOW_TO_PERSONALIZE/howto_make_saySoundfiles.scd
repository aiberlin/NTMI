// How the soundfiles for granbuf were made:
/* needs the Quark say, which is macOS only
if (Quarks.installed.any { |qk| qk.name == "say" }.not) {
	Quarks.install("say");
};
*/
// make the soundfiles
[ "Airborne_Instruments", "nUFO", "N_T_M_I" ].do { |txt|
	SayBuf.prepare((text: txt, lang: \en))
};
// find them here - copy them to where you need them
SayBuf.dir.openOS;

