\ifndef TestVoice
local
\endif
   
   % Mute a voice by setting hauteur to 0 for each echantillon
   % Arg: a voice (flat list of echantillons)
   % Return: a muted voice (hauteur = 0)
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

   
   % Stretch a voice.
   % Arg: a voice (flat list of echantillons) and a strech factor as float
   % Return: a strechted voice
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
   % Arg: a voice
   % Return: total duration of a voice as float
   fun {TotalDuration Voice}
      case Voice
      of nil then 0.0
      [] H|T then H.duree + {TotalDuration T}
      end  
   end

   
   % Fix the duration of each echantillon in a voice to a fixed duration
   % Arg: a voice (flat list of echantillons) and the number of seconds each echantillon should last
   % Return: a voice with each echantillon lasting the same duration
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
   % Arg: a voice (flat list of echantillons) and the number of seconds the voice shoud last as float (>=0)
   % Return: a voice wih total duration fixed to Seconds
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
   % Arg: a voice (flat list of echantillons) and a hauteur (integer or atom silence)
   % Return: a voice with hauteur of each enchantillons set the hauteur passed as argument.
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
   % Arg: a partition
   % Return: a transposed partition
   fun {Transpose Voice HalfSteps}
      fun {TransposeEchantillon Echantillon}
	 case Echantillon
	 of silence(duree:_) then Echantillon %TODO: Verify transpose of silence
	 [] echantillon(hauteur:Hauteur duree:Duree instrument:Instrument) then echantillon(hauteur:(Hauteur+HalfSteps) duree:Duree instrument:Instrument)
	 end
      end
   in
      {Map Voice TransposeEchantillon}
   end

\ifndef TestVoice
in
   'export'(muet:Muet duree:Duree etirer:Etirer bourdon:Bourdon transpose:Transpose)
end
\endif