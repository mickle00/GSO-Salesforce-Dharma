trigger AccountTrigger on Account (before insert, before update) {
	AccountClass objAccount = new AccountClass();
	objAccount.BeforeInsertUpdateAccount(trigger.new);
}