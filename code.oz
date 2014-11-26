% Projet fournit quatre fonctions :
% {Projet.run Interprete Mix Music 'out.wav'} = ok OR error(...) 
% {Projet.readFile FileName} = AudioVector OR error(...)
% {Projet.writeFile FileName AudioVector} = ok OR error(...)
% {Projet.load 'music_file.dj.oz'} = La valeur oz contenue dans le fichier chargé (normalement une <musique>).
% et une constante :
% Projet.hz = 44100, la fréquence d'échantilonnage (nombre de données par seconde)

local
   CWD = {Property.condGet 'testcwd' '/Users/Greg/Desktop/Projet2014/'}
   [Projet] = {Link [CWD#'Projet2014_mozart2.ozf']}
   Testing  = \insert /Users/Greg/Desktop/Projet2014/code/test.oz
   NoteMod  = \insert /Users/Greg/Desktop/Projet2014/code/note.oz
   VoixMod  = \insert /Users/Greg/Desktop/Projet2014/code/voix.oz
   Interprete
   Mix

   HauteurToFrequency
   VoiceToAudioVector
   BuildAudioVector
in   
   % {Browse {Projet.readFile CWD#'wave/animaux/cow.wav'}}
  
   fun {Interprete Partition}
      Voice
   in
      Voice = case Partition
      of nil then nil
      [] H|T then {Interprete H} | {Interprete T}
      [] etirer(facteur:Factor Part)        then {VoixMod.etirer    {Interprete Part} Factor}
      [] duree(secondes:Duration Part)      then {VoixMod.duree     {Interprete Part} Duration}
      [] muet(Part)                         then {VoixMod.muet      {Interprete Part} }
      [] bourdon(note:Note Part)            then {VoixMod.bourdon   {Interprete Part} {NoteMod.hauteur Note}}
      [] transpose(demitons:HalfSteps Part) then {VoixMod.transpose {Interprete Part} HalfSteps}
      [] Note                               then [{NoteMod.toEchantillon Note}]
      end
      {Flatten Voice}
   end

   
   % Convert an hauteur to a frequency
   % Arg: Hauteur as integer (+ or -)
   % Return: A frequency as float >= 0
   fun {HauteurToFrequency Hauteur}
      {Pow 2.0 ({IntToFloat Hauteur}/12.0)} * 440.0
   end
   \ifdef Debug
   {Testing.assertEqual HauteurToFrequency 0  440.0}
   {Testing.assertEqual HauteurToFrequency 10 783.99}
   {Testing.assertEqual HauteurToFrequency ~2 392.0}
   \endif

   
   % Build an audio vector for a frequency and a duree
   % Arg: Frequency as float (>= 0) and duree as float (>= 0)
   % Return: An audio vector (list of floats between -1 and 1) of size Duree*Projet.hz 
   fun {BuildAudioVector Frequency Duree}
      Pi   = 3.14159265358979323846 %TODO: How to get Pi in a clever way?
      Temp = (2.0*Pi*Frequency)/{IntToFloat Projet.hz}
      ValuesCount = {FloatToInt Duree*{IntToFloat Projet.hz}}
      fun {AudioVector I}
	 if I>ValuesCount then nil else (0.5 * {Sin (Temp*{IntToFloat I})}) | {AudioVector I+1} end
      end
   in
      {AudioVector 1}
   end
   \ifdef Debug
   local Vector1 Vector2 Vector3 in
      Vector1 = {BuildAudioVector 440.0 0.001}
      {Testing.assertEqual Length [Vector1] 44}
      {Testing.assertEqual Nth [Vector1 10] 0.293316}
      {Testing.assertEqual Nth [Vector1 35] 0.405969}
      Vector2 = {BuildAudioVector 783.99 0.005}
      {Testing.assertEqual Length [Vector2] 220}
      {Testing.assertEqual Nth [Vector2 10] 0.449393}
   end
   \endif

   
   % Converts a voice (flat list of echantillons) to an audio vector
   % Arg: A voice
   % Return: An audio vector (list of floats between -1 and 1) 
   fun {VoiceToAudioVector Voice}
      fun {EchantillonToAudioVector Echantillon}
	 case Echantillon
	 of silence(duree:Duree) then {BuildAudioVector 0.0 Duree}
	 [] echantillon(hauteur:Hauteur duree:Duree instrument:_) then {BuildAudioVector {HauteurToFrequency Hauteur} Duree} %TODO: Use instrument
	 end
      end
   in
      {Flatten {Map Voice EchantillonToAudioVector}} %TODO: Optimize by removing Flatten?
   end
   \ifdef Debug
   local Vector1 in
      Vector1 = {VoiceToAudioVector [echantillon(hauteur:10 duree:0.00025 instrument:none) echantillon(hauteur:~2 duree:0.0005 instrument:none)]}
      {Testing.assertEqual Length [Vector1] 33}
      {Testing.assertEqual Nth [Vector1 10] 0.449393}
      {Testing.assertEqual Nth [Vector1 20] 0.240876}
   end  
  \endif
   
   fun {Mix Interprete Music}
      case Music
      of nil then nil
      [] H|T then {Mix Interprete H} | {Mix Interprete T}
      [] voix(Voix)      then {VoiceToAudioVector Voix}
      [] partition(Part) then {Mix Interprete voix({Interprete Part})}
      [] wave(FileName)  then {Projet.readFile FileName}
      end 
      % [] merge(Musics)   then...
      % [] filter          then...
   end

     \ifdef Debug
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
   \endif

   % Demo Music
   % {Browse {Projet.run Mix Interprete {Projet.load CWD#'joie.dj.oz'} CWD#'out.wav'}}
end
