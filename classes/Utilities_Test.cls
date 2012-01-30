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
private class Utilities_Test {

    static testMethod void myUnitTest() {	
      Map<String,RecordType> mapRecordTypes = new Map<String,RecordType>();
      mapRecordTypes = Utilities.getRecordTypesMap('Case',true);
      
      // test integration key building
      String integrationContactKey = Utilities.generateIntegrationContactKey('test@test.com','joe', 'blow');
      system.assertEquals(integrationContactKey,'test@test.com:blow:joe');
    
      // test append to string
      String existing = 'start';
      String appendText = 'end';
      
      existing = Utilities.appendToString(existing, appendText);
      system.assertEquals(existing, 'startend');
      
      existing = null;
      
      existing = Utilities.appendToString(existing, appendText);
      system.assertEquals(existing, 'end');
      
      //test getCaseThreadId
      Case myCase = new Case(Subject = 'We have no Cases in Release so I have to create this');
      insert myCase;
      String myThreadId = Utilities.getCaseThreadId(string.valueOf([SELECT Id FROM Case limit 1].Id));
      
      //test truncate field      
      String longDescription = 'h';      
      for (integer i=0; i<35000; i++){
        longDescription = longDescription + 'i';
      }
      Utilities.truncateField(longDescription, 32000, '<br/>');
      
      //Recursive trigger test
      Utilities.hasAlreadyFiredTrigger();
      Utilities.setAlreadyFiredTrigger();
      
      //QueueNameToIdMap
      Map<String,Id> mapForTest = Utilities.getQueueNameToIdMap('Case');
    }
}