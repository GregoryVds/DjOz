\define TestVector

local
   Testing = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   \insert /Users/Greg/Desktop/Projet2014/code/vector.oz
   /*
   % RepeatTimes
   {Testing.assertEqual Repeat [nil 2] nil}
   {Testing.assertEqual Repeat [[0.1 0.2 0.3] 0] nil}
   {Testing.assertEqual Repeat [[0.1 0.2 0.3] 1] [0.1 0.2 0.3]}
   {Testing.assertEqual Repeat [[0.1 0.2 0.3] 2] [0.1 0.2 0.3 0.1 0.2 0.3]}
   {Testing.assertEqual Repeat [[0.1 0.2 0.3] 3] [0.1 0.2 0.3 0.1 0.2 0.3 0.1 0.2 0.3]}

   % RepeatUpToElementsCount
   {Testing.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 0] nil}
   {Testing.assertEqual RepeatUpToElementsCount [nil 3] nil}
   {Testing.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 1] [0.1]}
   {Testing.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 3] [0.1 0.2 0.3]}
   {Testing.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 4] [0.1 0.2 0.3 0.1]}
   {Testing.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 5] [0.1 0.2 0.3 0.1 0.2]}

   % Repeter
   {Testing.assertEqual RepeatUpToDuration [nil 1.0 44100] nil}
   {Testing.assertEqual Length [{RepeatUpToDuration [0.1 0.2 0.3] 0.001 44100}] 44}
   {Testing.assertEqual RepeatUpToDuration [[0.1 0.2 0.3] 0.0 44100] nil}

   % Clip
   {Testing.assertEqual Clip [nil 0.2 0.3] nil}
   {Testing.assertEqual Clip [[0.1 0.2 0.3] 0.15 0.25] [0.15 0.2 0.25]}
   {Testing.assertEqual Clip [[0.1 0.2 0.3] 0.25 0.25] [0.25 0.25 0.25]}
   {Testing.assertEqual Clip [[0.1 0.2 0.3] 0.05 0.50] [0.1 0.2 0.3]}
 
   % Linear Increase
   % {Testing.assertEqual LinearIncrease [[3.0 3.0 3.0]] [1.0 2.0 3.0]} %TODO: Check this is the right way to do it
   % {Testing.assertEqual LinearIncrease [[3.0 9.0 6.0]] [1.0 6.0 6.0]}
   % {Testing.assertEqual LinearIncrease [[3.0]] [3.0]}
   % {Testing.assertEqual LinearIncrease [nil] nil}
  
   % Fondu
   {Testing.assertEqual Fondu [[0.1 0.2 0.3] 0.0 0.0 44100] [0.1 0.2 0.3]}
   {Testing.assertEqual Fondu [[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1] 0.5 0.5 10] [0.0 0.025 0.05 0.075 0.1 0.1 0.075 0.05 0.025 0.0]}
   {Testing.assertEqual Fondu [[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1] 0.5 0.0 10] [0.0 0.025 0.05 0.075 0.1 0.1 0.1 0.1 0.1 0.1]}
   {Testing.assertEqual Fondu [[0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1] 0.0 0.5 10] [0.1 0.1 0.1 0.1 0.1 0.1 0.075 0.05 0.025 0.0]}

   % Multiply
   {Testing.assertEqual Multiply [[0.2 0.4] 0.5] [0.1 0.2]}
   {Testing.assertEqual Multiply [[~0.2 0.4] 0.5] [~0.1 0.2]}

   % Add
   {Testing.assertEqual Add [[1 2 3] [7 8]] [8 10 3]}
   {Testing.assertEqual Add [[7 8] [1 2 3]] [8 10 3]}
   {Testing.assertEqual Add [[~7 8] [1 ~2 ~3]] [~6 6 ~3]}
   {Testing.assertEqual Add [[1 3] [7 6]] [8 9]}
   {Testing.assertEqual Add [[1 2 3] nil] [1 2 3]}
   {Testing.assertEqual Add [nil [1 2 3]] [1 2 3]}
   {Testing.assertEqual Add [nil nil] nil}

   % Merge
   {Testing.assertEqual Merge [[0.5#[0.1 0.2 0.3] 0.3#[0.1 0.2 0.3] 0.2#[0.1 0.2 0.3]]] [0.1 0.2 0.3]}
   {Testing.assertEqual Merge [[0.4#[0.1 0.2 0.3] 0.4#[0.5 ~0.2 ~0.3] 0.2#[0.7 0.9 ~0.9]]] [0.38 0.18 ~0.18]}
   {Testing.assertEqual Merge [[1.0#[0.1 0.2 0.3]]] [0.1 0.2 0.3]}
   {Testing.assertEqual Merge [[0.4#nil 0.6#[0.5 ~0.2 ~0.3]]] [0.3 ~0.12 ~0.18]}
   {Testing.assertEqual Merge [[0.4#nil 0.6#nil]] nil}
   {Testing.assertEqual Merge [nil] nil}

   % FonduEnchaine
   {Testing.assertEqual FonduEnchaine [[0.5 0.5 0.5] [0.5 0.5 0.5] 3.0 1] [0.5 0.5 0.5]}
   {Testing.assertEqual FonduEnchaine [[0.2 0.4 0.6 0.8 0.2 0.7 0.4] [~0.5 ~0.6 0.4 0.2] 3.0 1] [0.2 0.4 0.6 0.8 0.2 0.05 0.4 0.2]}
   {Testing.assertEqual FonduEnchaine [[0.2 0.4 0.6 0.8] [~0.5 ~0.6 0.4 0.2 0.3 ~0.5] 3.0 1] [0.2 0.4 0.0 0.4 0.2 0.3 ~0.5]}
   {Testing.assertEqual FonduEnchaine [nil [0.5 0.5 0.5] 0.0 1] [0.5 0.5 0.5]}
   {Testing.assertEqual FonduEnchaine [[0.5 0.5 0.5] nil 0.0 1] [0.5 0.5 0.5]}

   % Couper
   % fun {Couper Vector Start End SamplingRate}
   {Testing.assertEqual Couper [[0.5 0.5 0.5] ~1.0 4.0 1] [0.0 0.5 0.5 0.5 0.0]}
   {Testing.assertEqual Couper [[0.5 0.5 0.5] 0.0 4.0 1] [0.5 0.5 0.5 0.0]}
   {Testing.assertEqual Couper [[0.5 0.5 0.5] ~2.0 3.0 1] [0.0 0.0 0.5 0.5 0.5]}
   {Testing.assertEqual Couper [[0.1 0.2 0.3 0.4 0.5] 1.0 4.0 1] [0.2 0.3 0.4]}
   {Testing.assertEqual Couper [nil 1.0 4.0 1] [0.0 0.0 0.0]}
   {Testing.assertEqual Couper [[0.5 0.5 0.5] ~5.0 ~2.0 1] [0.0 0.0 0.0]}
   {Testing.assertEqual Couper [[0.5 0.5 0.5] 5.0 8.0 1] [0.0 0.0 0.0]}
   */

   % Echo
   % fun {Echo Vector Delay Repetition Decay SamplingRate} 
   {Testing.assertEqual Echo [[0.2 0.4 0.6] 4.0  3  1.0  1] [0.05 0.1 0.15 0.0 0.05 0.1 0.15 0.0 0.05 0.1 0.15 0.0 0.05 0.1 0.15]}
   {Testing.assertEqual Echo [[1.0]         2.0  1  2.0  1] [(1.0/3.0) 0.0 (2.0/3.0)]}
   {Testing.assertEqual Echo [[1.0]         2.0  2  2.0  1] [(1.0/7.0) 0.0 (2.0/7.0) 0.0 (4.0/7.0)]}
   {Testing.assertEqual Echo [[1.0]         2.0  2  0.5  1] [(1.0/1.75) 0.0 (0.5/1.75) 0.0 (0.25/1.75)]}
   {Testing.assertEqual Echo [[1.0]         2.0  2  0.5  1] [(1.0/1.75) 0.0 (0.5/1.75) 0.0 (0.25/1.75)]}
   {Testing.assertEqual Echo [[0.2 0.4 0.6] 1.0  2  0.4  1] [(0.2/1.56) ((0.4+0.2*0.4)/1.56) ((0.6+0.4*0.4+0.2*0.16)/1.56) ((0.6*0.4+0.4*0.16)/1.56) (0.6*0.16/1.56)]}
   {Testing.assertEqual Echo [[0.2 0.4 0.6] 0.0  3  0.4  1] [0.2 0.4 0.6]}
   {Testing.assertEqual Echo [[0.2 0.4 0.6] 1.0  0  0.4  1] [0.2 0.4 0.6]}
   {Testing.assertEqual Echo [[0.2 0.4 0.6] 1.0  2  0.0  1] [0.2 0.4 0.6 0.0 0.0]} 
   {Testing.assertEqual Echo [nil           1.0  3  1.0  1] [0.0 0.0 0.0]}
   {Testing.assertEqual Echo [nil           2.0  3  1.0  1] [0.0 0.0 0.0 0.0 0.0 0.0]}
in
   {Browse doneTesting}
end
\undef TestVector