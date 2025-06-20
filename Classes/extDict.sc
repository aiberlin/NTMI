/*
this is for improving Object Modeling style.

~dict = (blink: { |dict, testarg| }, blank: { }, blonk: (boing: { |dict, bongo| }), klong: 123 );

~dict.skeys.cs;
~dict.printSKeys;

~dict.printInterface("~dict.", 0);
~dict.printInterface("~dict.", 1);

NTMI.printInterface("NTMI.", 0);

ToDo:
support keys that do begin with a lowercase letter,
(7: [1, 2, 3])
should become:
dict[7], not dict.7
*/

+ Dictionary {
	skeys {
		var keys = this.keys(Array);
		try { keys.sort };
		^keys
	}
	printSKeys { |prefix = ""|
		^this.skeys.do { |key|
			(prefix ++ key.cs).postln;
		}
	}

	printInterface { | prefix = "dict.", maxLevel = 2 |
		this.skeys.do { |key|
			var codeStr = (prefix ++ key);
			var val = this.at(key);
			var arglist, argNames;

			case { val.isKindOf(Function) } {
				arglist = "";
				argNames = (val.def.argNames ? []).drop(1);

				if (argNames.size > 0) {
					arglist = "(" ++ argNames.collect { |name|
						name.asString ++ ": ,"
					}.join(" ").drop(-1) + ")";
				};
				codeStr = codeStr ++ ".value" ++ arglist ++ ";"
			};
			(codeStr + "//" + val.class).postln;

			// recur if Dictionary:
			if (val.isKindOf(Dictionary) and: (maxLevel > 0)) {
				val.printInterface("	" ++ codeStr ++ ".", maxLevel - 1);
			}
		}
	}
}

