// Installing NTMI and connecting it to flatcat osc:

// if you don't have NTMI installed:
Quarks.install("NTMI");

// if you do, get the latest version:
Quark("NTMI").update;
// and update its dependencies too:
Quark("NTMI").dependencies.do(_.update);

thisProcess.recompile;

// this should start the default NTMI setup:
NTMI.run;
// and end with a fullscreen GUI called ntmi_MainStage!
// if not, try throwing away the NTMI quark, and reinstall it!
// same for the dependencies if they do not update properly.



// if all is well, try playing with the NTMI:
// click on one of the 4 left-hand slots -> should play a sound
// on its rightside popup, try selecting different sound presets
// on its leftside popup, try selecting different sound processes

// on the left row of buttons - Butz:
// click on inphlux,
// and try playing on the XY field -> sound should change!
// then try mouse-drawing on the xyz etc field ->


// when all seems to work, run the flatcat setup:

// flatcat files in the NTMI setup are here:
(NTMI.dir.setup +/+ "SpecialUses/flatcat/").openOS;
// copy them to NTMI user folder here:
NTMI.dir.user.openOS;

// open and run the whole file;
// and adapt as desired!
(NTMI.dir.user +/+ "flatcat2NTMI_better.scd").openOS;

// to see how the parameters change:
Butz(\NTMI).run(\slotSounds);
