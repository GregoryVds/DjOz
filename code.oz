% Vous ne pouvez pas utiliser le mot-clé 'declare'.

local Mix Interprete Projet CWD in
% local Mix Interprete Projet in
   % CWD contient le chemin complet vers le dossier contenant le fichier 'code.oz'
   % modifiez sa valeur pour correspondre à votre système.
   
   % CWD = {Property.condGet 'testcwd' '/home/layus/ucl/fsab1402/2014-2015/projet_2014/src/'}

   % Si vous utilisez Mozart 1.4, remplacez la ligne précédente par celle-ci :
   % [Projet] = {Link ['Projet2014_mozart1.4.ozf']}
   %
   % Projet fournit quatre fonctions :
   % {Projet.run Interprete Mix Music 'out.wav'} = ok OR error(...) 
   % {Projet.readFile FileName} = AudioVector OR error(...)
   % {Projet.writeFile FileName AudioVector} = ok OR error(...)
   % {Projet.load 'music_file.dj.oz'} = La valeur oz contenue dans le fichier chargé (normalement une <musique>).
   %
   % et une constante :
   % Projet.hz = 44100, la fréquence d'échantilonnage (nombre de données par seconde)

declare
try
   CWD = {Property.condGet 'testcwd' '/Users/Greg/Desktop/Projet2014/'}
    [Projet] = {Module.link ['/Users/Greg/Desktop/Projet2014/Projet2014.ozf']}   
   {Browse projet(Projet)}
   {Browse Projet.readFile}
catch E then {Browse E} end

   {Browse {Float.pow 1.0 1.0}}
  /* 
   local
      {Browse bef_audio}
      Audio = {Projet.readFile CWD#'wave/animaux/cow.wav'}
      {Browse audio(Audio)}
   in
      % Mix prends une musique et doit retourner un vecteur audio.
      fun {Mix Interprete Music}
         Audio
      end
      {Browse Mix}

      % Interprete doit interpréter une partition
      fun {Interprete Partition}
         nil
      end
      {Browse Interprete}
   end

   local
      % Music = {Projet.load CWD#'joie.dj.oz'}
      Music = temp
   in
      % Votre code DOIT appeler Projet.run UNE SEULE fois.  Lors de cet appel,
      % vous devez mixer une musique qui démontre les fonctionalités de votre
      % programme.
      %
      % Si votre code devait ne pas passer nos tests, cet exemple serait le
      % seul qui ateste de la validité de votre implémentation

      {Browse Music}
      % {Browse {Projet.run Mix Interprete Music CWD#'out.wav'}}
      % {Browse {Projet.run Mix Interprete Music '/Users/Greg/Desktop/Projet2014/out.wav'}}.
   end
   */
end
