\define TestUtilities

local
   Test = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   \insert /Users/Greg/Desktop/Projet2014/lib/utilities.oz

   % Position in list
   {Test.assertEqual PositionInList [a [a b c]] 0}
   {Test.assertEqual PositionInList [b [a b c]] 1}
   {Test.assertEqual PositionInList [d [a b c]] ~1}
   
in
   {Browse doneTestingUtilities}
end
\undef TestUtilities