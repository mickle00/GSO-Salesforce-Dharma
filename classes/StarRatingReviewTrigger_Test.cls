@isTest
private class StarRatingReviewTrigger_Test {

    static testMethod void myUnitTest() {
      Account testAccount = new Account (Name = 'TestAccount');
      insert testAccount;
   
      Structure_Type__c testStructure = new Structure_Type__c (Name = 'TestStructure');
      insert testStructure;
      
      Star_Rating_Review__c testStarRating = new Star_Rating_Review__c (Account__c  = testAccount.Id, Structure_Type__c = testStructure.Id, Review_Complete__c = 'Yes');        
      insert testStarRating;
    }
}