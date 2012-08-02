0 SelectATrainDialog
The Select a Train Dialog is used to select a train (to manage, run, or
print). The [Filter] button uses the Train Name Pattern to match
against train names to select a subset of trains to select from and can
contain these special sequences:  

   [*] Matches any sequence of zero or more characters in the train name.
   [?] Matches any single character in the train name. 
   [\[chars\]] Matches any character in the set given by chars. 
	If a sequence of the form [x-y] appears in chars, then any
        character between [x] and  [y],  inclusive,  will match.
	Characters are matched in a case insensitive way. 
   [\\x] Matchsthe single character [x]. This provides a 
	way of avoiding the special interpretation of the characters
        [*?\\\[\]] in the pattern.


{SelectATrainDialog.gif}
