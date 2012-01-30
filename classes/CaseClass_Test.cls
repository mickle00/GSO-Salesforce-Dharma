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
private class CaseClass_Test {

  static testMethod void myUnitTest() {
        
    Account[] testaccts = new Account[] {
      new Account(Name = '999TestAcct0'),
	    new Account(Name = '999TestAcct1', Rating = '1'),
	    new Account(Name = '999TestAcct2', Rating = '2'),
		  new Account(Name = '999TestAcct3', Rating = '3'),
	    new Account(Name = '999TestAcct4', Rating = '4'),
		  new Account(Name = '999TestAcct5', Rating = 'NoAccountNumber')
	  };
	
	  insert testaccts;
		
	  Map <String, Id> testacctid = new Map<String, Id> ();
		
	  for (Account a : testaccts){
	    system.debug ('Name: ' + a.Name + 'Id: ' + a.Id);
		  testacctid.put(a.Name, a.Id);
	  }
						
	  Contact[] testcontacts = new Contact[]{ 
      new Contact (LastName = '999Test1', Email = '999test@test.com', Case_Priority__c = '2'),
		  new Contact (LastName = '999Test2', Email = '999test@test.com', Case_Priority__c = '2'),
		  new Contact (LastName = '999Test3', Email = '999fake@fake.com', Case_Priority__c = '1'),
		  new Contact (LastName = '999Test4', Email = '999only1@example.com', Case_Priority__c = '4'),
	    new Contact (LastName = '999Test5', Email = '999no@email.com', Case_Priority__c = '3'),
		  new Contact (LastName = '999Test6', Email = '999no6@email.com'),
		  new Contact (LastName = '999Test7', Email = '999nonumber@email.com', Case_Priority__c = 'NOTANUMBER'),
		  new Contact (LastName = '999Test8', Email = '999noaccount@email.com', Case_Priority__c = '2'),
		  new Contact (LastName = '999Test9', Email = '999dupe@email.com', Case_Priority__c = '2')
    };
    insert testcontacts;
		
    Map <String, Id> testcontactid = new Map<String, Id> ();
		
		for (Contact c : testcontacts){
		  system.debug ('LastName: ' + c.LastName + 'Id: ' + c.Id);
      testcontactid.put(c.LastName, c.Id);
		}
		
    Account_Contact__c[] testjunctiontable = new Account_Contact__c[]{
		   new Account_Contact__c (Account__c = testacctid.get('999TestAcct1'), Contact__c = testcontactid.get('999Test1')),
			 new Account_Contact__c (Account__c = testacctid.get('999TestAcct1'), Contact__c = testcontactid.get('999Test4')),
			 new Account_Contact__c (Account__c = testacctid.get('999TestAcct4'), Contact__c = testcontactid.get('999Test6')),
			 new Account_Contact__c (Account__c = testacctid.get('999TestAcct2'), Contact__c = testcontactid.get('999Test7')),
			 new Account_Contact__c (Account__c = testacctid.get('999TestAcct3'), Contact__c = testcontactid.get('999Test3')),
			 new Account_Contact__c (Account__c = testacctid.get('999TestAcct1'), Contact__c = testcontactid.get('999Test9')),
			 new Account_Contact__c (Account__c = testacctid.get('999TestAcct3'), Contact__c = testcontactid.get('999Test9'))
    };
		insert testjunctiontable;
		
		test.startTest();
		
		Case[] testcases = new Case[] {
		  new Case(Subject = 'Test Case1', SuppliedName='Bob Smith', SuppliedEmail= '999test@test.com'),
			new Case(Subject = 'Test Case2', SuppliedName='Bob Smith', SuppliedEmail= '999only1@example.com'),
			new Case(Subject = 'Test Case3', SuppliedName='Bob Smith',SuppliedEmail= '999fake@fake.com'),
			new Case(Subject = 'Test Case4',SuppliedName='Bob Smith', SuppliedEmail= '999notin@thedatabase.com'),
			new Case(Subject = 'Test Case5', SuppliedName='Bob Smith',SuppliedEmail= '999nonumber@email.com'),
			new Case(Subject = 'Test Case6',SuppliedName='Bob Smith', SuppliedEmail= '999noaccount@email.com'),
			new Case(Subject = 'Test Case7', SuppliedName='Bob Smith',SuppliedEmail= '999dupe@email.com'),
			new Case(Subject = 'Test Case8', SuppliedName = 'Test User', SuppliedEmail= 'neverevergoingtobeinthere@test.com'),
			new Case(Subject = 'Test Case9', SuppliedName = 'Test', SuppliedEmail= 'neverevergoingtobeinthere2@test.com'),
			new Case(Subject = 'Test Case10', SuppliedName = 'Three Named Person', SuppliedEmail= 'neverevergoingtobeinthere3@test.com'),
			new Case(Subject = 'Test Case11', SuppliedName = 'Exactly One', SuppliedEmail= '999no6@email.com')
    };
		//Test.startTest();
    insert testcases;
    //Test.stopTest();
    
    
        
    Set<Id> CaseIDs = new Set<Id>(); 		
			
		for (Case c : testcases) {
			CaseIDs.add(c.Id);	
		}
		  
		Map <String, String> TestCasePriority = new Map<String, String> ();
		Map <String, String> TestCaseAcctName = new Map<String, String> ();
		Map <String, String> TestCaseContactName = new Map<String, String> ();
				
		for (Case c : [SELECT Id, Subject, Priority, Account.Name, Contact.LastName FROM Case WHERE Id IN : CaseIDs]){
		  TestCasePriority.put(c.Subject, c.Priority);
		  TestCaseAcctName.put(c.Subject, c.Account.Name);
			TestCaseContactName.put(c.Subject, c.Contact.LastName);
		}
		  
		system.debug(TestCasePriority.get('Test Case1'));
		//system.assert(TestCasePriority.get('Test Case1') == '1'); ***********
		system.debug('ACCOUNT NAME IS: ' + TestCaseAcctName.get('Test Case1'));
			
		//system.assert(TestCasePriority.get('Test Case2') == '1'); ***********
		system.debug('MIKEY WANTS TO KNOW WHAT IS RIGHT HERE: ' +TestCasePriority.get('Test Case3'));		
		//system.assert(TestCasePriority.get('Test Case3') == '1'); *********
		  // Need to be careful...this case will have the default priority value		
				
		//system.assert(TestCasePriority.get('Test Case5') == '2'); **********
		//system.assert(TestCasePriority.get('Test Case6') == '2');  *********
		  
		  
		EmailServicesHandler objEmail = new EmailServicesHandler();
    
    Messaging.InboundEmail.Binaryattachment emailAttachment = new Messaging.InboundEmail.Binaryattachment();
    emailAttachment.Body = Blob.valueOf('Some Text');
    emailAttachment.mimeTypeSubType = 'application/pdf';
    emailAttachment.fileName = 'Test File';
        
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
     
    email.toAddresses = new String[] {'dsmaint@expedia.com','geosup@expedia.com'};
    email.fromAddress = 'yuk@yucky.com';
    email.ccAddresses = new String[] {'this@that.com','that@this.com'};
    email.plainTextBody = 'This is a test, only a test';
    email.htmlBody = email.plainTextBody;
    email.subject = 'This is a test';
    email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { emailAttachment };
    
    Messaging.InboundEmail.Textattachment emailTextAttachment = new Messaging.InboundEmail.Textattachment();
    emailTextAttachment.Body = 'Some Text';
    emailTextAttachment.mimeTypeSubType = 'text/plain';
    emailTextAttachment.fileName = 'Test File.txt';
        
    email.Textattachments = new Messaging.inboundEmail.Textattachment[] { emailTextAttachment };
        
    envelope.toAddress = 'dsmaint@expedia.com';
    envelope.fromAddress = 'yuk@yucky.com';
           
    result = objEmail.handleInboundEmail(email, envelope);
        
    //email.subject = email.subject;
    //result = objEmail.handleInboundEmail(email, envelope);
    
    CaseClass objCase = new CaseClass();
    
    Case testCaseGeo1 = objCase.processEmail(email,'Geography',null);
     
    email.subject = email.subject + ' ' + Utilities.getCaseThreadId(testCaseGeo1.Id);
    email.plainTextBody = email.plainTextBody + '\n\n\n' + Utilities.getCaseThreadId(testCaseGeo1.Id);
    //Case testCaseGeo2 = objCase.processEmail(email,'Geography',null);
    
  }
}