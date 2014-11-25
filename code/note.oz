% \define DebugNote
local
   % Convert a note from short notation to extended notation
   % Arg: note in short notation (a, b3, b#4, silence)
   % Returns: a note in extended form like note(name:a octave:3 alteration:none)
   fun {ExtendNote Note}
      case Note
      of silence     then note(nom:silence octave:4 alteration:none)
      [] Name#Octave then note(nom:Name octave:Octave alteration:'#') 
      [] Atom        then
	 case {AtomToString Atom}
	 of [N]     then note(nom:{StringToAtom [N]} octave:4 alteration:none)
	 [] [N O]   then note(nom:{StringToAtom [N]} octave:{StringToInt [O]} alteration:none)
	 end
      end
   end
   \ifdef DebugNote
   {Testing.assertEqual ExtendNote a3      note(nom:a octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote c#2     note(nom:c octave:2 alteration:'#')}
   {Testing.assertEqual ExtendNote b3      note(nom:b octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote d3      note(nom:d octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote c       note(nom:c octave:4 alteration:none)}
   {Testing.assertEqual ExtendNote silence note(nom:silence octave:4 alteration:none)}
   \endif

   
   % Compute the distance of the extended note from A
   % Notes in order are c c# d d# e f f# g g# a a# b
   % distance = a_position - note_position
   % Arg: note in extended notation but not silence
   % Return: a distance as integer from -9 to +2 included
   fun {DistanceFromA ExtendedNote}
      case ExtendedNote.nom
      of c andthen ExtendedNote.alteration == '#' then ~8
      [] c then ~9
      [] d andthen ExtendedNote.alteration == '#' then ~6
      [] d then ~7
      [] e then ~5
      [] f andthen ExtendedNote.alteration == '#' then ~3
      [] f then ~4
      [] g andthen ExtendedNote.alteration == '#' then ~1
      [] g then ~2
      [] a andthen ExtendedNote.alteration == '#' then 1
      [] a then 0
      [] b then 2
      else raise wrongArgument(function:DistanceFromA arg:ExtendedNote) end
      end     
   end
   \ifdef DebugNote
   {Testing.assertEqual DistanceFromA note(nom:a octave:3 alteration:none) 0}
   {Testing.assertEqual DistanceFromA note(nom:c octave:2 alteration:'#')  ~8}
   {Testing.assertEqual DistanceFromA note(nom:b octave:3 alteration:none) 2}
   {Testing.assertEqual DistanceFromA note(nom:d octave:3 alteration:none) ~7}
   \endif
   
   
   % Count the number of half-steps of a note from note a4
   % halfs_steps = note_distance_from_A + octave_distance_to_4 * 12
   % Arg: note in short notation (a, b3, b#4)
   % Return: half-steps from a4 as integer (Z) or silence
   fun {Hauteur Note}
      ExtendedNote NoteDistance OctaveDistance
   in
      if Note==silence then silence
      else
	 ExtendedNote   = {ExtendNote Note}
	 NoteDistance   = {DistanceFromA ExtendedNote}
	 OctaveDistance = (ExtendedNote.octave - 4) * 12      
	 OctaveDistance+NoteDistance
      end
   end
   \ifdef DebugNote
   {Testing.assertEqual Hauteur a     0}
   {Testing.assertEqual Hauteur e    ~5}
   {Testing.assertEqual Hauteur b     2}
   {Testing.assertEqual Hauteur b3  ~10}
   {Testing.assertEqual Hauteur d#1 ~42}
   {Testing.assertEqual Hauteur a#4   1}
   {Testing.assertEqual Hauteur silence silence}
   \endif

   
   % Convert a note to an echantillon
   % Arg: note in short notation as argument (a, b3, b#4, silence)
   % Return: enchantillon of the form: echantillon(hauteur:73 duree:1.0 instrument:none)
   fun {ToEchantillon Note}
      case Note
      of silence then silence(duree:1.0)
      [] _       then echantillon(hauteur:{Hauteur Note} duree:1.0 instrument:none)
      end
   end
   \ifdef DebugNote
   {Testing.assertEqual ToEchantillon d#2      echantillon(hauteur:~30  duree:1.0 instrument:none)}
   {Testing.assertEqual ToEchantillon a        echantillon(hauteur:0    duree:1.0 instrument:none)}
   {Testing.assertEqual ToEchantillon d2       echantillon(hauteur:~31  duree:1.0 instrument:none)}
   {Testing.assertEqual ToEchantillon silence  silence(duree:1.0)}
   \endif
in
   'export'(toEchantillon:ToEchantillon hauteur:Hauteur)
end
\undef DebugNote