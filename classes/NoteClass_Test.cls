@isTest
private class NoteClass_Test {

    static testMethod void myUnitTest() {
		Note myNote = new Note(Body = 'Blah');
		Note myEmptyNote = new Note();
		Account myAccount = new Account(Name = 'TestAccount');
		insert myAccount;
		
		NoteClass.insertNote(myNote, myAccount.Id);
		NoteClass.insertNote(myEmptyNote, myAccount.Id);
		
		List<Note> myNotes = NoteClass.getNotesByParentId(myAccount.Id);
		system.assertEquals(myNotes.size(), 1);
    }
}