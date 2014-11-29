% {Projet.run Interprete Mix Music 'out.wav'} = ok OR error(...) 
% {Projet.readFile FileName} = AudioVector OR error(...)
% {Projet.writeFile FileName AudioVector} = ok OR error(...)
% {Projet.load 'music_file.dj.oz'} = La valeur oz contenue dans le fichier chargé (normalement une <musique>).
% Projet.hz = 44100, la fréquence d'échantilonnage (nombre de données par seconde)

\ifndef TestCode
local
   Interprete
   Mix
\endif
   CWD = {Property.condGet 'testcwd' '/Users/Greg/Desktop/Projet2014/'}
   [Projet] = {Link [CWD#'Projet2014_mozart2.ozf']}
   Testing  = \insert /Users/Greg/Desktop/Projet2014/lib/test.oz
   NoteMod  = \insert /Users/Greg/Desktop/Projet2014/code/note.oz
   Voice    = \insert /Users/Greg/Desktop/Projet2014/code/voix.oz
   Vector   = \insert /Users/Greg/Desktop/Projet2014/code/vector.oz
\ifndef TestCode
in
\endif
     
   fun {Interprete Partition}
      V
   in
      V = case Partition
      of nil then nil
      [] H|T then {Interprete H} | {Interprete T}
      [] etirer(facteur:Factor Part)        then {Voice.etirer    {Interprete Part} Factor}
      [] duree(secondes:Duration Part)      then {Voice.duree     {Interprete Part} Duration}
      [] muet(Part)                         then {Voice.muet      {Interprete Part} }
      [] bourdon(note:Note Part)            then {Voice.bourdon   {Interprete Part} {NoteMod.hauteur Note}}
      [] transpose(demitons:HalfSteps Part) then {Voice.transpose {Interprete Part} HalfSteps}
      [] Note                               then [{NoteMod.toEchantillon Note}]
      end
      {Flatten V}
   end
  
   fun {Mix Interprete Music}
      fun {ExtractVectorsToMerge MusicsWithIntensity}
	 case MusicsWithIntensity
	 of nil then nil
	 [] H|T then {ExtractVectorsToMerge H} | {ExtractVectorsToMerge T}
	 [] Float#Music then Float#{Mix Interprete Music}
	 end      
      end

      fun {MixMorceau Morceau}
	 case Morceau
	 of voix(Voix)                                 then {Voice.voiceToAudioVector Voix Projet.hz}
	 [] partition(Part)                            then {MixMorceau voix({Interprete Part}) }  
	 [] wave(FileName)                             then {Projet.readFile CWD#FileName}
	 [] renverser(Zik)                             then {Reverse {Mix Interprete Zik}}
	 [] repetition(nombre:Times Zik)               then {Vector.repeat {Mix Interprete Zik} Times}
	 [] repetition(duree:Duration Zik)             then {Vector.repeatUpToDuration {Mix Interprete Zik} Duration Projet.hz}
	 [] clip(bas:Low haut:High Zik)                then {Vector.clip {Mix Interprete Zik} Low High}
	 [] echo(delai:Delay Zik)                      then {Vector.echo {Mix Interprete Zik} Delay 1 1.0   Projet.hz}
	 [] echo(delai:Delay decadence:Decay Zik)      then {Vector.echo {Mix Interprete Zik} Delay 1 Decay Projet.hz}
	 [] echo(delai:D1 decadence:D2 repetition:R Z) then {Vector.echo {Mix Interprete Z}   D1    R D2    Projet.hz}   
	 [] fondu(ouverture:Open fermeture:Close Zik)  then {Vector.fondu {Mix Interprete Zik} Open Close Projet.hz}
	 [] fondu_enchaine(duree:Duree Zik1 Zik2)      then {Vector.fonduEnchaine {Mix Interprete Zik1} {Mix Interprete Zik2} Duree Projet.hz}
	 [] couper(debut:Start fin:End Zik)            then {Vector.couper {Mix Interprete Zik} Start End Projet.hz}
	 [] merge(ZiksToMerge)                         then {Vector.merge {ExtractVectorsToMerge ZiksToMerge}}
	 end
      end
   in
      {Flatten {Map Music MixMorceau}}
   end  
   
\ifndef TestCode
end
 \endif
