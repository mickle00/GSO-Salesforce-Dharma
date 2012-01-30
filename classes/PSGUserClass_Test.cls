@isTest
private class PSGUserClass_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        PSG_User__c psgUser = new PSG_User__c();
        
        psgUser.Email__c = 'test@test.com';
        psgUser.Name = 'Joe User';
        
        insert psgUser;
        
        PSG_User__c foundPSGUser = PSGUserClass.findById(psgUser.Id);
        
        system.assertEquals(psgUser.Id,foundPSGUser.Id);
        
    }
}