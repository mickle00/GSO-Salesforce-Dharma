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
private class ContactClass_Test {

    static testMethod void myUnitTest() {
    	
    	Account[] accounts = new Account[]{new Account(Name = 'Internal Contacts')
    	                                  ,new Account(Name = 'External Contacts')};
    	
    	insert accounts;
    	
    	ContactClass objContact = new ContactClass();
    	
    	List<Contact> testContactsToInsert = new List<Contact>();
    	// add some new contacts so we can test the next methods
      Contact existing1 = (new Contact(LastName = 'Number1'
                                        ,FirstName = 'Existing'
                                        ,Email = 'found1@expedia.com'));
                                        
      testContactsToInsert.add(existing1);
       
    	// add some new contacts so we can test the next methods
      Contact existing2 = (new Contact(LastName = 'Number2'
                                      ,FirstName = 'Existing'
                                      ,Email = 'found2@expedia.com'));
                                     
      testContactsToInsert.add(existing2);
      
      Contact existing3 = (new Contact(LastName = 'Number2'
                                      ,FirstName = 'Existing'
                                      ,Email = 'found1@expedia.com'));
                                        
      testContactsToInsert.add(existing3);
                                      
      insert testContactsToInsert;
    	
      Contact[] contacts = new Contact[]{new Contact(LastName='Last1',FirstName='First1',email='first1@expedia.com'),
        								                 new Contact(LastName='Last2',FirstName='First2',email='first2@expedia.com'),
        								                 new Contact(LastName='Last3',FirstName='First3',email='first3@expedia.com'),
        								                 new Contact(LastName='Last4',FirstName='First4',email='first4@expedia.com'),
        								                 new Contact(LastName='Last5',FirstName='First5',email='first5@expedia.com'),
        								                 new Contact(LastName='Last5',FirstName='First5',email='first5@info.com.com')
      };
      
      // Test updating AccountAndRecordType on new contacts
      objContact.updateAccountAndRecordType(contacts);
      
      //insert the contacts so other methods can use them
      
      // add some new contacts so we can test the next methods
      contacts.add(existing1);
      contacts.add(existing2); 
      contacts.add(existing3);
       
      // Build a set or all email address
      Set<String> allEmails = new Set<String>();
      Map<String,String> allEmailsAndNames = new Map<String,String>();
      Map<String,List<Contact>> existingContacts = new Map<String,List<Contact>>();
      
      for(Contact thisContact : contacts) {
      	allEmails.add(thisContact.email);
      }
      
      // test to call to get map of existing contacts
      existingContacts = objContact.getExistingContacts(allEmails);
      system.assertEquals(existingContacts.size(),2);	
     
      Set<String> existingContactEmails = existingContacts.keySet();
      
      //Test getting a list of contacts that need to be created
      objContact.getContactsToCreate(allEmails, allEmailsAndNames, existingContactEmails);
  }  
}