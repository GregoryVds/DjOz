\define TestCode

local   
   \insert /Users/Greg/Desktop/Projet2014/code.oz
   
   % Basic partitions
   {Testing.assertEqual Interprete nil nil}      
   {Testing.assertEqual Interprete b [echantillon(hauteur:2 duree:1.0 instrument:none)] }      
   {Testing.assertEqual Interprete [ [[b] [c d#1]] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) echantillon(hauteur:~9 duree:1.0 instrument:none) echantillon(hauteur:~42 duree:1.0 instrument:none)] }

   % Etirer
   {Testing.assertEqual Interprete etirer(facteur:3.0 b) [echantillon(hauteur:2 duree:3.0 instrument:none)] }
   {Testing.assertEqual Interprete [ [[b] etirer(facteur:2.0 [c3 d#1])] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) echantillon(hauteur:~21 duree:2.0 instrument:none) echantillon(hauteur:~42 duree:2.0 instrument:none)] }
   {Testing.assertEqual Interprete [ [b etirer(facteur:2.0 [b etirer(facteur:2.0 b)])] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) echantillon(hauteur:2 duree:2.0 instrument:none) echantillon(hauteur:2 duree:4.0 instrument:none)] }

   % Duree
   {Testing.assertEqual Interprete duree(secondes:3.0 b) [echantillon(hauteur:2 duree:3.0 instrument:none)] }
   {Testing.assertEqual Interprete duree(secondes:3.0 [b c3])
    [echantillon(hauteur:2 duree:1.5 instrument:none) echantillon(hauteur:~21 duree:1.5 instrument:none)] }
   {Testing.assertEqual Interprete duree(secondes:2.0 duree(secondes:3.0 b)) [echantillon(hauteur:2 duree:2.0 instrument:none)] }
   {Testing.assertEqual Interprete [ [b duree(secondes:2.0 [b duree(secondes:3.0 [b b])])] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) echantillon(hauteur:2 duree:0.5 instrument:none)
     echantillon(hauteur:2 duree:0.75 instrument:none) echantillon(hauteur:2 duree:0.75 instrument:none)] }

   % Muet
   {Testing.assertEqual Interprete muet(b) [silence(duree:1.0)] }
   {Testing.assertEqual Interprete muet([b c3]) [silence(duree:1.0) silence(duree:1.0)] }
   {Testing.assertEqual Interprete [ [b muet([b c3])] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) silence(duree:1.0) silence(duree:1.0)] }

   % Bourdon
   {Testing.assertEqual Interprete bourdon(note:silence c) {Interprete muet(c)} }
   {Testing.assertEqual Interprete bourdon(note:silence d) {Interprete muet(a)} }
   {Testing.assertEqual Interprete bourdon(note:c2 [b c2])
    [echantillon(hauteur:~33 duree:1.0 instrument:none) echantillon(hauteur:~33 duree:1.0 instrument:none)] }

   % Transpose
   {Testing.assertEqual Interprete transpose(demitons:2 b) [echantillon(hauteur:4 duree:1.0 instrument:none)] }
   {Testing.assertEqual Interprete transpose(demitons:~2 b) [echantillon(hauteur:0 duree:1.0 instrument:none)] }
   {Testing.assertEqual Interprete transpose(demitons:~2 [a2 a1]) [echantillon(hauteur:~26 duree:1.0 instrument:none) echantillon(hauteur:~38 duree:1.0 instrument:none)] }
      
   % Crazy Mix
   {Testing.assertEqual Interprete etirer(facteur:2.0 duree(secondes:3.0 b)) [echantillon(hauteur:2 duree:6.0 instrument:none)] }
   {Testing.assertEqual Interprete muet([b duree(secondes:2.0 c3)]) [silence(duree:1.0) silence(duree:2.0)]}
   {Testing.assertEqual Interprete [ [c3 bourdon(note:c2 etirer(facteur:2.0 [b c2]))] ]
    [echantillon(hauteur:~21 duree:1.0 instrument:none) echantillon(hauteur:~33 duree:2.0 instrument:none) echantillon(hauteur:~33 duree:2.0 instrument:none)] }


   % MIX
   local
      V1 = {Mix Interprete [partition([a b2 [c3]])] }
      {Testing.assertEqual Length [V1] 132300}
      
      V2 = {Mix Interprete [voix([echantillon(hauteur:2 duree:0.5 instrument:none) echantillon(hauteur:~10 duree:0.5 instrument:none)])] }
      {Testing.assertEqual Length [V2] 44100}
            
      V3 = {Mix Interprete [voix([echantillon(hauteur:0 duree:0.5 instrument:none)]) partition([a c3]) ] }
      {Testing.assertEqual Length [V3] 110250}

      V4 = {Mix Interprete [merge([0.4#[partition([a b2 [c3]])] 0.6#[voix([echantillon(hauteur:2 duree:3.5 instrument:none)])]])] }
      {Testing.assertEqual Length [V4] 154350}
      
      V5 = {Mix Interprete [partition([a [c3]]) fondu(ouverture:0.2 fermeture:0.2 [voix([echantillon(hauteur:2 duree:0.5 instrument:none)])])] }
      {Testing.assertEqual Length [V5] 110250}

      V6 = {Mix Interprete [fondu_enchaine(duree:0.5 [partition([a [c3]])] [voix([echantillon(hauteur:~2 duree:1.2 instrument:none)])])] }
      {Testing.assertEqual Length [V6] 119070}

      V7 = {Mix Interprete [repetition(duree:2.2 [voix([echantillon(hauteur:0 duree:0.5 instrument:none)])] )]}
      {Testing.assertEqual Length [V7] 97020}

      V8 = {Mix Interprete [repetition(nombre:3 [voix([echantillon(hauteur:0 duree:0.5 instrument:none)])] )]}
      {Testing.assertEqual Length [V8] 66150}

      V9 = {Mix Interprete [couper(debut:~0.3 fin:1.4 [merge([0.4#[partition([a b2 [c3]])] 0.6#[voix([echantillon(hauteur:2 duree:3.5 instrument:none)])]])])]}
      {Testing.assertEqual Length [V9] 74970}

      V10 = {Mix Interprete [wave('wave/animaux/cow.wav')]}
      {Testing.assertEqual IsList [V10] true}
  
      V11 = {Mix Interprete [echo(delai:1.0 [voix([echantillon(hauteur:2 duree:0.5 instrument:none) echantillon(hauteur:~10 duree:2.5 instrument:none)])] )]}
      {Testing.assertEqual Length [V11] 176400}      

      V12 = {Mix Interprete [echo(delai:1.0 decadence:1.4 [voix([echantillon(hauteur:2 duree:0.5 instrument:none) echantillon(hauteur:~10 duree:2.5 instrument:none)])] )]}
      {Testing.assertEqual Length [V12] 176400}

      V13 = {Mix Interprete [echo(delai:1.0 decadence:1.4 repetition:2 [voix([echantillon(hauteur:2 duree:0.5 instrument:none) echantillon(hauteur:~10 duree:2.5 instrument:none)])] )]}
      {Testing.assertEqual Length [V13] 220500}
   in
      {Browse ok}
   end
in
   {Browse doneTesting}
end
\undef TestCode