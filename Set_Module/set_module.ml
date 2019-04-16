let printset item = Printf.printf "%s\n" item 

module Mod = Set.Make (String);;
let setMod = Mod.empty in
	let setMod = Mod.add "str1" setMod in
	let setMod = Mod.add "str2" setMod in
		Mod.iter printset setMod