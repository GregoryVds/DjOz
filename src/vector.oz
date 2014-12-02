% Expose 9 fonctions that apply filters on musical vectors
% A musical vector is list of floats >= -1 and <= 1
% - repeat:             repeat a musical vector X times
% - repeatUpToDuration: repeat a musical vector up to a fixed duration and truncate the rest
% - clip:               clip a musical vector so that all its values are comprised in the specified interval
% - merge:              merge multiple musical vectors together by computing the weigthed sum of the vectors to merge (where the weight is the intensity)
% - fondu:              fade in the start and fade out the end of a musical vector
% - fonduEnchaine:      concatenate 2 musical vectors together and fade out the end of the first one while fading in
%                       the start of the second one for a smooth transition over a specified duration
% - couper:             returns all the values in a time interval in a musical vector. If the time interval extends beyond the vector it return 0.0's on that portion of the interval
% - echo:               generate an echo by repeating an audio vector multiple times at fixed intervals with a decay applied on the intensity of the repetitions
% - vectorFromVoice:    build an audio vector from a voice
\ifndef TestVector
local
\endif

   
   % Repeat a musical vector X times
   % Arg: Vector - a musical vector
   %      Times - an integer (>=0) the gives the final number of repetitions.
   % Return: the vector passed in argument repeated X times. If X=0 then return nil.
   % Complexity: O(VectorLength*Times)
   fun {Repeat Vector Times}
      {ListHelpers.repeat Vector Times}
   end
   
   
   % Repeat a musical vector up to a fixed duration and truncate the rest
   % Arg: Vector - a musical vector
   %      Duration - the final duration of the vector as float (>=0)
   %      SamplingRate - the number of values per second as integer (>=0)
   % Return: the repeated vector lasting Duration seconds
   % Complexity: O(Duration*SamplingRate)
   fun {RepeatUpToDuration Vector Duration SamplingRate}
      {ListHelpers.repeatUpToElementsCount Vector {FloatToInt Duration*{IntToFloat SamplingRate}}}
   end


   % Clip a musical vector so that all its values are comprised in the specified interval
   % Arg: Vector - a musical vector
   %      Low - the lower bound as float (>= -1 & <= 1)
   %      High - the upper bound as float (>= -1 & <= 1)
   % Return: the clipped vector where values outside the interval are rounded to the closest bound
   % Complexity: O(VectorLength)
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


   % Fade in the start and fade out the end of a musical vector
   % Linearly increase the intensity of its start by multiplying values from 0 to 1 on the specified interval
   % Linearly decreasing the intensity of its end by multiplying values from 1 to 0 on the specified interval
   % Arg: Vector - a musical vector
   %      Start - interval on which to fade the vector at the start as float (>= 0)
   %      End - interval on which to fade the vector at the end as float (>= 0)
   %      SamplingRate - the number of values per second as integer (>=0)
   % Return: a faded musical vector
   % Complexity: O(VectorLength*SamplingRate)
   fun {Fondu Vector Start End SamplingRate}
      VectorLength       = {Length Vector}
      StartElementsCount = {FloatToInt Start*{IntToFloat SamplingRate}}
      EndElementsCount   = {FloatToInt End*{IntToFloat SamplingRate}}      
      fun {RecFondu Vector PositionFromHead PositionFromTail}
	 case Vector
	 of nil then nil
	 [] H|T then Factor in
	    Factor = if (PositionFromHead =< StartElementsCount)   then ({IntToFloat PositionFromHead}-1.0)/({IntToFloat StartElementsCount}-1.0)
		     elseif (PositionFromTail =< EndElementsCount) then	({IntToFloat PositionFromTail}-1.0)/({IntToFloat EndElementsCount}-1.0)
		     else 1.0
		     end
	    (Factor*H) | {RecFondu T (PositionFromHead+1) (PositionFromTail-1)}
	 end          
      end
   in
      {RecFondu Vector 1 VectorLength}
   end


   % Multiply each element in a musical vector by a factor
   % Arg: Vector - a musical vector
   %      Factor - float
   % Return: the vector where each element is multiplied by the factor
   % Complexity: O(VectorLength)
   fun {Multiply Vector Factor}
      {Map Vector fun {$ Elem} Elem * Factor end } 
   end

   
   % Add 2 musical vectors together
   % Arg: Vector1 - a musical vector to be added
   %      Vector2 - a musical vector to be added
   % Return: a single vector which is the addition of Vector1 and Vector2.
   %         If one vector is longer than the other, then nothing is added at the end of the longest.
   % Complexity: O(n) where n is the shortest vector length
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
	    of nil   then LongestV
	    [] H2|T2 then (H+H2) | {RecAdd T T2}  
	    end
	 end  	    
      end
   in
      {RecAdd Longest Shortest}
   end
   

   % Merge multiple musical vectors together by computing the weigthed sum of the vectors to merge (where the weight is the intensity)
   % Arg: VectorsToMerge - a list a pairs with Intensity#MusicalVector where the sum the of intensities (floats) <= 1
   % Return: a single musical vector
   % Complexity: O(n*m) where n is the number of vector to merge (-1) and m is roughly the minimum length of the vectors to merge
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


   % Concatenate 2 musical vectors together and fade out the end of the first one while fading in the start of the second one for a smooth transition over a specified duration
   % Arg: Vector1 - first musical vector to concatenate in the final vector
   %      Vector2 - second musical vector to concatenate in the final vector
   %      Duration - duration of the fade in/fade out transition between the 2 vectors
   %      SamplingRate - the number of values per second as integer (>=0)
   % Return: a single musical vector
   % Complexity: O(n*SamplingRate) where n is roughly the average length of the 2 vectors.
   fun {FonduEnchaine Vector1 Vector2 Duration SamplingRate}
      V1Start V1Fondu V2Fondu V2End 
      FonduElements = {FloatToInt Duration*{IntToFloat SamplingRate}}
      {List.takeDrop Vector1 {Length Vector1}-FonduElements V1Start V1Fondu}
      {List.takeDrop Vector2 FonduElements V2Fondu V2End}      
      Mix = {Add {Fondu V1Fondu 0.0 Duration SamplingRate} {Fondu V2Fondu Duration 0.0 SamplingRate}}
   in
      {Append {Append V1Start Mix} V2End}
   end


   % Returns all values in a time interval in a musical vector. If the time interval extends beyond the vector it return 0.0's on that portion of the interval.
   % Arg: Vector - the musical vector to slice from
   %      Start - the start of the time interval relative the start of the vector
   %      End - the end of the time interval relative the end of the vector
   %      SamplingRate - the number of values per second as integer (>=0)
   % Return: a single musical vector sliced out of the original one.
   % Complexity: O(Interval*SamplingRate) where Interval = End - Start
   fun {Couper Vector Start End SamplingRate}
      SamplingFloat = {IntToFloat SamplingRate}
      IntervalStart = {FloatToInt Start*SamplingFloat}
      IntervalEnd   = {FloatToInt End*SamplingFloat}
      VectorLength  = {Length Vector}
      fun {CouperRec Vector Position Acc}
	 if (Position == IntervalEnd)                                  then {Reverse Acc}
	 elseif (Position < 0)                                         then {CouperRec Vector Position+1 (0.0|Acc)}
	 elseif ({And Position>=VectorLength Position>=IntervalStart}) then {CouperRec Vector Position+1 (0.0|Acc)}
	 else
	    if (Position < IntervalStart) then V in
	       V = case Vector of nil then nil [] _|T then T end	  
	       {CouperRec V Position+1 Acc}
	    else
	       {CouperRec Vector.2 Position+1 (Vector.1|Acc)}
	    end 
	 end		 
      end 
   in
      {CouperRec Vector {Min IntervalStart 0} nil}
   end


   % Generate an echo by repeating an audio vector multiple times at fixed intervals with a decay applied on the intensity of the repetitions 
   % Arg: Vector - the original audio vector
   %      Delay - float (>= 0) that specify the time interval in seconds between 2 echos
   %      Repetition - integer (>= 0) that specify the number of repetitions
   %      Decay - float (>= 0) that specify the decay factor at each echo
   %      SamplingRate - the number of values per second as integer (>=0)
   % Return: a single musical vector that combines the original vector and the echoed vectors.
   % Complexity: O(n*m) where n is the number of repetitions and m is [Sum where X goes from 1 to Repetition of VectorLength+X*Delay*SamplingRate]/Repetition
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


   % Build an audio vector from a frequency, a duree and a sampling rate
   % Arg: Frequency - float (>= 0) 
   %      Duree - float (>= 0)
   %      SamplingRate - the number of values per second as integer (>=0)
   % Return: An audio vector of size Duree*SamplingRate
   % Complexity: O(Duree*SamplingRate)
   fun {Build Frequency Duree SamplingRate}
      Pi   = 3.14159265358979323846
      Temp = (2.0*Pi*Frequency)/{IntToFloat SamplingRate}
      ValuesCount = {FloatToInt Duree*{IntToFloat SamplingRate}}
      fun {AudioVector I}
	 if I>ValuesCount then nil else (0.5 * {Sin (Temp*{IntToFloat I})}) | {AudioVector I+1} end
      end
   in
      {AudioVector 1}
   end


   % Build the path to a .wav audio file a note played by an instrument
   % Arg: Note - note in extended notation 
   %      Instrument - instrument as atom like 'woody'
   % Return: the path to the file as an atom
   % Complexity: O(1)
   fun {FilePath Note Instrument}
      {VirtualString.toAtom CWD#'wave/instruments/'#Instrument#'_'#Note.nom#Note.octave#(if Note.alteration == none then '' else "#" end)#'.wav'}
   end


   % Build an audio vector for an instrument
   % Arg: Instrument - instrument as atom like 'woody'
   %      Hauteur - note distance from a4 as positive or negative integer
   %      Duree - float (>= 0)
   %      SamplingRate - the number of values per second as integer (>=0)
   % Return: an audio vector
   % Complexity: O(SamplingRate*Duree)
   fun {VectorFromInstrument Instrument Hauteur Duree SamplingRate}
      InstrumentVector = {Projet.readFile {FilePath {Note.buildFromHauteur Hauteur} Instrument}}
   in
      {Fondu {RepeatUpToDuration InstrumentVector Duree SamplingRate} 0.15*Duree 0.15*Duree SamplingRate}      
   end


   % Build an audio vector from a voice
   % Arg: Voice - a flat list of echantillons
   % Return: an audio vector
   % Complexity: O(VoiceTotalDuree*SamplingRate)
   fun {VectorFromVoice Voice SamplingRate}
      fun {VectorFromEnchantillon Frequency Duree SamplingRate}
	 {Fondu {Build Frequency Duree SamplingRate} 0.15*Duree 0.15*Duree SamplingRate}
      end

      fun {EchantillonToAudioVector Echantillon}
	 case Echantillon
	 of silence(duree:Duree)                                           then {VectorFromEnchantillon 0.0 Duree SamplingRate}
	 [] echantillon(hauteur:Hauteur duree:Duree instrument:none)       then {VectorFromEnchantillon {Note.hauteurToFrequency Hauteur} Duree SamplingRate}
	 [] echantillon(hauteur:Hauteur duree:Duree instrument:Instrument) then {VectorFromInstrument Instrument Hauteur Duree SamplingRate}
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