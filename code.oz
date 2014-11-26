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
      case Music
      of nil then nil
      [] H|T then {Mix Interprete H} | {Mix Interprete T}
      [] voix(Voix)      then {VoixMod.voiceToAudioVector Voix Projet.hz}
      [] partition(Part) then {Mix Interprete voix({Interprete Part})}
      [] wave(FileName)  then {Projet.readFile FileName}
      end 
      % [] merge(Musics)   then...
      % [] filter          then...
   end

\ifndef TestCode
end
\endif
