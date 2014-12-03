local
   %  ____            _   _ _   _             
   % |  _ \ __ _ _ __| |_(_) |_(_) ___  _ __    
   % | |_) / _` | '__| __| | __| |/ _ \| '_ \ 
   % |  __/ (_| | |  | |_| | |_| | (_) | | | |
   % |_|   \__,_|_|   \__|_|\__|_|\___/|_| |_|                                       
	 
   Notes = [c a4]
   
   Partition =
   % Basic partitions with notes, different formats and multiple levels of nesting
   [[c [d#1] silence c3]]
       
   % Muet
   | muet(Notes)
   | muet(silence)

   % Duree
   | duree(secondes:0.2 Notes)
   | duree(secondes:0.0 Notes)
   | duree(secondes:0.0 nil)
    
   % Etirer
   | etirer(facteur:1.1 Notes)
   | etirer(facteur:0.3 Notes)
   | etirer(facteur:0.0 Notes)
   
   % Bourdon
   | bourdon(note:c2 Notes)
   | bourdon(note:silence Notes)
   | bourdon(note:b#3 nil)
         
   % Transpose
   | transpose(demitons:~2 Notes)
   | transpose(demitons:2 Notes)
   | transpose(demitons:0 Notes)

   % Instrument
   | instrument(nom:woody [e4 e3])
   
   % Mix a few things...
   | etirer(facteur:0.3 duree(secondes:0.2 [a]))
   | muet([[a] duree(secondes:0.3 [a])])
   | [c3 bourdon(note:c2 etirer(facteur:0.3 [a]))]
   
   % Crazy mix all-in-one 
   | [etirer(facteur:0.2 [b4 etirer(facteur:0.2 duree(secondes:0.3 [c#3 bourdon(note:c2 [b transpose(demitons:~2 [muet(a)])])]))])]
   | nil
   
   %  __  __           _                  
   % |  \/  |_   _ ___(_) __ _ _   _  ___ 
   % | |\/| | | | / __| |/ _` | | | |/ _ \
   % | |  | | |_| \__ \ | (_| | |_| |  __/ 
   % |_|  |_|\__,_|___/_|\__, |\__,_|\___|
   %                        |_|            

   Voix = voix([echantillon(hauteur:2 duree:0.005 instrument:none) echantillon(hauteur:~10 duree:0.002 instrument:none) echantillon(hauteur:~10 duree:0.0 instrument:woody) ])
   Musique =
   
   % Voix
   Voix

   % Partition
   | partition(Partition)
  
   % Wave
   | wave('wave/animaux/cow.wav')
 
   % Merge
   | merge([0.4#[Voix] 0.6#[Voix]])
   | merge([0.2#[Voix] 0.6#[Voix]])

   % Renverser
   | renverser([Voix])
   
   % Repetition Duree
   | repetition(duree:0.2 [Voix])
   | repetition(duree:0.0 [Voix])
   | repetition(duree:2.2 [nil])
   
   % Repetition Nombre
   | repetition(nombre:3 [Voix])
   | repetition(nombre:0 [Voix])
   
   % Clip
   | clip(bas:~0.2 haut:0.2 [Voix])
   | clip(bas:0.0 haut:0.0 [Voix])

   % Echo
   | echo(delai:0.02 [Voix])
   | echo(delai:0.0 [Voix])
  
   % Echo with Decay
   | echo(delai:0.04 decadence:1.4 [Voix])
   | echo(delai:0.02 decadence:0.4 [Voix])
      
   % Echo with Decay and Repeat
   | echo(delai:0.04 decadence:1.4 repetition:2 [Voix])
   | echo(delai:0.03 decadence:1.4 repetition:0 [Voix])

   % Fondu
   | fondu(ouverture:0.002 fermeture:0.002 [Voix])
   | fondu(ouverture:0.0 fermeture:0.0 [Voix])

   % Fondu Enchaine
   | fondu_enchaine(duree:0.005 [Voix] [Voix])

   % Couper
   | couper(debut:~0.005 fin:0.005 [Voix])
   | couper(debut:0.003 fin:0.05 [Voix])

   | nil
in
   % Best song in the world
   Musique
end