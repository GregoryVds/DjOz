\define TestVector

local
   CWD         = {Property.condGet 'testcwd' '/Users/Greg/Desktop/Projet2014/'}
   [Projet]    = {Link [CWD#'Projet2014_mozart2.ozf']}
   Note        = \insert /Users/Greg/Desktop/Projet2014/src/note.oz
   ListHelpers = \insert /Users/Greg/Desktop/Projet2014/lib/list_helpers.oz
   Test        = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   \insert /Users/Greg/Desktop/Projet2014/src/vector.oz
   
   % Repeat
   {Test.assertEqual Repeat [[0.1 0.2 0.3] 1] [0.1 0.2 0.3]}
   {Test.assertEqual Repeat [[0.1 0.2 0.3] 2] [0.1 0.2 0.3 0.1 0.2 0.3]}
   
   % Clip
   {Test.assertEqual Clip [nil 0.2 0.3] nil}
   {Test.assertEqual Clip [[0.1 0.2 0.3] 0.15 0.25] [0.15 0.2 0.25]}
   {Test.assertEqual Clip [[0.1 0.2 0.3] 0.25 0.25] [0.25 0.25 0.25]}
   {Test.assertEqual Clip [[0.1 0.2 0.3] 0.05 0.50] [0.1 0.2 0.3]}
  
   % Fondu
   {Test.assertEqual Fondu [[0.1 0.2 0.3] 0.0 0.0 44100] [0.1 0.2 0.3]}
   {Test.assertEqual Fondu [[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1] 0.5 0.5 10] [0.0 0.025 0.05 0.075 0.1 0.1 0.075 0.05 0.025 0.0]}
   {Test.assertEqual Fondu [[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1] 0.5 0.0 10] [0.0 0.025 0.05 0.075 0.1 0.1 0.1 0.1 0.1 0.1]}
   {Test.assertEqual Fondu [[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1] 0.0 0.5 10] [0.1 0.1 0.1 0.1 0.1 0.1 0.075 0.05 0.025 0.0]}

   % Repeter
   {Test.assertEqual RepeatUpToDuration [nil 1.0 44100] nil}
   {Test.assertEqual Length [{RepeatUpToDuration [0.1 0.2 0.3] 0.001 44100}] 44}
   {Test.assertEqual RepeatUpToDuration [[0.1 0.2 0.3] 0.0 44100] nil}

   % Multiply
   {Test.assertEqual Multiply [[0.2 0.4] 0.5] [0.1 0.2]}
   {Test.assertEqual Multiply [[~0.2 0.4] 0.5] [~0.1 0.2]}

   % Add
   {Test.assertEqual Add [[1 2 3] [7 8]] [8 10 3]}
   {Test.assertEqual Add [[7 8] [1 2 3]] [8 10 3]}
   {Test.assertEqual Add [[~7 8] [1 ~2 ~3]] [~6 6 ~3]}
   {Test.assertEqual Add [[1 3] [7 6]] [8 9]}
   {Test.assertEqual Add [[1 2 3] nil] [1 2 3]}
   {Test.assertEqual Add [nil [1 2 3]] [1 2 3]}
   {Test.assertEqual Add [nil nil] nil}

   % Merge
   {Test.assertEqual Merge [[0.5#[0.1 0.2 0.3] 0.3#[0.1 0.2 0.3] 0.2#[0.1 0.2 0.3]]] [0.1 0.2 0.3]}
   {Test.assertEqual Merge [[0.4#[0.1 0.2 0.3] 0.4#[0.5 ~0.2 ~0.3] 0.2#[0.7 0.9 ~0.9]]] [0.38 0.18 ~0.18]}
   {Test.assertEqual Merge [[0.4#[0.1 0.2 0.3] 0.4#[0.5 ~0.2 ~0.3]]] [0.24 0.0 0.0]}
   {Test.assertEqual Merge [[1.0#[0.1 0.2 0.3]]] [0.1 0.2 0.3]}
   {Test.assertEqual Merge [[0.4#nil 0.6#[0.5 ~0.2 ~0.3]]] [0.3 ~0.12 ~0.18]}
   {Test.assertEqual Merge [[0.4#nil 0.6#nil]] nil}
   {Test.assertEqual Merge [nil] nil}

   % FonduEnchaine
   {Test.assertEqual FonduEnchaine [[0.5 0.5 0.5] [0.5 0.5 0.5] 3.0 1] [0.5 0.5 0.5]}
   {Test.assertEqual FonduEnchaine [[0.2 0.4 0.6 0.8 0.2 0.7 0.4] [~0.5 ~0.6 0.4 0.2] 3.0 1] [0.2 0.4 0.6 0.8 0.2 0.05 0.4 0.2]}
   {Test.assertEqual FonduEnchaine [[0.2 0.4 0.6 0.8] [~0.5 ~0.6 0.4 0.2 0.3 ~0.5] 3.0 1] [0.2 0.4 0.0 0.4 0.2 0.3 ~0.5]}
   {Test.assertEqual FonduEnchaine [nil [0.5 0.5 0.5] 0.0 1] [0.5 0.5 0.5]}
   {Test.assertEqual FonduEnchaine [[0.5 0.5 0.5] nil 0.0 1] [0.5 0.5 0.5]}

   % Couper
   {Test.assertEqual Couper [[0.5 0.5 0.5] ~1.0 4.0 1] [0.0 0.5 0.5 0.5 0.0]}
   {Test.assertEqual Couper [[0.5 0.5 0.5]  0.0 4.0 1] [0.5 0.5 0.5 0.0]}
   {Test.assertEqual Couper [[0.5 0.5 0.5] ~2.0 3.0 1] [0.0 0.0 0.5 0.5 0.5]}
   {Test.assertEqual Couper [[0.1 0.2 0.3 0.4 0.5] 1.0 4.0 1] [0.2 0.3 0.4]}
   {Test.assertEqual Couper [nil 1.0 4.0 1] [0.0 0.0 0.0]}
   {Test.assertEqual Couper [[0.5 0.5 0.5] ~5.0 ~2.0 1] [0.0 0.0 0.0]}
   {Test.assertEqual Couper [[0.5 0.5 0.5]  5.0  8.0 1] [0.0 0.0 0.0]}

   % Echo
   {Test.assertEqual Echo [[0.2 0.4 0.6] 4.0  3  1.0  1] [0.05 0.1 0.15 0.0 0.05 0.1 0.15 0.0 0.05 0.1 0.15 0.0 0.05 0.1 0.15]}
   {Test.assertEqual Echo [[1.0]         2.0  1  2.0  1] [(1.0/3.0) 0.0 (2.0/3.0)]}
   {Test.assertEqual Echo [[1.0]         2.0  2  2.0  1] [(1.0/7.0) 0.0 (2.0/7.0) 0.0 (4.0/7.0)]}
   {Test.assertEqual Echo [[1.0]         2.0  2  0.5  1] [(1.0/1.75) 0.0 (0.5/1.75) 0.0 (0.25/1.75)]}
   {Test.assertEqual Echo [[1.0]         2.0  2  0.5  1] [(1.0/1.75) 0.0 (0.5/1.75) 0.0 (0.25/1.75)]}
   {Test.assertEqual Echo [[0.2 0.4 0.6] 1.0  2  0.4  1] [(0.2/1.56) ((0.4+0.2*0.4)/1.56) ((0.6+0.4*0.4+0.2*0.16)/1.56) ((0.6*0.4+0.4*0.16)/1.56) (0.6*0.16/1.56)]}
   {Test.assertEqual Echo [[0.2 0.4 0.6] 0.0  3  0.4  1] [0.2 0.4 0.6]}
   {Test.assertEqual Echo [[0.2 0.4 0.6] 1.0  0  0.4  1] [0.2 0.4 0.6]}
   {Test.assertEqual Echo [[0.2 0.4 0.6] 1.0  2  0.0  1] [0.2 0.4 0.6 0.0 0.0]} 
   {Test.assertEqual Echo [nil           1.0  3  1.0  1] [0.0 0.0 0.0]}
   {Test.assertEqual Echo [nil           2.0  3  1.0  1] [0.0 0.0 0.0 0.0 0.0 0.0]}

    % FilePath
   {Test.assertEqual FilePath [note(nom:a octave:3 alteration:none) woody]      {VirtualString.toAtom CWD#'wave/instruments/woody_a3.wav'}}
   {Test.assertEqual FilePath [note(nom:a octave:3 alteration:'#') woody]       {VirtualString.toAtom CWD#'wave/instruments/woody_a3#.wav'}}
   {Test.assertEqual FilePath [note(nom:g octave:2 alteration:'#') '8bit_stab'] {VirtualString.toAtom CWD#'wave/instruments/8bit_stab_g2#.wav'}}

   % VectorFromInstrument
   {Test.assertEqual Length [{VectorFromInstrument woody ~10 1.0 44100}] 44100}
   {Test.assertEqual Length [{VectorFromInstrument woody ~10 2.0 44100}] 88200}
   {Test.assertEqual Length [{VectorFromInstrument woody   0 0.5 44100}] 22050}
   
   % Build
   local Vector1 Vector2 in
      Vector1 = {Build 440.0 0.001 44100}
      {Test.assertEqual Length [Vector1] 44}
      {Test.assertEqual Nth [Vector1 10] 0.293316}
      {Test.assertEqual Nth [Vector1 35] 0.405969}
      Vector2 = {Build 783.99 0.005 44100}
      {Test.assertEqual Length [Vector2] 220}
      {Test.assertEqual Nth [Vector2 10] 0.449393}
   end

   % VectorFromVoice
   local Vector1 in
      Vector1 = {VectorFromVoice [echantillon(hauteur:10 duree:0.00025 instrument:none) echantillon(hauteur:~2 duree:0.0005 instrument:none)] 44100}
      {Test.assertEqual Length [Vector1] 33}
      {Test.assertEqual Nth [Vector1 10] 0.449393}
      {Test.assertEqual Nth [Vector1 20] 0.240876}
   end
   
in
   {Browse doneTestingVector}
end
\undef TestVector