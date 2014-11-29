\ifndef TestVector
local
\endif
  
   % Repeats a vector X times
   % Arg: a vector and an integer
   % Return: the vector passed in argument repeated X times
   fun {Repeat Vector Times}
      fun {RecRepeat Counter Acc}
	 if (Counter==0) then Acc else {RecRepeat Counter-1 {Append Vector Acc}} end
      end
   in
      {RecRepeat Times nil}
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
	 {Flatten [{Repeat Vector BasicRepeats} {List.take Vector Remaining}]}
      end
   end

   
   % Repeats a vector X times or up to a duration
   % Arg: a vector, the factor which is a positive or integer >=0, and the sampling rate (natural)
   % Return: a repeated vector
   fun {RepeatUpToDuration Vector Duration SamplingRate}
      {RepeatUpToElementsCount Vector {FloatToInt Duration*{IntToFloat SamplingRate}}}
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
   
   fun {Fondu Vector Ouverture Fermeture SamplingRate}
      VectorLength = {Length Vector}
      OuvertureElementsCount = {FloatToInt Ouverture*{IntToFloat SamplingRate}}
      FermetureElementsCount = {FloatToInt Fermeture*{IntToFloat SamplingRate}}      
      fun {RecFondu Vector PositionFromHead PositionFromTail}
	 case Vector
	 of nil then nil
	 [] H|T then Factor in
	    Factor = if (PositionFromHead =< OuvertureElementsCount) then
			({IntToFloat PositionFromHead}-1.0)/({IntToFloat OuvertureElementsCount}-1.0)
		     elseif (PositionFromTail =< FermetureElementsCount) then
			({IntToFloat PositionFromTail}-1.0)/({IntToFloat FermetureElementsCount}-1.0)
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
   
   fun {Merge VectorsToMerge}
      fun {RecMerge VectorsToMerge Acc}
	 case VectorsToMerge
	 of nil then Acc
	 [] H|T then
	    case H of Intensity#Vector then {RecMerge T {Add Acc {Multiply Vector Intensity}}} end
	 end
      end
   in
      {RecMerge VectorsToMerge nil}
   end
   
   fun {FonduEnchaine Vector1 Vector2 Duration SamplingRate}
      V1Start V1Fondu V2Fondu V2End 
      FonduElements = {FloatToInt Duration*{IntToFloat SamplingRate}}
      {List.takeDrop Vector1 {Length Vector1}-FonduElements V1Start V1Fondu}
      {List.takeDrop Vector2 FonduElements V2Fondu V2End}      
      Mix = {Add {Fondu V1Fondu 0.0 Duration SamplingRate} {Fondu V2Fondu Duration 0.0 SamplingRate}}
   in
      {Append {Append V1Start Mix} V2End}
   end

   fun {Couper Vector Start End SamplingRate}
      SamplingFloat = {IntToFloat SamplingRate}
      IntervalStart = {FloatToInt Start*SamplingFloat}
      IntervalEnd   = {FloatToInt End*SamplingFloat}
      VectorLength  = {Length Vector}
      fun {Slice Vector Position Acc}
	 if (Position == IntervalEnd) then
	    {Reverse Acc}
	 elseif (Position < 0) then
	    {Slice Vector Position+1 (0.0|Acc)}
	 elseif ({And Position>=VectorLength Position>=IntervalStart}) then 
	    {Slice Vector Position+1 (0.0|Acc)}
	 else
	    if (Position < IntervalStart) then V in
	       V = case Vector
		   of nil then nil
		   [] _|T then T
		   end	  
	       {Slice V Position+1 Acc}
	    else
	       {Slice Vector.2 Position+1 (Vector.1|Acc)}
	    end 
	 end		 
      end 
   in
      {Slice Vector {Min IntervalStart 0} nil}
   end


   fun {Echo Vector Delay Repetition Decay SamplingRate} 
      BaseVectorDuration = {IntToFloat {Length Vector}}/{IntToFloat SamplingRate}
      fun {EchoRec Acc Repetition Counter IntensityDivisor}
	 if (Repetition==0) then
	    {Multiply Acc 1.0/IntensityDivisor}
	 else EchoedVector MixedVector EchoIntensity in
	    EchoedVector  = {Couper Vector ~{IntToFloat (Counter+1)}*Delay BaseVectorDuration SamplingRate}
	    EchoIntensity = {Pow Decay {IntToFloat Counter+1}}
	    MixedVector   = {Merge [1.0#Acc EchoIntensity#EchoedVector]}
	    {EchoRec MixedVector Repetition-1 Counter+1 IntensityDivisor+EchoIntensity}
	 end
      end
   in
      {EchoRec Vector Repetition 0 1.0}
   end
   
   
\ifndef TestVector
in
  'export'(repeat:Repeat repeatUpToDuration:RepeatUpToDuration clip:Clip fondu:Fondu merge:Merge fonduEnchaine:FonduEnchaine couper:Couper)
end
\endif