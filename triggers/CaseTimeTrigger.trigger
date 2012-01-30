trigger CaseTimeTrigger on Case (before insert, after insert, after update) {

    if (trigger.isBefore && trigger.isInsert){
        List<Case_Time__c> newCaseTimes = new List<Case_Time__c>();
        for (Integer i=0; i < trigger.New.size(); i++){
            Case_Time__c myCaseTime = new Case_Time__c();
            newCaseTimes.add(myCaseTime);
        }
        insert newCaseTimes;
        
        for (Case myCase : trigger.New){
            myCase.Case_Time__c = newCaseTimes.remove(0).Id;        
        }
        // clean up incase there were any failures inserting Cases
        if (!newCaseTimes.isEmpty()) delete newCaseTimes;
    }
    
    if (trigger.isAfter && trigger.isInsert){
        List<Case_Time__c> newCaseTimes = new List<Case_Time__c>();
        List<Time_Log__c> newCaseLogs = new List<Time_Log__c>();
        for (Case myCase : trigger.New){
            if (myCase.Case_Time__c != null){
                Case_Time__c myCaseTime = new Case_Time__c(Id=myCase.Case_Time__c);
                myCaseTime.Case__c = myCase.Id;
                newCaseTimes.add(myCaseTime);
                
                //immediately log, incase the case is created in progress or whatever
                Time_Log__c myTimeLog = new Time_Log__c(Case_Owner__c = myCase.OwnerId
                                                       ,Case_Status__c = myCase.Status
                                                       ,New_Case_Status__c = myCase.Status
                                                       ,In_Effect_Until__c = myCase.LastModifiedDate
                                                       ,Case_Time__c = myCase.Case_Time__c);
               newCaseLogs.add(myTimeLog);
            }
        }
        update newCaseTimes;
        insert newCaseLogs;
    }
    
    if (trigger.isAfter && trigger.isUpdate){
        List<Time_Log__c> newCaseLogs = new List<Time_Log__c>();
        
        for (Case myCase : trigger.New){
            Case myOldCase = trigger.OldMap.get(myCase.Id);
            if (myCase.Status != myOldCase.Status || myCase.OwnerId != myOldCase.OwnerId){
                Time_Log__c myTimeLog = new Time_Log__c(Case_Owner__c = myOldCase.OwnerId
                                                       ,Case_Status__c = myOldCase.Status
                                                       ,New_Case_Status__c = myCase.Status
                                                       ,In_Effect_Until__c = myCase.LastModifiedDate
                                                       ,Case_Time__c = myCase.Case_Time__c);
               newCaseLogs.add(myTimeLog);
            }
        }
        insert newCaseLogs;
    }
}