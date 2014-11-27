\ifndef TestVector
local
\endif
  
   % Repeats a vector X times
   % Arg: a vector and an integer
   % Return: the vector passed in argument repeated X times
   fun {RepeatTimes Vector Times}
      fun {Repeat Counter}
	 if (Counter==0) then
	    nil
	 else
	    Vector | {RepeatTimes Vector Times-1}
	 end
      end
   in
      {Flatten {Repeat Times}}
   end

   
   % Repeats a vector up to max X elements
   % Arg: a vector and the max number of elements to be contained (natural)
   % Return: the repeated vector
   fun {RepeatUpToElementsCount Vector ElementsCount}
      BasicRepeats Remaining
      VectorSize = {Length Vector}
   in
      if VectorSize==0 then
	 nil
      else
	 BasicRepeats = ElementsCount div VectorSize
	 Remaining    = ElementsCount mod VectorSize
	 {Flatten [{RepeatTimes Vector BasicRepeats} {List.take Vector Remaining}]}
      end
   end

   
   % Repeats a vector X times or up to a duration
   % Arg: a vector, the factor which is a positive or integer >=0, and the sampling rate (natural)
   % Return: a repeated vector
   fun {Repeter Vector Factor SamplingRate}
      if {IsFloat Factor} then
	 {RepeatUpToElementsCount Vector {FloatToInt Factor*{IntToFloat SamplingRate}}}
      else
	 {RepeatTimes Vector Factor}
      end
   end


   % Clip values in the vector so that all values are >= Low and <= High
   % Arg: a vector, the low bound as float, the high bound as float.
   % Return: a clipped vector
   fun {Clip Vector Low High}
      fun {ClipElement Element}
	 {Max {Min Element High} Low}
      end
   in
      if (Low > High) then
	 raise invalidArgument(ClipElement 'High must be >= Low') end
      else	 
	 {Map Vector ClipElement}
      end
   end

   /*
   % Multiply each values of a vector by index/length to simulate a linear increase
   % Arg: a vector
   % Return: a vector
   %fun {LinearIncrease Vector}
      Count = {Length Vector}
      fun {Fade Vector Position}
	 case Vector
	 of nil then nil
	 [] H|T then ({IntToFloat Position}/{IntToFloat Count})*H | {Fade T Position + 1}
	 end	 
      end
   in
      {Fade Vector 1}
   end
*/
   
   fun {Fondu Vector Ouverture Fermeture SamplingRate}
      VectorLength = {Length Vector}
      OuvertureElementsCount = {FloatToInt Ouverture*{IntToFloat SamplingRate}}
      FermetureElementsCount = {FloatToInt Fermeture*{IntToFloat SamplingRate}}      
      fun {RecFondu Vector PositionFromHead PositionFromTail}
	 case Vector
	 of nil then nil
	 [] H|T then Factor in
	    Factor = if (PositionFromHead =< OuvertureElementsCount) then
			{IntToFloat PositionFromHead}/{IntToFloat OuvertureElementsCount}
		     elseif (PositionFromTail =< FermetureElementsCount) then
			{IntToFloat PositionFromTail}/{IntToFloat FermetureElementsCount} 
		     else
			1.0
		     end
	    (Factor*H) | {RecFondu T (PositionFromHead+1) (PositionFromTail-1)}
	 end          
      end
   in
      {RecFondu Vector 1 VectorLength}
   end

   fun {Multiply Vector Factor}
      {Map Vector fun {$ Elem} Elem * Factor end } 
   end

   fun {Add Vector1 Vector2}
      Length1 = {Length Vector1}
      Length2 = {Length Vector2}
      Longest  = if Length1 > Length2 then Vector1 else Vector2 end
      Shortest = if Length1 > Length2 then Vector2 else Vector1 end
      fun {RecAdd LongestV ShortestV}
	 case LongestV
	 of nil then nil
	 [] H|T then
	    case ShortestV
	    of nil   then H | {RecAdd T nil}  
	    [] H2|T2 then (H+H2) | {RecAdd T T2}  
	    end
	 end  	    
      end
   in
      {RecAdd Longest Shortest}
   end
   
      
   /*fun {Merge VectorsToMerge}  
   end
   {Testing.assertEqual Merge [0.5#[0.1 0.2 0.3] 0.3#[0.1 0.2 0.3] 0.2#[0.1 0.2 0.3]] [expected]}
*/
\ifndef TestVector
in
  'export'(repeter:Repeter clip:Clip fondu:Fondu)
end
\endif