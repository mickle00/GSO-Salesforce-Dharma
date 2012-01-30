public with sharing class NoteClass {

	public static void insertNote(Note myNote, Id parentId){
	    if (myNote.body != null || myNote.title != null){
            if (myNote.title == null) myNote.title = '(NONE)';
            myNote.ParentId = parentId;
            insert myNote;
        }
		
	}
	
	public static List<Note> getNotesByParentId(Id parentId){
    	List<Note> myNotes = [SELECT Title
    								,Body
    								,Owner.Name
    								,CreatedDate 
    						    FROM Note 
    						   WHERE ParentId = :parentId 
    						order by CreatedDate desc];
    	return myNotes; 
    }
}