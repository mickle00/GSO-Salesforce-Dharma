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
private class UserClassTest {

    static testMethod void myUnitTest() {
    	
    	Profile testUserProfile = [SELECT Id
    	                             FROM Profile
    	                            LIMIT 1];
    	                            
    	                            
      User newUser = new User(FirstName = 'UserClass'
                             ,LastName = 'TestUser'
                             ,Email = 'testuser@userclasstest.com'
                             ,UserName = 'testuser@userclasstest.com'
                             ,Alias = 'testuser'
                             ,CommunityNickname = 'testuser_testing'
                             ,LanguageLocaleKey = 'en_US'
                             ,EmailEncodingKey = 'UTF-8'
                             ,TimeZoneSidKey = 'America/Los_Angeles'
                             ,LocaleSidKey = 'en_US'
                             ,ProfileId = testUserProfile.Id);
                             
      insert newUser;
                             
      String badEmail = 'notest@test.com';
      String goodEmail = 'testuser@userclasstest.com';
      
      User testUser;
      
      UserClass objUser = new UserClass();
      
      test.startTest();
      
      testUser = objUser.getUserByEmail(goodEmail);
      system.debug('testUser => ' + testUser);
      system.debug('newUser => ' + newUser);
      system.assertEquals(testUser.Id,newUser.Id);
      
      testUser = objUser.getUserByEmail(badEmail);
      system.assertEquals(testUser, null);
          
    }   
}