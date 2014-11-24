local
   % Return the position of an element in a list.
   % Arg: element to be matched and a list
   % Return: position in list starting at 0 and -1 if not found
   fun {PositionInList Elem List}
      fun {PositionInListAcc List Acc}
	 case List
	 of nil then 0
	 [] H|T then if H==Elem then Acc else {PositionInListAcc T Acc+1} end
	 end
      end
   in
      {PositionInListAcc List 1}
   end
   \ifdef Debug
   {Testing.assertEqual PositionInList [a [a b c]] 1}
   {Testing.assertEqual PositionInList [b [a b c]] 2}
   {Testing.assertEqual PositionInList [d [a b c]] 0}
   \endif
   
in
   'export'(positionInList:PositionInList)
end