/**

DEPENDENCIES

QUEUE
Troubleshooting Transport Queue
Fare Filing

RECORD TYPE
Troubleshooting

At Least one Process_Team__c in the Database

**/

@isTest
private class troubleshootingCaseClassExt_Test {

    static testMethod void myUnitTest() {
        troubleshootingCaseClassExtension objTroubleCaseClass = new troubleshootingCaseClassExtension();
        Id troubleshootingRecordType = [SELECT Id
											   ,Name 
                                          FROM  RecordType 
                                         WHERE  sObjectType = 'Case'
                                           AND Name = 'Troubleshooting'].Id;
                                           
		Id troubleshootingQueueId = [SELECT Id
                                            ,Name
                                            ,(SELECT Id
                                                     ,SobjectType 
                                              FROM QueueSobjects 
                                              WHERE SobjectType = 'Case') 
                                      FROM Group 
                                      WHERE Type = 'Queue' 
                                      AND Name = 'Troubleshooting Transport Queue' LIMIT 1].Id;
                                      
        Id nontroubleshootingQueueId = [SELECT Id
                                            ,Name
                                            ,(SELECT Id
                                                     ,SobjectType 
                                              FROM QueueSobjects 
                                              WHERE SobjectType = 'Case') 
                                      FROM Group 
                                      WHERE Type = 'Queue' 
                                      AND Name = 'Fare Filing' LIMIT 1].Id;
                                      
        test.startTest();
                                           
        Case myCase = new Case(RecordTypeId = troubleshootingRecordType);
        Case nonTroubleshootingCase = new Case(Subject = 'Test Case');
        insert nonTroubleshootingCase;
        List<Case> beforeInsertCases = new List<Case>();
        beforeInsertCases.add(myCase);

        objTroubleCaseClass.beforeNewTroubleshootingCase(beforeInsertCases);
        insert beforeInsertCases;      
        
       
        objTroubleCaseClass.afterNewTroubleshootingCase(beforeInsertCases);
        Map<Id, Case> beforeUpdateCases = new Map<Id, Case>();
        
        Map<Id, Case> oldCases = new Map<Id, Case>();        
        Case testCase = [SELECT Id, OwnerId FROM Case WHERE OwnerId != : troubleshootingQueueId limit 1];
        oldCases.put(testCase.Id, testCase);
        oldCases.put(nonTroubleshootingCase.Id, nonTroubleshootingCase);
        
        testCase.OwnerId = troubleshootingQueueId;
        testCase.RecordTypeId = troubleshootingRecordType;
        testCase.Status = 'Transferred';
        
        Process_Team__c myProcessTeam = [SELECT Id FROM Process_Team__c limit 1];
        Case_Process_Team__c testCaseProcessTeam = new Case_Process_Team__c(Case__c = testCase.Id, Process_Team__c = myProcessTeam.Id);
        insert testCaseProcessTeam;
        
        beforeUpdateCases.put(testCase.Id, testCase);
        objTroubleCaseClass.beforeUpdateTroubleshootingCase(beforeUpdateCases, oldCases);
        update beforeUpdateCases.values();
        
        objTroubleCaseClass.afterUpdateTroubleshootingCase(beforeUpdateCases, oldCases);
        
        testCase.OwnerId = nontroubleshootingQueueId;
        beforeUpdateCases.put(testCase.Id, testCase);
        objTroubleCaseClass.beforeUpdateTroubleshootingCase(beforeUpdateCases, oldCases);
        
        nonTroubleshootingCase.RecordTypeId = troubleshootingRecordType;
        beforeUpdateCases.put(nonTroubleshootingCase.Id, nonTroubleshootingCase);
        objTroubleCaseClass.afterUpdateTroubleshootingCase(beforeUpdateCases, oldCases);
        
        test.stopTest();       
    }
}