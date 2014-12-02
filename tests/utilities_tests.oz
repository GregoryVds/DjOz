\define TestUtilities

local
   Test = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   \insert /Users/Greg/Desktop/Projet2014/lib/utilities.oz

   % Position in list
   {Test.assertEqual PositionInList [a [a b c]] 0}
   {Test.assertEqual PositionInList [b [a b c]] 1}
   {Test.assertEqual PositionInList [d [a b c]] ~1}

   % Repeat
   {Test.assertEqual Repeat [nil 2] nil}
   {Test.assertEqual Repeat [[0.1 0.2 0.3] 0] nil}
   {Test.assertEqual Repeat [[0.1 0.2 0.3] 1] [0.1 0.2 0.3]}
   {Test.assertEqual Repeat [[0.1 0.2 0.3] 2] [0.1 0.2 0.3 0.1 0.2 0.3]}
   {Test.assertEqual Repeat [[0.1 0.2 0.3] 3] [0.1 0.2 0.3 0.1 0.2 0.3 0.1 0.2 0.3]}

   % RepeatUpToElementsCount
   {Test.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 0] nil}
   {Test.assertEqual RepeatUpToElementsCount [nil 3] nil}
   {Test.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 1] [0.1]}
   {Test.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 3] [0.1 0.2 0.3]}
   {Test.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 4] [0.1 0.2 0.3 0.1]}
   {Test.assertEqual RepeatUpToElementsCount [[0.1 0.2 0.3] 5] [0.1 0.2 0.3 0.1 0.2]}
   
in
   {Browse doneTestingUtilities}
end
\undef TestUtilities