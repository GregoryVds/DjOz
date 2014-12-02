% Expose 3 fonctions related to musical notes:
% - noteToEchantillon:  convert a note to an echantillon
% - hauteur:            count the number of half-steps between a note and a4
% - buildFromHauteur:   convert a hauteur (note distance from a4 as positive or negative integer) to a note in extended notation
% - hauteurToFrequency: convert a hauteur (note distance from a4 as positive or negative integer) to a frequency

\ifndef TestNote
local
\endif
   
   NotesList = [n(n:a a:none) n(n:a a:'#')  n(n:b a:none) n(n:c a:none) n(n:c a:'#')  n(n:d a:none)
		n(n:d a:'#')  n(n:e a:none) n(n:f a:none) n(n:f a:'#')  n(n:g a:none) n(n:g a:'#')]
   NotesListLength = {Length NotesList}

   
   % Convert a note from its short notation to its extended notation
   % Arg: Note - a note in short notation (Ex: a, b3, b#4, silence)
   % Returns: a note in extended form like note(name:a octave:3 alteration:none)
   % Complexity: O(1) - Since length of the atom is max 3
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

   
   % Compute the distance of the note from note "a" is the same musical scale
   % Notes in order are: c c# d d# e f f# g g# a a# b
   % Arg: ExtendedNote - a note in extended notation (but not "silence")
   % Return: a distance as integer ranging from -9 to +2 included
   % Complexity: O(1) since NotesList length is bound to 12
   fun {DistanceFromA ExtendedNote}
      DistanceInList = {Utilities.positionInList n(n:ExtendedNote.nom a:ExtendedNote.alteration) NotesList}
   in
      if DistanceInList > 2 then ~(NotesListLength - DistanceInList) else DistanceInList end
   end
   

   % Count the number of half-steps between a note and a4
   % halfs_steps = DistanceFromA + octave_distance_to_4 * 12
   % Arg: Note - a note in short notation (a, b3, b#4, silence)
   % Return: Half-steps from a4 as positive or negative integer.
   %         If note "silence" was passed as argument, returns silence.
   % Complexity: O(1)
   fun {Hauteur Note}
      ExtendedNote NoteDistance OctaveDistance
   in
      if Note==silence then silence
      else
	 ExtendedNote   = {ExtendNote Note}
	 NoteDistance   = {DistanceFromA ExtendedNote}
	 OctaveDistance = (ExtendedNote.octave - 4) * NotesListLength      
	 OctaveDistance+NoteDistance
      end
   end

   
   % Convert a note to an echantillon
   % Arg: Note - a note in short notation (a, b3, b#4, silence)
   %      Instrument - an instrument as atom (woody, drums)
   % Return: an enchantillon of the form echantillon(hauteur:73 duree:1.0 instrument:woody)
   % Complexity: O(1)
   fun {NoteToEchantillon Note Instrument}
      case Note
      of silence then silence(duree:1.0)
      [] _       then echantillon(hauteur:{Hauteur Note} duree:1.0 instrument:Instrument)
      end
   end


   % Convert a hauteur back to a note in extended notation
   % Arg: Hauteur - note distance from a4 as positive or negative integer
   % Return: note in extended notation like note(name:a octave:3 alteration:none)
   % Complexity: O(1) since NotesList length is bound to 12
   fun {BuildFromHauteur Hauteur}
      Octave = 4 + (Hauteur div NotesListLength)
      NoteDistance = Hauteur mod NotesListLength
      NotePosition
      N
   in
      NotePosition = if (NoteDistance < 0) then NotesListLength+NoteDistance+1 else NoteDistance+1 end
      N = {Nth NotesList NotePosition} 
      note(nom:N.n octave:Octave alteration:N.a)      
   end

      
   % Convert an hauteur (note distance from a4 as positive or negative integer) to a frequency
   % Arg: Hauteur - note distance from a4 as positive or negative integer
   % Return: frequency of the note in HZ
   % Complexity: O(1)
   fun {HauteurToFrequency Hauteur}
      {Pow 2.0 ({IntToFloat Hauteur}/12.0)} * 440.0
   end
   
\ifndef TestNote
in
   'export'(noteToEchantillon:NoteToEchantillon hauteur:Hauteur buildFromHauteur:BuildFromHauteur hauteurToFrequency:HauteurToFrequency)
end
\endif
