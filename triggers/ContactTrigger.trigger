trigger ContactTrigger on Contact (before insert) {
	ContactClass objClass = new ContactClass();
	objClass.updateAccountAndRecordType(trigger.new);
}