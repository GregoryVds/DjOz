% \define Debug

% Vous ne pouvez pas utiliser le mot-clé 'declare'.
local Interprete Projet Testing Music Transformations in
   [Projet] = {Link ['Projet2014_mozart2.ozf']}
   {Browse Projet}
   % Si vous utilisez Mozart 1.4, remplacez la ligne précédente par celle-ci :
   % [Projet] = {Link ['Projet2014_mozart1.4.ozf']}
   %
   % Projet fournit quatre fonctions :
   % {Projet.run Interprete Mix Music 'out.wav'} = ok OR error(...) 
   % {Projet.readFile FileName} = audioVector(AudioVector) OR error(...)
   % {Projet.writeFile FileName AudioVector} = ok OR error(...)
   % {Projet.load 'music_file.oz'} = Oz structure.
   %
   % et une constante :
   % Projet.hz = 44100, la fréquence d'échantilonnage (nombre de données par seconde)

   % ////////////////////////////////////////////////////////////////////////////////
   % TESTING MODULE
   % ////////////////////////////////////////////////////////////////////////////////
   % Holds testing and debugging functions.
   local
      % Testing routine that asserts that the functions returns what is expected.
      % Args can either be a single argument or a list of arguments.
      proc {AssertEqual Function Args Expected}
	 Got Message ApplyArg
      in
	 ApplyArg = case Args
		    of _|_ then {Append Args [Got]}
		    [] _   then {Append [Args] [Got]}
		    end
	 {Procedure.apply Function ApplyArg}
	 Message = (if Expected==Got then assertion_pass else assertion_fail end)
	 {Browse Message(Function expected:Expected got:Got args:Args)}
      end
   in
      Testing = 'export'(assertEqual:AssertEqual)
   end  

   
   % MUSIC MODULE
   % Holds a bunch of musical helper functions
   % - ExtendNote
   % - ComputeFrequency
   local
      % Convert a note from to its extended notation
      % Pre: Note in short notation (a, b3, b#4, silence)
      % Post: Returns a note in its extended form like note(name:a octave:3 alteration:none)
      fun {ExtendNote Note}
	 case Note
	 of silence     then note(nom:silence octave:4 alteration:none)
	 [] Name#Octave then note(nom:Name octave:Octave alteration:'#') 
	 [] Atom        then
	    case {AtomToString Atom}
	    of [N]     then note(nom:{StringToAtom [N]} octave:4 alteration:none)
	    [] [N O]   then note(nom:{StringToAtom [N]} octave:{StringToInt [O]} alteration:none)
	    end
	 end
      end
      \ifdef Debug
      {Testing.assertEqual ExtendNote a3      note(nom:a octave:3 alteration:none)}
      {Testing.assertEqual ExtendNote c#2     note(nom:c octave:2 alteration:'#')}
      {Testing.assertEqual ExtendNote b3      note(nom:b octave:3 alteration:none)}
      {Testing.assertEqual ExtendNote d3      note(nom:d octave:3 alteration:none)}
      {Testing.assertEqual ExtendNote c       note(nom:c octave:4 alteration:none)}
      {Testing.assertEqual ExtendNote silence note(nom:silence octave:4 alteration:none)}
      \endif

      % Compute the distance of the extended note from A
      % Notes in order are c c# d d# e f f# g g# a a# b
      % distance = a_position - note_position
      % Arg: note in extended notation but not silence
      % Return: a distance as integer from -9 to +2 included
      fun {ComputeDistanceFromA ExtendedNote}
	 case ExtendedNote.nom
	 of c andthen ExtendedNote.alteration == '#' then ~8
	 [] c then ~9
	 [] d andthen ExtendedNote.alteration == '#' then ~6
	 [] d then ~7
	 [] e then ~5
	 [] f andthen ExtendedNote.alteration == '#' then ~3
	 [] f then ~4
	 [] g andthen ExtendedNote.alteration == '#' then ~1
	 [] g then ~2
	 [] a andthen ExtendedNote.alteration == '#' then 1
	 [] a then 0
	 [] b then 2
	 [] silence then what_to_do_with_silence
	 end     
      end
      \ifdef Debug
      {Testing.assertEqual ComputeDistanceFromA note(nom:a octave:3 alteration:none) 0}
      {Testing.assertEqual ComputeDistanceFromA note(nom:c octave:2 alteration:'#')  ~8}
      {Testing.assertEqual ComputeDistanceFromA note(nom:b octave:3 alteration:none) 2}
      {Testing.assertEqual ComputeDistanceFromA note(nom:d octave:3 alteration:none) ~7}
      \endif
      
      % Count the number of half-steps of a note from note a4
      % halfs_steps = note_distance_from_A + octave_distance_to_4 * 12
      % Arg: note in short notation (a, b3, b#4) but not silence
      % Return: half-steps from a4 as integer (Z)
      fun {CountHalfStepsFromA4 Note}
	 ExtendedNote NoteDistance OctaveDistance
      in
	 ExtendedNote = {ExtendNote Note}
	 NoteDistance = {ComputeDistanceFromA ExtendedNote}
	 OctaveDistance = (ExtendedNote.octave - 4) * 12
	 OctaveDistance+NoteDistance
      end
      \ifdef Debug
      {Testing.assertEqual CountHalfStepsFromA4 a   0}
      {Testing.assertEqual CountHalfStepsFromA4 b3  ~10}
      {Testing.assertEqual CountHalfStepsFromA4 d#1 ~42}
      {Testing.assertEqual CountHalfStepsFromA4 e   ~5}
      {Testing.assertEqual CountHalfStepsFromA4 f#4 ~3}
      {Testing.assertEqual CountHalfStepsFromA4 a#4 1}
      {Testing.assertEqual CountHalfStepsFromA4 a#2 ~23}
      \endif

      % Compute the frequency of a note
      % If the note is silence, then frequency is O.
      % Otherwise, frequency = [(2^(1/12))^n]*440 Hz where n is the number of half-steps from a4
      % Arg: note in short notation as argument (a, b3, b#4, silence).
      % Return: note frequency as a natural integer (N)
      fun {ComputeFrequency Note}
	 HalfSteps
      in
	 case Note
	 of silence then 0
	 [] Note then
	    HalfSteps = {CountHalfStepsFromA4 Note}
	    {FloatToInt {Round {Pow {Pow 2.0 (1.0/12.0)} {IntToFloat HalfSteps}}*440.0}}
	 end
      end
      \ifdef Debug
      {Testing.assertEqual ComputeFrequency a       440}
      {Testing.assertEqual ComputeFrequency g#4     415}
      {Testing.assertEqual ComputeFrequency d#4     311}
      {Testing.assertEqual ComputeFrequency d#2     78}
      {Testing.assertEqual ComputeFrequency d2      73}
      {Testing.assertEqual ComputeFrequency silence 0}
      \endif

      % Convert a note to an echantillon
      % Arg: note in short notation as argument (a, b3, b#4, silence)
      % Return: enchantillon of the form: echantillon(hauteur:73 duree:1.0 instrument:none)
      fun {NoteToEchantillon Note}
	 Frequency
      in
	 Frequency = {ComputeFrequency Note}
	 echantillon(hauteur:Frequency duree:1.0 instrument:none)
      end
      \ifdef Debug
      {Testing.assertEqual NoteToEchantillon d#2      echantillon(hauteur:78  duree:1.0 instrument:none)}
      {Testing.assertEqual NoteToEchantillon a        echantillon(hauteur:440 duree:1.0 instrument:none)}
      {Testing.assertEqual NoteToEchantillon d2       echantillon(hauteur:73  duree:1.0 instrument:none)}
      {Testing.assertEqual NoteToEchantillon silence  echantillon(hauteur:0   duree:1.0 instrument:none)}
      \endif
   in
      Music = 'export'(noteToEchantillon:NoteToEchantillon)
   end


   % TRANSFORMATIONS MODULE
   % Transformation functions that act on a voice (flat list of echantillons)
   % - Etirer
   % - Duree
   % - Muet
   local
      
      % Stretch a voice.
      % Arg: a voice and a strech factor as float
      % Return: a strechted voice
      fun {Etirer Voice Factor}
	 case Voice
	 of nil then nil
	 [] H|T then {Etirer H Factor} | {Etirer T Factor}
	 [] echantillon(hauteur:Frequency duree:Duration instrument:none) then echantillon(hauteur:Frequency duree:(Duration*Factor) instrument:none)
	 end
      end
      \ifdef Debug
      {Testing.assertEqual Etirer [[echantillon(hauteur:494 duree:1.0 instrument:none)] 2.0] [echantillon(hauteur:494 duree:2.0 instrument:none)] }
      {Testing.assertEqual Etirer [nil 2.0] nil }
      {Testing.assertEqual Etirer [[echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:131 duree:1.0 instrument:none)] 2.0] [echantillon(hauteur:494 duree:2.0 instrument:none) echantillon(hauteur:131 duree:2.0 instrument:none)] }
      {Testing.assertEqual Etirer [[echantillon(hauteur:494 duree:0.0 instrument:none)] 2.0] [echantillon(hauteur:494 duree:.0 instrument:none)] }
      \endif


      % Fix the duration of a voice
      % Arg: a voice (flat list of echantillons) and the number of seconds the voice shoud last as float (>=0)
      % Return: a voice wih duration fixed to seconds
      fun {Duree Voice Seconds}
	 fun {ComputeTotalDuration Voice}
	    case Voice
	    of nil then 0.0
	    [] H|T then H.duree + {ComputeTotalDuration T}
	    end  
	 end

	 fun {FixDurationForEachEchantillon Voice Seconds}
	    case Voice
	    of nil then nil 
	    [] H|T then {FixDurationForEachEchantillon H Seconds} | {FixDurationForEachEchantillon T Seconds}
	    [] echantillon(hauteur:Freq duree:_ instrument:Instrument) then echantillon(hauteur:Freq duree:Seconds instrument:Instrument)
	    end   
	 end
      in	 
	 case Voice
	 of nil then nil
	 [] echantillon(hauteur:Frequency duree:_ instrument:Instrument) then echantillon(hauteur:Frequency duree:Seconds instrument:Instrument)
	 [] _|_ then TotalDuration in
	    TotalDuration = {ComputeTotalDuration Voice}
	    if (TotalDuration == 0.0) then
	       {FixDurationForEachEchantillon Voice Seconds}
	    else
	       {Etirer Voice Seconds/TotalDuration}
	    end
	 end
      end
      \ifdef Debug
      {Testing.assertEqual Duree [[echantillon(hauteur:494 duree:1.0 instrument:none)] 2.5]                                                    [echantillon(hauteur:494 duree:2.5 instrument:none)] }
      {Testing.assertEqual Duree [[echantillon(hauteur:494 duree:0.0 instrument:none)] 2.5]                                                    [echantillon(hauteur:494 duree:2.5 instrument:none)] }
      {Testing.assertEqual Duree [[echantillon(hauteur:494 duree:0.0 instrument:none) echantillon(hauteur:494 duree:0.0 instrument:none)] 0.0] [echantillon(hauteur:494 duree:0.0 instrument:none) echantillon(hauteur:494 duree:0.0 instrument:none)] }
      {Testing.assertEqual Duree [[echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:494 duree:1.0 instrument:none)] 3.0] [echantillon(hauteur:494 duree:1.5 instrument:none) echantillon(hauteur:494 duree:1.5 instrument:none)] }
      {Testing.assertEqual Duree [[echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:494 duree:1.0 instrument:none)] 0.0] [echantillon(hauteur:494 duree:0.0 instrument:none) echantillon(hauteur:494 duree:0.0 instrument:none)] }
      {Testing.assertEqual Duree [[echantillon(hauteur:494 duree:2.0 instrument:none) echantillon(hauteur:494 duree:4.0 instrument:none)] 3.0] [echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:494 duree:2.0 instrument:none)] }
      \endif


      % Mute a voice (flat list of echantillons) by setting hauteur to 0 for each echantillon
      % Arg: a voice
      % Return: a muted voice (hauteur = 0)
      fun {Muet Voice}
	 case Voice
	 of nil then nil
	 [] H|T then {Muet H} | {Muet T}
	 [] echantillon(hauteur:_ duree:Duration instrument:Instrument) then echantillon(hauteur:0 duree:Duration instrument:Instrument)
	 end
      end
      \ifdef Debug
      {Testing.assertEqual Muet [[echantillon(hauteur:494 duree:1.0 instrument:none)]]                                                    [echantillon(hauteur:0 duree:1.0 instrument:none)] }
      {Testing.assertEqual Muet [[echantillon(hauteur:0 duree:1.0 instrument:none)]]                                                      [echantillon(hauteur:0 duree:1.0 instrument:none)] }
      {Testing.assertEqual Muet [[echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:494 duree:1.0 instrument:none)]] [echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:1.0 instrument:none)] }      
      \endif
   in
      Transformations = 'export'(etirer:Etirer duree:Duree muet:Muet)
   end
  
   
   % local
   %   Audio = {Projet.readFile 'wave/animaux/cow.wav'}
   % in
      % Mix prends une musique et doit retourner un vecteur audio.
      %fun {Mix Interprete Music}
      %   Audio
      %end

      % Interprete doit interpréter une partition

      % INTERPRET
      fun {Interprete Partition}
	 Voice
      in
	 Voice = case Partition
		 of nil then nil
		 [] H|T then {Interprete H}|{Interprete T}
		 [] etirer(facteur:Factor Part)   then {Transformations.etirer {Interprete Part} Factor}
		 [] duree(secondes:Duration Part) then {Transformations.duree  {Interprete Part} Duration}
                 [] muet(Part)                    then {Transformations.muet   {Interprete Part}}
		 [] Note then [{Music.noteToEchantillon Note}]
		 end
	 {Flatten Voice}
      end

      {Testing.assertEqual Interprete b                                                         [echantillon(hauteur:494 duree:1.0 instrument:none)] }
      {Testing.assertEqual Interprete etirer(facteur:3.0 b)                                     [echantillon(hauteur:494 duree:3.0 instrument:none)] }
      {Testing.assertEqual Interprete [ [[b] [c d#1]] ]                                         [echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:262 duree:1.0 instrument:none) echantillon(hauteur:39 duree:1.0 instrument:none)] }
      {Testing.assertEqual Interprete [ [[b] etirer(facteur:2.0 [c3 d#1])] ]                    [echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:131 duree:2.0 instrument:none) echantillon(hauteur:39 duree:2.0 instrument:none)] }
      {Testing.assertEqual Interprete [ [b etirer(facteur:2.0 [b etirer(facteur:2.0 b)])] ]     [echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:494 duree:2.0 instrument:none) echantillon(hauteur:494 duree:4.0 instrument:none)] }
      {Testing.assertEqual Interprete duree(secondes:3.0 b)                                     [echantillon(hauteur:494 duree:3.0 instrument:none)] }
      {Testing.assertEqual Interprete duree(secondes:3.0 [b c3])                                [echantillon(hauteur:494 duree:1.5 instrument:none) echantillon(hauteur:131 duree:1.5 instrument:none)] }
      {Testing.assertEqual Interprete etirer(facteur:2.0 duree(secondes:3.0 b))                 [echantillon(hauteur:494 duree:6.0 instrument:none)] }
      {Testing.assertEqual Interprete duree(secondes:2.0 duree(secondes:3.0 b))                 [echantillon(hauteur:494 duree:2.0 instrument:none)] }
      {Testing.assertEqual Interprete [ [b duree(secondes:2.0 [b duree(secondes:3.0 [b b])])] ] [echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:494 duree:0.5 instrument:none) echantillon(hauteur:494 duree:0.75 instrument:none) echantillon(hauteur:494 duree:0.75 instrument:none)] }   
      {Testing.assertEqual Interprete muet(b)                                                   [echantillon(hauteur:0 duree:1.0 instrument:none)] }
      {Testing.assertEqual Interprete muet([b c3])                                              [echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:1.0 instrument:none)] }
      {Testing.assertEqual Interprete [ [b muet([b c3])] ]                                      [echantillon(hauteur:494 duree:1.0 instrument:none) echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:1.0 instrument:none)] }
      {Testing.assertEqual Interprete muet([b duree(secondes:2.0 c3)])                          [echantillon(hauteur:0 duree:1.0 instrument:none) echantillon(hauteur:0 duree:2.0 instrument:none)] }

   % end

   % local 
   %   Music = {Projet.load 'joie.dj.oz'}      
   % in
      % Votre code DOIT appeler Projet.run UNE SEULE fois.  Lors de cet appel,
      % vous devez mixer une musique qui démontre les fonctionalités de votre
      % programendme.
      %
      % Si votre code devait ne pas passer nos tests, cet exemple serait le
      % seul qui ateste de la validité de votre implémentation.
      % {Browse {Projet.run Mix Interprete Music 'out.wav'}}
   % end
end

\undef Debug