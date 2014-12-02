% Expose 5 fonctions that apply transformations on musical voices (flat list of echantillons)
% - muet: mute a voice by replacing all enchantillons by silences
% - etirer: stretch a voice (final duration is original duration multiplied by strech factor)
% - duree: fix the total duration of a voice while preserving the relative duration of each echantillon
% - bourdon: set the hauteur of each enchantillons in a voice to a fixed value
% - transpore: shift the hauteur of all echantillons in a voice by a number of halfsteps

\ifndef TestVoice
local
\endif
   
   % Mute a voice by replacing all enchantillons by silences
   % Arg: Voice - a voice
   % Return: a muted voice with only silences.
   % Complexity: O(n) where n is the length of the voice
   fun {Muet Voice}
      fun {MuetEchantillon Echantillon}
	   case Echantillon
	   of silence(duree:_) then Echantillon
	   [] echantillon(hauteur:_ duree:Duree instrument:_) then silence(duree:Duree)
	   end
      end
   in
      {Map Voice MuetEchantillon}
   end

   
   % Stretch a voice (final duration is original duration multiplied by strech factor)
   % Arg: Voice - a voice
   %      Factor - strech factor as float (>=0)
   % Return: a strechted voice
   % Complexity: O(n) where n is the length of the voice
   fun {Etirer Voice Factor}
      fun {EtirerEchantillon Echantilon}
	 case Echantilon
	 of silence(duree:Duree) then silence(duree:(Duree*Factor))
	 [] echantillon(hauteur:Frequency duree:Duree instrument:Instrument) then echantillon(hauteur:Frequency duree:(Duree*Factor) instrument:Instrument)
	 end
      end
   in
      {Map Voice EtirerEchantillon}
   end
   

   % Compute the total duration of a voice
   % Arg: Voice - a voice
   % Return: total duration of a voice as float (>= 0)
   % Complexity: O(n) where n is the length of the voice
   fun {TotalDuration Voice}
      fun {TotalDurationAcc Voice Acc}
	 case Voice
	 of nil then Acc
	 [] H|T then {TotalDurationAcc T Acc+H.duree}
	 end
      end
   in
      {TotalDurationAcc Voice 0.0}
   end

   
   % Fix the duration of each echantillon in a voice to a fixed duration
   % Arg: Voice - a voice
   %      Seconds - the duration each echantillon should last in seconds as float (>=0)
   % Return: a voice with each echantillon lasting the same duration
   % Complexity: O(n) where n is the length of the voice
   fun {SetFixedDureeForEachEchantillon Voice Seconds}
      fun {DureeEchantillon Echantillon}
	 case Echantillon 
	 of silence(duree:_) then silence(duree:Seconds)
	 [] echantillon(hauteur:Freq duree:_ instrument:Instrument) then echantillon(hauteur:Freq duree:Seconds instrument:Instrument)
	 end   
      end
   in
      {Map Voice DureeEchantillon}
   end
        
      
   % Fix the total duration of a voice while preserving the relative duration of each echantillon
   % Arg: Voice - a voice
   %      Seconds - duration of the final voice as float (>=0)
   % Return: a voice wih total duration == Seconds
   % Complexity: O(n) where n is the length of the voice
   fun {Duree Voice Seconds}
      case Voice
      of nil then nil
      [] _|_ then Duree = {TotalDuration Voice} in
	 if (Duree == 0.0) then {SetFixedDureeForEachEchantillon Voice (Seconds/{IntToFloat {Length Voice}})}
	 else {Etirer Voice Seconds/Duree}
	 end
      end
   end

   
   % Set the hauteur of each enchantillons in a voice to a fixed value
   % Arg: Voice - a voice
   %      Hauteur - integer (positive or negative) or atom silence
   % Return: a voice with the hauteur of each enchantillon set the hauteur passed as argument
   % Complexity: O(n) where n is the length of the voice
   fun {Bourdon Voice Hauteur}
      fun {BourdonEchantillon Echantillon}
	 case Echantillon
	 of silence(duree:Duree) then
	    if Hauteur==silence then Echantillon else echantillon(hauteur:Hauteur duree:Duree instrument:none) end			       
	 [] echantillon(hauteur:_ duree:Duree instrument:Instrument) then
	    if Hauteur==silence then silence(duree:Duree) else echantillon(hauteur:Hauteur duree:Duree instrument:Instrument) end  
	 end	 
      end
   in
      {Map Voice BourdonEchantillon}
   end  

   
   % Shift the hauteur of all echantillons in a voice by a number of halfsteps
   % Arg: Voice - a voice
   %      Halfsteps - the number of halfsteps the voice should be shifted as integer (positive or negative)
   % Return: a transposed voice. A silence is always shifted to a silence.
   % Complexity: O(n) where n is the length of the voice
   fun {Transpose Voice HalfSteps}
      fun {TransposeEchantillon Echantillon}
	 case Echantillon
	 of silence(duree:_) then Echantillon
	 [] echantillon(hauteur:Hauteur duree:Duree instrument:Instrument) then echantillon(hauteur:(Hauteur+HalfSteps) duree:Duree instrument:Instrument)
	 end
      end
   in
      {Map Voice TransposeEchantillon}
   end

   
\ifndef TestVoice
in
   'export'(muet:Muet etirer:Etirer duree:Duree bourdon:Bourdon transpose:Transpose)
end
\endif