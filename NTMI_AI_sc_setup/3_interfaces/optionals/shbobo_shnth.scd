/*

SHBOBO SHNTH for NTMI:

For now only the 4 piezos and 2 antenas inputs are used to influence Influx

*/
NTMI.shbobo_shnth = NTMI.shnth ? ();

NTMI.shbobo_shnth.influxMode = \setRel;
///// look for wired and wireless
if (MKtlLookup.findByIDInfo("SHNTH_SHBOBO").size == 1) {
	"*** Shbobo Shnth found!".postln;
	MKtl.all['shbobo_shnth'].free;
	MKtl('shbobo_shnth', "shbobo-shnth");
};

if (MKtl('shbobo_shnth').isNil) {
	"No shbobo shnth found - creating virtual one.".postln;
	MKtl.all['shbobo_shnth'].free;
	MKtl('shbobo_shnth', "*dual-analog-4");
};
"*** Shbobo Shnth loading ...".postln;

MKtl('shbobo_shnth').elementsDict.do { |el| el.action.enable(\post) };
MKtl('shbobo_shnth').elementsDict.do { |el| el.action.disable(\post) };

MKtl('shbobo_shnth').addNamed(\influx,
	(MKtl('shbobo_shnth').elAt(\pz) ++ MKtl('shbobo_shnth').elAt(\an)).flat
);

NTMI.shbobo_shnth.vols = ();
NTMI.shbobo_shnth.selectedSlots = List[];

NTMI.shbobo_shnth.zoom = 0.5;

MKtl('shbobo_shnth').elAt(\influx).do { |el, i|
	var inIndex = [9, 11, 12, 13, 14,15][i];
	el.elemDesc.label = "infl" + inIndex;
	el.action = { |el|
		if (NTMI.shbobo_shnth.influxMode == \setAbs) {
			NTMI.inphlux.set(inIndex, el.value.unibi);
		} {
			MFdef(\setRelInf).(
				inIndex,
				(el.value - el.prevValue),
				NTMI.zoom * NTMI.shbobo_shnth.zoom
			);
		}
	}
};

MKtl('shbobo_shnth');
