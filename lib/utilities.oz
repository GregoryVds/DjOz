\ifndef TestUtilities
local
\endif

   % Returns the position of an element in a list (starting at 0).
   % Args: Elem - Element to loopup in the list
   %       List - List to be searched in
   % Return: position of element in the list as integer starting at 0 or -1 if not found.
   % Complexity: O(n) where n is the size of the list
   fun {PositionInList Elem List}
      fun {PositionInListAcc List Acc}
	 case List
	 of nil then ~1
	 [] H|T then
	    if H==Elem then Acc else {PositionInListAcc T Acc+1} end
	 end
      end
   in
      {PositionInListAcc List 0}
   end

\ifndef TestUtilities
in
   'export'(positionInList: PositionInList)
end
\endif