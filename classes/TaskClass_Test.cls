/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TaskClass_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
      RecordType rt = [SELECT Id
                        FROM RecordType
                       WHERE RecordType.DeveloperName = 'Geography'
                       LIMIT 1];
      
      Case testCase = new Case(subject = 'Test Case'
                              ,description = 'test description'
                              ,recordTypeId = rt.Id);
      
      insert testCase;
      
      Contact testContact = new Contact(firstName = 'Test'
                                       ,lastName = 'Contact'
                                       ,email = 'test@email.com');
                                       
      insert testContact;
        
      TaskClass objTask = new TaskClass();
      
      String caseThreadId = Utilities.getCaseThreadId(testCase.Id);
      
      EmailMessage testEmail = new EmailMessage(ParentId = testCase.Id, Subject = 'Test subject [ ' + caseThreadId +' ]');
      insert testEmail;
      
      objTask.getTaskParentId('[ ref:RANDOMNEVERGOINGTOCOMEUPEVER.50fdsfdsfD:ref ]');
      
      objTask.createTask(testCase.Id, testContact.Id, UserInfo.getUserId(), 'Test Description', 
        'Test subject [ ' + caseThreadId +' ]', 'Completed', system.today());
      
     
      // test for a parent case we should find
      Id taskParentId = objTask.getTaskParentId('Test email subject [ ' + caseThreadId + ' ]');
      system.debug('testcase: ' + testcase.Id + 'task: ' + taskParentId);
      system.assertEquals(testCase.Id, taskParentId);
      // test for no parent case found
      taskParentId = objTask.getTaskParentId('Test email subject');
      system.assertEquals(taskParentId, null);
      
      Task emailTask = new Task(Subject = 'Email task', WhatId = testCase.Id);
      insert emailTask;      
      system.assertEquals(TaskClass.findEmailsByParentId(testCase.Id).size(), 1);
      
    }
}