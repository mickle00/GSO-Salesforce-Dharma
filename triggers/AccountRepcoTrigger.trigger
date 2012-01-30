trigger AccountRepcoTrigger on Account_Repco__c (before insert, after delete) {
    AccountRepcoClass accountRepcoObj = new AccountRepcoClass();
    
    if (trigger.isBefore && trigger.isInsert){
        accountRepcoObj.indexAccountRepcos(trigger.New);
    }   

    if (trigger.isDelete && trigger.isAfter){
        accountRepcoObj.reIndexAccountRepcos(trigger.Old);
    }       
}