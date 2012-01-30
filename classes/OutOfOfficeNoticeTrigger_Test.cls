/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OutOfOfficeNoticeTrigger_Test {
  static testMethod void myUnitTest() {
  	
    Assignment_Groups__c groupMember = [SELECT User__c
                                          FROM Assignment_Groups__c
                                         LIMIT 1];

    Out_of_Office_Notice__c[] oofNotices = new Out_of_Office_Notice__c[]{new Out_of_Office_Notice__c(User__c = groupMember.User__c, Start_Date__c = System.today(), End_Date__c = System.today()+1),
                                                                       new Out_of_Office_Notice__c(User__c = groupMember.User__c, Start_Date__c = System.today(), End_Date__c = System.today()+1)};
    
    
    insert oofNotices;
    
    oofNotices[0].Status__c = 'Active';
    oofNotices[1].Status__c = 'Inactive';
    
    update oofNotices;
       
  }
}