/*
~dict = (blink: { |dict, testarg| }, blank: { }, blonk: (boing: { |dict, bongo| }), klong: 123 );

~dict.skeys.cs;
~dict.printSKeys;

~dict.printInterface("~dict.");

NTMI.printInterface("NTMI.");

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
	printInterface { | prefix = "dict." |
		this.skeys.do { |key|
			var codeStr = (prefix ++ key);
			var val = this.at(key);

			case { val.isKindOf(Function) } {
				var arglist = "";
				var argNames = (val.def.argNames ? []).drop(1);

				if (argNames.size > 0) {
					arglist = "(" ++ argNames.collect { |name|
						name.asString ++ ": ,"
					}.join(" ").drop(-1) + ")";
				};
				codeStr = codeStr ++ ".value" ++ arglist ++ ";"
			};
			(codeStr + "//" + val.class).postln;

			// recur if Dictionary:
			if (val.isKindOf(Dictionary)) {
				val.printInterface("	" ++ codeStr ++ ".");

			}
		}
	}
}

