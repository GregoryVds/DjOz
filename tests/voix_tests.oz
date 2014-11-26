\define TestVoix

local
   Testing = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   \insert /Users/Greg/Desktop/Projet2014/code/voix.oz

   % Etirer
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:1.0 instrument:none)] 2.0] [echantillon(hauteur:0 duree:2.0 instrument:none)] }
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:1.0 instrument:none)] 0.5] [echantillon(hauteur:0 duree:0.5 instrument:none)] }
   {Testing.assertEqual Etirer [nil 2.0] nil }
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:1.0 instrument:none)] 2.0]
                                [echantillon(hauteur:0 duree:2.0 instrument:none) echantillon(hauteur:0 duree:2.0 instrument:none)] }
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:0.0 instrument:none)] 2.0] [echantillon(hauteur:0 duree:0.0 instrument:none)] }
   {Testing.assertEqual Etirer [[echantillon(hauteur:0 duree:2.0 instrument:none) silence(duree:2.0)] 0.5]
                                [echantillon(hauteur:0 duree:1.0 instrument:none) silence(duree:1.0)] }

   % TotalDuration
   {Testing.assertEqual TotalDuration [[echantillon(hauteur:0 duree:1.0 instrument:none)]] 1.0}
   {Testing.assertEqual TotalDuration [[echantillon(hauteur:0 duree:2.0 instrument:none) echantillon(hauteur:0 duree:2.0 instrument:none)]] 4.0}

   % SetFixedDureeForEachEchantillon
   {Testing.assertEqual SetFixedDureeForEachEchantillon [[echantillon(hauteur:0 duree:2.0 instrument:none)] 3.0] [echantillon(hauteur:0 duree:3.0 instrument:none)]}
   {Testing.assertEqual SetFixedDureeForEachEchantillon [[echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:3.0 instrument:none)] 2.0]
                                                         [echantillon(hauteur:0 duree:2.0 instrument:none) echantillon(hauteur:0 duree:2.0 instrument:none)] }
   % Duree
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
   % Muet
   {Testing.assertEqual Muet [[echantillon(hauteur:0 duree:1.0 instrument:none)]] [silence(duree:1.0)] }
   {Testing.assertEqual Muet [[echantillon(hauteur:~10 duree:2.0 instrument:none) echantillon(hauteur:10 duree:1.0 instrument:none)]]
                              [silence(duree:2.0) silence(duree:1.0)] }      
   {Testing.assertEqual Muet [[echantillon(hauteur:10 duree:1.0 instrument:none) silence(duree:1.0)]] [silence(duree:1.0) silence(duree:1.0)] }

   % Bourdon
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

   % Transpose
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

   % HauteurToFrequency
   {Testing.assertEqual HauteurToFrequency 0  440.0}
   {Testing.assertEqual HauteurToFrequency 10 783.99}
   {Testing.assertEqual HauteurToFrequency ~2 392.0}


   % BuildAudioVector
   local Vector1 Vector2 in
      Vector1 = {BuildAudioVector 440.0 0.001 44100}
      {Testing.assertEqual Length [Vector1] 44}
      {Testing.assertEqual Nth [Vector1 10] 0.293316}
      {Testing.assertEqual Nth [Vector1 35] 0.405969}
      Vector2 = {BuildAudioVector 783.99 0.005 44100}
      {Testing.assertEqual Length [Vector2] 220}
      {Testing.assertEqual Nth [Vector2 10] 0.449393}
   end

   % VoiceToAudioVector
   local Vector1 in
      Vector1 = {VoiceToAudioVector [echantillon(hauteur:10 duree:0.00025 instrument:none) echantillon(hauteur:~2 duree:0.0005 instrument:none)] 44100}
      {Testing.assertEqual Length [Vector1] 33}
      {Testing.assertEqual Nth [Vector1 10] 0.449393}
      {Testing.assertEqual Nth [Vector1 20] 0.240876}
   end  
in
   {Browse doneTesting}
end
\undef TestVoix