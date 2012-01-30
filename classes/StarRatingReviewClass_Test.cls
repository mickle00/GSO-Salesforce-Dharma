@isTest
private class StarRatingReviewClass_Test {

  static testMethod void myUnitTest() {    
  
    Account testAccount = new Account (Name = 'TestAccount');
    insert testAccount;
   
    Structure_Type__c testStructure = new Structure_Type__c (Name = 'TestStructure');
    insert testStructure;
    
    test.startTest();
    StarRatingReviewClass objStarRating = new StarRatingReviewClass();
    List<Star_Rating_Review__c> newStarRatings = new List<Star_Rating_Review__c>();
    
    Star_Rating_Review__c testStarRating = new Star_Rating_Review__c (Account__c  = testAccount.Id
                                                                     ,Structure_Type__c = testStructure.Id
                                                                     ,Review_Complete__c = 'Yes');        
    insert testStarRating;
    
    newStarRatings.add(testStarRating);
    objStarRating.syncAccountStarRatings(newStarRatings); 
        
    //Query the Database to get the updated lookup fields
    Account myTestAccount = [SELECT Id
                                    ,Star_Rating_Structure_Type__c
                                    ,Star_Rating_Review_ID__c 
                               FROM Account 
                              WHERE Id = :testAccount.Id]; 
                                
    system.assertEquals(myTestAccount.Star_Rating_Structure_Type__c, testStructure.Id);
    system.assertEquals(myTestAccount.Star_Rating_Review_ID__c, testStarRating.Id);
    
    Star_Rating_Review__c newerStarRating = new Star_Rating_Review__c (Account__c  = testAccount.Id
                                                                      ,Structure_Type__c = testStructure.Id
                                                                      ,Review_Complete__c = 'Yes');        
    insert newerStarRating;
    objStarRating.syncAccountStarRatings(newStarRatings);
    
    //Query the Database to get the updated lookup fields
    Account updatedTestAccount = [SELECT Id
                                         ,Star_Rating_Structure_Type__c
                                         ,Star_Rating_Review_ID__c 
                                    FROM Account 
                                   WHERE Id = :testAccount.Id]; 
                                     
    system.assertEquals(updatedTestAccount.Star_Rating_Structure_Type__c, testStructure.Id);
    system.assertEquals(updatedTestAccount.Star_Rating_Review_ID__c, newerStarRating.Id);
    
    test.stopTest();    
  }
}