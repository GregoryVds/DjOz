\define DebugVoix

% Transformation functions that act on a voice (flat list of echantillons)
% - Etirer
% - Duree
% - Muet

local
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
   \ifdef DebugVoix
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:1.0 instrument:none)] 2.0] [echantillon(hauteur:0 duree:2.0 instrument:none)] }
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:1.0 instrument:none)] 0.5] [echantillon(hauteur:0 duree:0.5 instrument:none)] }
   {Testing.assertEqual Etirer [nil 2.0] nil }
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:1.0 instrument:none)] 2.0]
                                [echantillon(hauteur:0 duree:2.0 instrument:none) echantillon(hauteur:0 duree:2.0 instrument:none)] }
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:0.0 instrument:none)] 2.0] [echantillon(hauteur:0 duree:0.0 instrument:none)] }
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:2.0 instrument:none) silence(duree:2.0)] 0.5]
                                [echantillon(hauteur:0 duree:1.0 instrument:none) silence(duree:1.0)] }
   \endif


   % Compute the total duration of a voice
   % Arg: a voice
   % Return: total duration of a voice as float
   fun {TotalDuration Voice}
      case Voice
      of nil then 0.0
      [] H|T then H.duree + {TotalDuration T}
      end  
   end
   \ifdef DebugVoix
   {Testing.assertEqual TotalDuration [[echantillon(hauteur:0 duree:1.0 instrument:none)]] 1.0}
   {Testing.assertEqual TotalDuration [[echantillon(hauteur:0 duree:2.0 instrument:none) echantillon(hauteur:0 duree:2.0 instrument:none)]] 4.0}
   \endif

   
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
   \ifdef DebugVoix
   {Testing.assertEqual SetFixedDureeForEachEchantillon [[echantillon(hauteur:0 duree:2.0 instrument:none)] 3.0] [echantillon(hauteur:0 duree:3.0 instrument:none)]}
   {Testing.assertEqual SetFixedDureeForEachEchantillon [[echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:3.0 instrument:none)] 2.0]
                                                         [echantillon(hauteur:0 duree:2.0 instrument:none) echantillon(hauteur:0 duree:2.0 instrument:none)] }
   \endif
        
      
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
   \ifdef DebugVoix
   {Testing.assertEqual Duree [nil 3.0] nil }
   {Testing.assertEqual Duree [[echantillon(hauteur:0 duree:1.0 instrument:none)] 2.5]
                               [echantillon(hauteur:0 duree:2.5 instrument:none)] }
   {Testing.assertEqual Duree [[echantillon(hauteur:0 duree:0.0 instrument:none)] 2.5]
                               [echantillon(hauteur:0 duree:2.5 instrument:none)] }
   {Testing.assertEqual Duree [[echantillon(hauteur:0 duree:0.0 instrument:none) echantillon(hauteur:0 duree:0.0 instrument:none)] 1.0]
                               [echantillon(hauteur:0 duree:0.5 instrument:none) echantillon(hauteur:0 duree:0.5 instrument:none)] }
   {Testing.assertEqual Duree [[echantillon(hauteur:0 duree:2.0 instrument:none) echantillon(hauteur:0 duree:4.0 instrument:none)] 3.0]
                               [echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:2.0 instrument:none)] }
   {Testing.assertEqual Duree [[echantillon(hauteur:0 duree:2.0 instrument:none) silence(duree:4.0)] 3.0]
                               [echantillon(hauteur:0 duree:1.0 instrument:none) silence(duree:2.0)] }
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
   \ifdef DebugVoix
   {Testing.assertEqual Muet [[echantillon(hauteur:0 duree:1.0 instrument:none)]] [silence(duree:1.0)] }
   {Testing.assertEqual Muet [[echantillon(hauteur:~10 duree:2.0 instrument:none) echantillon(hauteur:10 duree:1.0 instrument:none)]]
                              [silence(duree:2.0) silence(duree:1.0)] }      
   {Testing.assertEqual Muet [[echantillon(hauteur:10 duree:1.0 instrument:none) silence(duree:1.0)]] [silence(duree:1.0) silence(duree:1.0)] }
   \endif

   
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
   \ifdef DebugVoix
   {Testing.assertEqual Bourdon [nil 5] nil }
   {Testing.assertEqual Bourdon [[echantillon(hauteur:10 duree:1.0 instrument:none)] silence] [silence(duree:1.0)]}
   {Testing.assertEqual Bourdon [[echantillon(hauteur:10 duree:1.0 instrument:none)] 5]
                                 [echantillon(hauteur:5  duree:1.0 instrument:none)] }
   {Testing.assertEqual Bourdon [[echantillon(hauteur:0 duree:1.0 instrument:none)  echantillon(hauteur:20 duree:1.0 instrument:none)] 10]
                                 [echantillon(hauteur:10 duree:1.0 instrument:none) echantillon(hauteur:10 duree:1.0 instrument:none)] }      
   {Testing.assertEqual Bourdon [[echantillon(hauteur:10 duree:1.0 instrument:none) echantillon(hauteur:10 duree:2.0 instrument:none)] silence]
                                 [silence(duree:1.0) silence(duree:2.0)] }        
   {Testing.assertEqual Bourdon [[echantillon(hauteur:0  duree:1.0 instrument:none) silence(duree:1.0)] 10]
                                 [echantillon(hauteur:10 duree:1.0 instrument:none) echantillon(hauteur:10 duree:1.0 instrument:none)] }      
   \endif

   
   % Shift the hauteur of all echantillons in a voice by a number of halfsteps
   % Arg: a partition
   % Return: a transposed partition
   fun {Transpose Voice HalfSteps}
      fun {TransposeEchantillon Echantillon}
	 case Echantillon
	 of silence(duree:Duree) then Echantillon %TODO: Verify transpose of silence
	 [] echantillon(hauteur:Hauteur duree:Duree instrument:Instrument) then echantillon(hauteur:(Hauteur+HalfSteps) duree:Duree instrument:Instrument)
	 end
      end
   in
      {Map Voice TransposeEchantillon}
   end
   \ifdef DebugVoix
   {Testing.assertEqual Transpose [nil 8] nil }
   {Testing.assertEqual Transpose [[echantillon(hauteur:10 duree:1.0 instrument:none)]~12] [echantillon(hauteur:~2 duree:1.0 instrument:none)] }
   {Testing.assertEqual Transpose [[echantillon(hauteur:10 duree:1.0 instrument:none)]  8] [echantillon(hauteur:18 duree:1.0 instrument:none)] }
   {Testing.assertEqual Transpose [[echantillon(hauteur:~2 duree:1.0 instrument:none)]  8] [echantillon(hauteur:6  duree:1.0 instrument:none)] }
   {Testing.assertEqual Transpose [[echantillon(hauteur:10 duree:1.0 instrument:none)] ~8] [echantillon(hauteur:2  duree:1.0 instrument:none)] }
   {Testing.assertEqual Transpose [[echantillon(hauteur:10 duree:1.0 instrument:none)]  0] [echantillon(hauteur:10 duree:1.0 instrument:none)] }
   {Testing.assertEqual Transpose [[echantillon(hauteur:1  duree:1.0 instrument:none) echantillon(hauteur:10 duree:1.0 instrument:none)]  5]
                                   [echantillon(hauteur:6  duree:1.0 instrument:none) echantillon(hauteur:15 duree:1.0 instrument:none)] }
   {Testing.assertEqual Transpose [[echantillon(hauteur:1  duree:1.0 instrument:none) silence(duree:1.0)]  5]
                                   [echantillon(hauteur:6  duree:1.0 instrument:none) silence(duree:1.0)] }
    \endif
in
   'export'(etirer:Etirer duree:Duree muet:Muet bourdon:Bourdon transpose:Transpose)
end
\undef DebugVoix