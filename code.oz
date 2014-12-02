% Author: VANDER SCHUEREN Gregory
% Date: December 2014

\ifndef TestCode
local
   Interprete Mix
\endif
   CWD         = {Property.condGet 'testcwd' '/Users/Greg/Desktop/Projet2014/'}
   [Projet]    = {Link [CWD#'Projet2014_mozart2.ozf']}
   ListHelpers = \insert /Users/Greg/Desktop/Projet2014/lib/list_helpers.oz
   Note        = \insert /Users/Greg/Desktop/Projet2014/src/note.oz
   Voice       = \insert /Users/Greg/Desktop/Projet2014/src/voice.oz
   Vector      = \insert /Users/Greg/Desktop/Projet2014/src/vector.oz
   
\ifndef TestCode
in
\endif

   fun {Interprete Partition}
      fun {InterpreteWithInstrument Partition Instrument} M in
	 M = case Partition
	     of nil then nil
	     [] H|T then {InterpreteWithInstrument H Instrument} | {InterpreteWithInstrument T Instrument}
	     [] etirer(facteur:Factor Part)        then {Voice.etirer    {InterpreteWithInstrument Part Instrument} Factor}
	     [] duree(secondes:Duration Part)      then {Voice.duree     {InterpreteWithInstrument Part Instrument} Duration}
	     [] muet(Part)                         then {Voice.muet      {InterpreteWithInstrument Part Instrument} }
	     [] bourdon(note:N Part)               then {Voice.bourdon   {InterpreteWithInstrument Part Instrument} {Note.hauteur N}}
	     [] transpose(demitons:HalfSteps Part) then {Voice.transpose {InterpreteWithInstrument Part Instrument} HalfSteps}
	     [] instrument(nom:Inst Part)          then {InterpreteWithInstrument Part Inst}
	     [] N                                  then [{Note.noteToEchantillon N Instrument}]
	     end
	 {Flatten M}
      end
   in
      {InterpreteWithInstrument Partition none}
   end
   
	
   fun {Mix Interprete Music}
      fun {MixMusicsToMerge MusicsWithIntensity}
	 fun {MixMusic MusicWithIntensity}
	    case MusicWithIntensity of Float#Music then Float#{Mix Interprete Music} end
	 end
      in
	 {Map MusicsWithIntensity MixMusic}
      end
      
      fun {MixMorceau Morceau}
	 case Morceau
	 of voix(Voix)                                 then {Vector.vectorFromVoice Voix Projet.hz}
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
	 [] merge(ZiksToMerge)                         then {Vector.merge {MixMusicsToMerge ZiksToMerge}}
	 end
      end
   in
      {Flatten {Map Music MixMorceau}}
   end

   {Browse {Projet.run Mix Interprete {Projet.load CWD#'example.dj.oz'} CWD#'out.wav'}}
   
\ifndef TestCode
end
 \endif
