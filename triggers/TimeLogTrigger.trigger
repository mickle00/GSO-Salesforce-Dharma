trigger TimeLogTrigger on Time_Log__c (before insert, before update) {
    
    CaseTimeClass caseTimeObj = new CaseTimeClass();
    
    if (trigger.isInsert){        
        BusinessHours allHours = [select Id from BusinessHours where IsDefault=true];
        
        for (Time_Log__c myTimeLog : trigger.New){
        	myTimeLog.Time_Bucket__c = caseTimeObj.getStatusTimeBucket(myTimeLog.Case_Status__c, myTimeLog.Case_Closed__c);
        	myTimeLog.Included_In_SLA_Time__c = caseTimeObj.isStatusIncludedInSLATime(myTimeLog.Case_Status__c, myTimeLog.Case_Closed__c);            
            myTimeLog.In_Effect_From__c = myTimeLog.Most_Recent_Change__c == null ? myTimeLog.In_Effect_Until__c : myTimeLog.Most_Recent_Change__c;            
            myTimeLog.Business_Time_in_Hours__c = BusinessHours.diff(myTimeLog.Case_Business_Hours_ID__c, myTimeLog.In_Effect_From__c, myTimeLog.In_Effect_Until__c)/3600000.0;
        }        
    }
}