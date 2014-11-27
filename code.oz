% {Projet.run Interprete Mix Music 'out.wav'} = ok OR error(...) 
% {Projet.readFile FileName} = AudioVector OR error(...)
% {Projet.writeFile FileName AudioVector} = ok OR error(...)
% {Projet.load 'music_file.dj.oz'} = La valeur oz contenue dans le fichier chargé (normalement une <musique>).
% Projet.hz = 44100, la fréquence d'échantilonnage (nombre de données par seconde)

\ifndef TestCode
local
   CWD = {Property.condGet 'testcwd' '/Users/Greg/Desktop/Projet2014/'}
   [Projet] = {Link [CWD#'Projet2014_mozart2.ozf']}
   Testing  = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   NoteMod  = \insert /Users/Greg/Desktop/Projet2014/code/note.oz
   VoixMod  = \insert /Users/Greg/Desktop/Projet2014/code/voix.oz
   Vector   = \insert /Users/Greg/Desktop/Projet2014/code/vector.oz
   Interprete
   Mix
in
\endif
     
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
  
   fun {Mix Interprete Music}
      fun {ExtractVectorsToMerge MusicsWithIntensity}
	 case MusicsWithIntensity
	 of nil then nil
	 [] H|T then {ExtractVectorsToMerge H} | {ExtractVectorsToMerge T}
	 [] Float#Music then Float#{Mix Interprete Music}
	 end      
      end
      AudioVector
   in
      AudioVector = case Music
      of nil then nil
      [] H|T then {Mix Interprete H} | {Mix Interprete T}
      [] partition(Part)       then {Mix Interprete voix({Interprete Part}) }    % TODO: Optimize this and flatten?
      [] voix(Voix)            then {VoixMod.voiceToAudioVector Voix Projet.hz}	       
      [] wave(FileName)        then {Projet.readFile FileName}
      [] merge(ZiksToMerge)    then {Vector.merge {ExtractVectorsToMerge ZiksToMerge}}
      [] renverser(Zik)                            then {Reverse {Mix Interprete Zik}}
      [] repetition(nombre:Factor Zik)             then {Vector.repeat {Mix Interprete Zik} Factor}
      [] clip(bas:Low haut:High Zik)               then {Vector.clip {Mix Interprete Zik} Low High}
      [] fondu(ouverture:Open fermeture:Close Zik) then {Vector.fondu {Mix Interprete Zik} Open Close Projet.hz}
		       
      end
      {Flatten AudioVector}
      % 
      % [] filter          then...
   end  
   
   local
      V1 = {Mix Interprete [partition([a b2 [c3]])] }
      {Testing.assertEqual IsList [V1] true}
      {Testing.assertEqual Length [V1] 132300}
      
      V2 = {Mix Interprete [voix([echantillon(hauteur:2 duree:0.5 instrument:none) echantillon(hauteur:~10 duree:0.5 instrument:none)])] }
      {Testing.assertEqual IsList [V2] true}
      {Testing.assertEqual Length [V2] 44100}
            
      V3 = {Mix Interprete [voix([echantillon(hauteur:0 duree:0.5 instrument:none)]) partition([a c3]) ] }
      {Testing.assertEqual IsList [V3] true}
      {Testing.assertEqual Length [V3] 110250}

      V4 = {Mix Interprete merge([0.4#partition([a b2 [c3]]) 0.6#voix([echantillon(hauteur:2 duree:3.5 instrument:none)])]) }
      {Testing.assertEqual IsList [V4] true}
      {Testing.assertEqual Length [V4] 154350}

      V5 = {Mix Interprete [partition([a [c3]]) fondu(ouverture:0.2 fermeture:0.2 voix([echantillon(hauteur:0 duree:0.5 instrument:none)]))] }
      {Testing.assertEqual IsList [V5] true}
      {Testing.assertEqual Length [V5] 110250}
   in
      {Browse ok}
   end
\ifndef TestCode
end
 \endif
