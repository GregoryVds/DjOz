% Author: VANDER SCHUEREN Gregory
% Date: December 2014

\define TestCode
local
   Test = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   \insert /Users/Greg/Desktop/Projet2014/code.oz

   % Basic partitions
   {Test.assertEqual Interprete nil nil}      
   {Test.assertEqual Interprete b [echantillon(hauteur:2 duree:1.0 instrument:none)] }      
   {Test.assertEqual Interprete [ [[b] [c d#1]] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) echantillon(hauteur:~9 duree:1.0 instrument:none) echantillon(hauteur:~42 duree:1.0 instrument:none)] }

   % Etirer
   {Test.assertEqual Interprete etirer(facteur:3.0 b) [echantillon(hauteur:2 duree:3.0 instrument:none)] }
   {Test.assertEqual Interprete [ [[b] etirer(facteur:2.0 [c3 d#1])] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) echantillon(hauteur:~21 duree:2.0 instrument:none) echantillon(hauteur:~42 duree:2.0 instrument:none)] }
   {Test.assertEqual Interprete [ [b etirer(facteur:2.0 [b etirer(facteur:2.0 b)])] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) echantillon(hauteur:2 duree:2.0 instrument:none) echantillon(hauteur:2 duree:4.0 instrument:none)] }

   % Duree
   {Test.assertEqual Interprete duree(secondes:3.0 b) [echantillon(hauteur:2 duree:3.0 instrument:none)] }
   {Test.assertEqual Interprete duree(secondes:3.0 [b c3])
    [echantillon(hauteur:2 duree:1.5 instrument:none) echantillon(hauteur:~21 duree:1.5 instrument:none)] }
   {Test.assertEqual Interprete duree(secondes:2.0 duree(secondes:3.0 b)) [echantillon(hauteur:2 duree:2.0 instrument:none)] }
   {Test.assertEqual Interprete [ [b duree(secondes:2.0 [b duree(secondes:3.0 [b b])])] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) echantillon(hauteur:2 duree:0.5 instrument:none)
     echantillon(hauteur:2 duree:0.75 instrument:none) echantillon(hauteur:2 duree:0.75 instrument:none)] }

   % Muet
   {Test.assertEqual Interprete muet(b) [silence(duree:1.0)] }
   {Test.assertEqual Interprete muet([b c3]) [silence(duree:1.0) silence(duree:1.0)] }
   {Test.assertEqual Interprete [ [b muet([b c3])] ]
    [echantillon(hauteur:2 duree:1.0 instrument:none) silence(duree:1.0) silence(duree:1.0)] }

   % Bourdon
   {Test.assertEqual Interprete bourdon(note:silence c) {Interprete muet(c)} }
   {Test.assertEqual Interprete bourdon(note:silence d) {Interprete muet(a)} }
   {Test.assertEqual Interprete bourdon(note:c2 [b c2])
    [echantillon(hauteur:~33 duree:1.0 instrument:none) echantillon(hauteur:~33 duree:1.0 instrument:none)] }

   % Transpose
   {Test.assertEqual Interprete transpose(demitons:2 b) [echantillon(hauteur:4 duree:1.0 instrument:none)] }
   {Test.assertEqual Interprete transpose(demitons:~2 b) [echantillon(hauteur:0 duree:1.0 instrument:none)] }
   {Test.assertEqual Interprete transpose(demitons:~2 [a2 a1]) [echantillon(hauteur:~26 duree:1.0 instrument:none) echantillon(hauteur:~38 duree:1.0 instrument:none)] }
      
   % Crazy Mix
   {Test.assertEqual Interprete etirer(facteur:2.0 duree(secondes:3.0 b)) [echantillon(hauteur:2 duree:6.0 instrument:none)] }
   {Test.assertEqual Interprete muet([b duree(secondes:2.0 c3)]) [silence(duree:1.0) silence(duree:2.0)]}
   {Test.assertEqual Interprete [ [c3 bourdon(note:c2 etirer(facteur:2.0 [b c2]))] ]
    [echantillon(hauteur:~21 duree:1.0 instrument:none) echantillon(hauteur:~33 duree:2.0 instrument:none) echantillon(hauteur:~33 duree:2.0 instrument:none)] }

   % Instruments                       
   {Test.assertEqual Test.assertEqualLists [{Interprete instrument(nom:woody a4)} {Interprete instrument(nom:drums instrument(nom:woody a4))}] true}
   
   % MIX
   local
      V1 = {Mix Interprete [partition([a b2 [c3]])] }
      {Test.assertEqual Length [V1] 132300}
      
      V2 = {Mix Interprete [voix([echantillon(hauteur:2 duree:0.5 instrument:none) echantillon(hauteur:~10 duree:0.5 instrument:none)])] }
      {Test.assertEqual Length [V2] 44100}
            
      V3 = {Mix Interprete [voix([echantillon(hauteur:0 duree:0.5 instrument:none)]) partition([a c3]) ] }
      {Test.assertEqual Length [V3] 110250}

      V4 = {Mix Interprete [merge([0.4#[partition([a b2 [c3]])] 0.6#[voix([echantillon(hauteur:2 duree:3.5 instrument:none)])]])] }
      {Test.assertEqual Length [V4] 154350}
      
      V5 = {Mix Interprete [partition([a [c3]]) fondu(ouverture:0.2 fermeture:0.2 [voix([echantillon(hauteur:2 duree:0.5 instrument:none)])])] }
      {Test.assertEqual Length [V5] 110250}

      V6 = {Mix Interprete [fondu_enchaine(duree:0.5 [partition([a [c3]])] [voix([echantillon(hauteur:~2 duree:1.2 instrument:none)])])] }
      {Test.assertEqual Length [V6] 119070}

      V7 = {Mix Interprete [repetition(duree:2.2 [voix([echantillon(hauteur:0 duree:0.5 instrument:none)])] )]}
      {Test.assertEqual Length [V7] 97020}

      V8 = {Mix Interprete [repetition(nombre:3 [voix([echantillon(hauteur:0 duree:0.5 instrument:none)])] )]}
      {Test.assertEqual Length [V8] 66150}

      V9 = {Mix Interprete [couper(debut:~0.3 fin:1.4 [merge([0.4#[partition([a b2 [c3]])] 0.6#[voix([echantillon(hauteur:2 duree:3.5 instrument:none)])]])])]}
      {Test.assertEqual Length [V9] 74970}

      V10 = {Mix Interprete [wave('wave/animaux/cow.wav')]}
      {Test.assertEqual IsList [V10] true}
  
      V11 = {Mix Interprete [echo(delai:1.0 [partition([a b2 [c3]])])]}
      {Test.assertEqual Length [V11] 176400}      

      V12 = {Mix Interprete [echo(delai:1.0 decadence:1.4 [voix([echantillon(hauteur:2 duree:0.5 instrument:none) echantillon(hauteur:~10 duree:2.5 instrument:none)])] )]}
      {Test.assertEqual Length [V12] 176400}

      V13 = {Mix Interprete [echo(delai:1.0 decadence:1.4 repetition:2 [voix([echantillon(hauteur:2 duree:0.5 instrument:none) echantillon(hauteur:~10 duree:2.5 instrument:none)])])]}
      {Test.assertEqual Length [V13] 220500}

      V14 = {Mix Interprete [echo(delai:1.0 [partition([a b2 [c3]])])]}
      V15 = {Mix Interprete [merge([0.5#[partition([a b2 [c3]])] 0.5#[voix([silence(duree:1.0)]) partition([a b2 [c3]])]])] }
      {Test.assertEqual Test.assertEqualLists [V14 V15] true}
      
      V16 = {Mix Interprete [echo(delai:1.0 decadence:0.5 repetition:2 [partition([a b2 [c3]])])]}
      V17 = {Mix Interprete [merge([(1.0/1.75)#[partition([a b2 [c3]])] (0.5/1.75)#[voix([silence(duree:1.0)]) partition([a b2 [c3]])] (0.25/1.75)#[voix([silence(duree:2.0)]) partition([a b2 [c3]])]])]}
      {Test.assertEqual Test.assertEqualLists [V16 V17] true}

   in
      {Browse ok}
   end
in
   {Browse doneTestingCode}
end
\undef TestCode