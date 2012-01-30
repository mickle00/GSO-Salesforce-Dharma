trigger ConnectionTrigger on Connection__c (before insert, before update) {
    ConnectionClass connectionObj = new ConnectionClass();
    
    if (trigger.isBefore && trigger.isInsert){
        connectionObj.buildConnectionIntegrationKeys(trigger.New);
    }
    if (trigger.isBefore && trigger.isUpdate){
        connectionObj.buildConnectionIntegrationKeys(trigger.New);
    }
}