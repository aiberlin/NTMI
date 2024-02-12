/***  forward all messages to NTMI setup,
so a second system gets the same messages.
only forward the relative ones to avoid jumps?
***/

// examples:
NTMI.slots.playAt(0)
-> [\NTMI, \slots, \playAt, 0]

NTMI.printInterface("NTMI.", 0);

MFdef(\mainPre)

[ mainPre, mainPreStep, mainVol, mainVolGet, mainVolGetUni, mainVolSetUni, mainVolStep, ndefVolStep, setRelInf ]

NTMI.incZoom.value(inc:  ); // Function
NTMI.setZoom.value(val:  ); // Function

NTMI.bin // Event
NTMI.flatcat // Event
NTMI.inph // Event
NTMI.keypl // Event
NTMI.mfx // Event
NTMI.mkmix // Event
NTMI.nUFO // Event
NTMI.nanoKtl // Event
NTMI.ndef // Event
NTMI.pre // Event
NTMI.process // Event
NTMI.ro // Event
NTMI.slots // Event
NTMI.wse // Event

