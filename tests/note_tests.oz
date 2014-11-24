local
   Testing     = \insert /Users/Greg/Desktop/Projet2014/code/test.oz
   NoteMod     = \insert /Users/Greg/Desktop/Projet2014/code/note.oz
in
   {Testing.assertEqual ExtendNote a3      note(nom:a octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote c#2     note(nom:c octave:2 alteration:'#')}
   {Testing.assertEqual ExtendNote b3      note(nom:b octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote d3      note(nom:d octave:3 alteration:none)}
   {Testing.assertEqual ExtendNote c       note(nom:c octave:4 alteration:none)}
   {Testing.assertEqual ExtendNote silence note(nom:silence octave:4 alteration:none)}


end


