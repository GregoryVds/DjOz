\define TestVector

local
   Testing = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   \insert /Users/Greg/Desktop/Projet2014/code/note.oz

   % ExtendNote
   {Testing.assertEqual ExtendNote a3      note(nom:a octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote c#2     note(nom:c octave:2 alteration:'#')}
   {Testing.assertEqual ExtendNote b3      note(nom:b octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote d3      note(nom:d octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote c       note(nom:c octave:4 alteration:none)}
   {Testing.assertEqual ExtendNote silence note(nom:silence octave:4 alteration:none)}

   % DistanceFromA
   {Testing.assertEqual DistanceFromA note(nom:a octave:3 alteration:none) 0}
   {Testing.assertEqual DistanceFromA note(nom:c octave:2 alteration:'#')  ~8}
   {Testing.assertEqual DistanceFromA note(nom:b octave:3 alteration:none) 2}
   {Testing.assertEqual DistanceFromA note(nom:d octave:3 alteration:none) ~7}

   % Hauteur
   {Testing.assertEqual Hauteur a     0}
   {Testing.assertEqual Hauteur e    ~5}
   {Testing.assertEqual Hauteur b     2}
   {Testing.assertEqual Hauteur b3  ~10}
   {Testing.assertEqual Hauteur d#1 ~42}
   {Testing.assertEqual Hauteur a#4   1}
   {Testing.assertEqual Hauteur silence silence}

   % ToEchantillon
   {Testing.assertEqual ToEchantillon d#2      echantillon(hauteur:~30  duree:1.0 instrument:none)}
   {Testing.assertEqual ToEchantillon a        echantillon(hauteur:0    duree:1.0 instrument:none)}
   {Testing.assertEqual ToEchantillon d2       echantillon(hauteur:~31  duree:1.0 instrument:none)}
   {Testing.assertEqual ToEchantillon silence  silence(duree:1.0)}
in
   {Browse doneTesting}
end
\undef TestNote