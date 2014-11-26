\define TestCode

local
   CWD = {Property.condGet 'testcwd' '/Users/Greg/Desktop/Projet2014/'}
   [Projet] = {Link [CWD#'Projet2014_mozart2.ozf']}
   Testing = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   NoteMod  = \insert /Users/Greg/Desktop/Projet2014/code/note.oz
   VoixMod  = \insert /Users/Greg/Desktop/Projet2014/code/voix.oz

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
in
   {Browse doneTesting}
end
\undef TestCode