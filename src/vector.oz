% Expose 9 fonctions that apply filters on musical vectors
% A musical vector is list of floats >= -1 and <= 1
% - repeat: repeat a musical vector X times
% - repeatUpToDuration: repeat a musical vector up to a fixed duration and truncate the rest
% - clip: clip a musical vector so that all its values are comprised in the specified interval

\ifndef TestVector
local
\endif

   
   % Repeat a musical vector X times
   % Arg: Vector - a musical vector
   %      Times - an integer (>=0) the gives the final number of repetitions.
   % Return: the vector passed in argument repeated X times. If X=0 then return nil.
   % Complexity: O(n*m) where n is the length of the vector and m the number of repetitions
   fun {Repeat Vector Times}
      fun {RecRepeat Counter Acc}
	 if (Counter==0) then Acc else {RecRepeat Counter-1 {Append Vector Acc}} end
      end
   in
      {RecRepeat Times nil}
   end

   
   % Repeat a musical vector untill it reaches a maximum number of elements and truncate the rest
   % Arg: Vector - a musical vector
   %      ElementsCount - maximum number of elements as integer (>=0)
   % Return: the repeated vector
   % Complexity: O(n) where n is ElementsCount
   fun {RepeatUpToElementsCount Vector ElementsCount}
      BasicRepeats Remaining
      VectorSize = {Length Vector}
   in
      if VectorSize==0 then nil
      else
	 BasicRepeats = ElementsCount div VectorSize
	 Remaining    = ElementsCount mod VectorSize
	 {Flatten [{Repeat Vector BasicRepeats} {List.take Vector Remaining}]}
      end
   end

   
   % Repeat a musical vector up to a fixed duration and truncate the rest
   % Arg: Vector - a musical vector
   %      Duration - the final duration of the vector as float (>=0)
   %      SamplingRate - the number of values per second as integer (>=0)
   % Return: the repeated vector lasting Duration seconds
   % Complexity: O(n) where n is Duration*SamplingRate
   fun {RepeatUpToDuration Vector Duration SamplingRate}
      {RepeatUpToElementsCount Vector {FloatToInt Duration*{IntToFloat SamplingRate}}}
   end


   % Clip a musical vector so that all its values are comprised in the specified interval
   % Arg: Vector - a musical vector
   %      Low - the lower bound as float (>= -1 & <= 1)
   %      High - the upper bound as float (>= -1 & <= 1)
   % Return: the clipped vector where values outside the interval are rounded to the closest bound
   % Complexity: O(n) where n is the vector length
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

   % Convert an hauteur to a frequency
   % Arg: Hauteur as integer (+ or -)
   % Return: A frequency as float >= 0
   fun {HauteurToFrequency Hauteur}
      {Pow 2.0 ({IntToFloat Hauteur}/12.0)} * 440.0
   end
   
   % Build an audio vector for a frequency and a duree
   % Arg: Frequency as float (>= 0) and duree as float (>= 0)
   % Return: An audio vector (list of floats between -1 and 1) of size Duree*Projet.hz 
   fun {BuildAudioVector Frequency Duree SamplingRate}
      Pi   = 3.14159265358979323846 %TODO: How to get Pi in a clever way?
      Temp = (2.0*Pi*Frequency)/{IntToFloat SamplingRate}
      ValuesCount = {FloatToInt Duree*{IntToFloat SamplingRate}}
      fun {AudioVector I}
	 if I>ValuesCount then nil else (0.5 * {Sin (Temp*{IntToFloat I})}) | {AudioVector I+1} end
      end
   in
      {AudioVector 1}
   end

   fun {SmoothenVector Vector Duration SamplingRate}
      Smoothing = 0.15*Duration
   in
      {Fondu Vector Smoothing Smoothing SamplingRate}
   end
   
   fun {VectorFromEnchantillon Frequency Duree SamplingRate}
      {SmoothenVector {BuildAudioVector Frequency Duree SamplingRate} Duree SamplingRate}
   end

   fun {FilePath Note Instrument}
      {VirtualString.toAtom CWD#'wave/instruments/'#Instrument#'_'#Note.nom#Note.octave#(if Note.alteration == none then '' else "#" end)#'.wav'}
   end

   fun {VectorFromInstrument Instrument Hauteur Duree SamplingRate}
      InstrumentVector = {Projet.readFile {FilePath {Note.buildFromHauteur Hauteur} Instrument}}
   in
      {SmoothenVector {RepeatUpToDuration InstrumentVector Duree SamplingRate} Duree SamplingRate}      
   end

   fun {VectorFromVoice Voice}
      fun {EchantillonToAudioVector Echantillon}
	 case Echantillon
	 of silence(duree:Duree)                                           then {VectorFromEnchantillon 0.0 Duree Projet.hz}
	 [] echantillon(hauteur:Hauteur duree:Duree instrument:none)       then {VectorFromEnchantillon {HauteurToFrequency Hauteur} Duree Projet.hz}
	 [] echantillon(hauteur:Hauteur duree:Duree instrument:Instrument) then {VectorFromInstrument Instrument Hauteur Duree Projet.hz}
	 end
      end
   in
      {Flatten {Map Voice EchantillonToAudioVector}}
   end
   

\ifndef TestVector
in
  'export'(vectorFromVoice:VectorFromVoice repeat:Repeat repeatUpToDuration:RepeatUpToDuration clip:Clip fondu:Fondu merge:Merge fonduEnchaine:FonduEnchaine couper:Couper echo:Echo)
end
\endif