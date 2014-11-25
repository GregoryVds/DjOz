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
in
   local
      Audio = {Projet.readFile CWD#'wave/animaux/cow.wav'}
   in
      % Mix prends une musique et doit retourner un vecteur audio.
      fun {Mix Interprete Music}
         Audio
      end

      % Interprete doit interpréter une partition
      fun {Interprete Partition}
         nil
      end
   end


   % Demo Music
   % {Browse {Projet.run Mix Interprete {Projet.load CWD#'joie.dj.oz'} CWD#'out.wav'}}
end
