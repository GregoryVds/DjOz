% Author: VANDER SCHUEREN Gregory
% Date: December 2014

% Expose 3 helpers functions to work with lists
% positionInList:          returns the position of an element in a list (starting at 0)
% repeat:                  repeat a list X times
% repeatUpToElementsCount: repeat a list until it reaches a maximum number of elements and truncate the rest

\ifndef TestListHelpers
local
\endif

   % Returns the position of an element in a list (starting at 0)
   % Args: Elem - Element to loopup in the list
   %       List - List to be searched in
   % Return: position of element in the list as integer starting at 0 or -1 if not found
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


   % Repeat a list X times
   % Arg: List - a list
   %      Times - an integer (>=0) the gives the final number of repetitions
   % Return: the list passed in argument repeated X times. If X=0 then return nil
   % Complexity: O(n*m) where n is the length of the list and m the number of repetitions
   fun {Repeat List Times}
      fun {RecRepeat Counter Acc}
	 if (Counter==0) then Acc else {RecRepeat Counter-1 {Append List Acc}} end
      end
   in
      {RecRepeat Times nil}
   end

   
   % Repeat a list until it reaches a maximum number of elements and truncate the rest
   % Arg: L - a list
   %      ElementsCount - maximum number of elements as integer (>=0)
   % Return: the repeated list
   % Complexity: O(n) where n is ElementsCount
   fun {RepeatUpToElementsCount L ElementsCount}
      BasicRepeats Remaining
      ListSize = {Length L}
   in
      if ListSize==0 then nil
      else
	 BasicRepeats = ElementsCount div ListSize
	 Remaining    = ElementsCount mod ListSize
	 {Flatten [{Repeat L BasicRepeats} {List.take L Remaining}]}
      end
   end

   
\ifndef TestListHelpers
in
   'export'(positionInList:PositionInList repeat:Repeat repeatUpToElementsCount:RepeatUpToElementsCount)
end
\endif