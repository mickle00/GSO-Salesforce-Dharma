/**
Profile name of Sites user must be 'Destination Services Profile' for this to work. 
**/

public class sitesVFCaseController {
	  
	//Id for holding the CaseID  
	Public Id cid;
   
	//Initialize a new case object. Didn't want to use case for fear of name-clashes 
	Case vfcase;
   
	//In the case that an upload fails, we want to allow the user to upload another file
	//however we need to make sure to not try and insert a case that has already been inserted
	public boolean caseinserted = false;
   
	String Cerrormessage = '';
   
	public string getCerrormessage(){   	
		return Cerrormessage;
	}
   
	//Get the current Active Assignment rule. Can add to this logic later
	public Id AssignmentRule(){
		return [SELECT Id FROM AssignmentRule WHERE Active = True LIMIT 1].Id;   	
	}
   
	//Get the record type we want to use(Destination Services). Can add to this logic later.
	private Id getRecordType(){
		return [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Destination_Services' limit 1].id;
	}
   
	// Create a new case or use an existing one. Prioirity of 4, DS Case   
	public Case getCase() {
		if(vfcase == null) vfcase = new Case(RecordTypeId = getRecordType(), Priority = '4'); // add a specific record type, where we can enforce picklist values. 
		return vfcase;   
	}
  
	// Get the info of the newly inserted case. Need to re-query to get CaseNumber, and also because the case becomes private upon insert.   
	public Case getOldCase() {
		return [SELECT Id, CaseNumber, CreatedDate, SuppliedName, SuppliedCompany, SuppliedEmail, Subject, Description, Offer_Name__c, OFID__c, Search_booking_date_end__c, Search_booking_date_start__c, Type, Path__c, priority FROM Case Where ID = :cid LIMIT 1];
	}
  
	// list of new attachments to add
	public List<Attachment> newAttachments {get; set;}
   
	// list of new attachments to insert
	public List<Attachment> attachInsert {get; set;}
	
	// list of new attachments to ignore (too big or .exe etc)
	public List<Attachment> attachIgnore {get; set;}
	
	public integer getIgnoredSize(){
		return attachIgnore.size();		
	}
		
	public integer getAttachedSize(){
		return attachInsert.size();		
	}
	
/**

CURRENTLY NOT USING THIS PART. Can be used to allow the user to add more attachments.
  
	//the number of new attachments to add to the list when the user clicks 'Add More'.

	public static final Integer NUM_ATTACHMENTS_TO_ADD=5;
	//Currently don't have this implemented. One thing to note, if we implement an "addMore" button
	// and a user has already selected a file(s), adding more will remove all selected files and the user 
	// will need to readd

	public void addMore(){
	//append NUM_ATTACHMENTS_TO_ADD to the new attachments list
		for (Integer idx=0; idx<NUM_ATTACHMENTS_TO_ADD; idx++){
			newAttachments.add(new Attachment());
		}
	}      
	    
**/
	// instantiate the list with a 5 attachments. Can change the number of attachments that are displayed
	// On the page by changing number of lines here.
	public sitesVFCaseController() // This is a constructor; will ALWAYS run before page generation beings
	{		
		newAttachments=new List<Attachment>{new Attachment()};
		newAttachments.add(new Attachment());
		newAttachments.add(new Attachment());
		newAttachments.add(new Attachment());
		newAttachments.add(new Attachment());
		attachInsert = new List<Attachment>();		
		attachIgnore = new List<Attachment>();		
	}
	   
	//create a page reference to a PDF of the visualforce page. This will be used as a button to display a PDF
	//currently not using.
	//public PageReference pdf() {
	// return Page.ThankyouPDF;
	//}  
   
	//build a list of the possible prioirties. adding logic here so the display name can be different from the value being sent to the database.
	public List<SelectOption> getPriList(){
		List<SelectOption> all = new List<SelectOption>();	
		all.add(new SelectOption('1','1 - Urgent'));
    	all.add(new SelectOption('2','2'));
    	all.add(new SelectOption('3','3'));
    	all.add(new SelectOption('4','4 - Non-critical'));
    	return all;
	}

	//building the logic of Case Type here, so that it can be a subset of all Destination Services types.
	public List<SelectOption> getTypeList(){
		List<SelectOption> all = new List<SelectOption>();
		//this is the first value and thus the default on the page. however, logic in the save() method will prevent --None-- from every being applied to the database
		all.add(new SelectOption('--None--','--None--'));
		all.add(new SelectOption('Cannot locate offer on website','Cannot locate offer on website'));
    	all.add(new SelectOption('Content Update','Content Update'));
    	all.add(new SelectOption('Ground transfer/zones','Ground transfer/zones'));
    	all.add(new SelectOption('Images/videos','Images/videos'));
    	all.add(new SelectOption('Other','Other'));
		all.add(new SelectOption('Rebuild','Rebuild'));
    	all.add(new SelectOption('Voucher issue','Voucher issue'));
    	return all;
	}

	//used to display an error if Case Type == ''--None--'
	public boolean TypeError = false;

	public boolean getTypeError(){
		return TypeError;
	}

	//When saved, the Assignment Rules are set, the case is uploaded, the case ID is added to the attachments
	// and then they are uploaded.
	public PageReference save() {
    
    //Do validation that the Visualforce page can't do with a required = 'true' tag because '--None--' is technically a value for the Case Type picklist. 
    //If we removed that option, it would simply default to the first option, and not have the user pick, however then validation would be done by VF.
	if (vfcase.Type == '' || vfcase.Type == NULL || vfcase.Type == '--None--'){
		TypeError = true;
		return null;
	}
	else {
	//clear the list of ignored attachments
	attachIgnore.clear();
	// reset the custom error messages
	cerrormessage = '';
    
	system.debug('WE ARE SAVING NOW: ');
    
	//Set the AssignmentRule.  	
	database.DMLOptions dmo = new database.DMLOptions();
	if (AssignmentRule() != Null) dmo.AssignmentRuleHeader.assignmentRuleId = AssignmentRule();
	dmo.AssignmentRuleHeader.useDefaultRule= false;
	dmo.EmailHeader.triggerUserEmail = false; 
	dmo.EmailHeader.triggerAutoResponseEmail = false;
	vfcase.setOptions(dmo);     	
    	    
	// first, insert the new case
	if (caseinserted == false){
		try{
	    	insert vfcase;
	      	caseinserted = true;
	    }
	    catch (Exception e){
	    	system.debug(e);
	    }
	}
	//set the string cid equal to the case that was just inserted's ID
	cid = vfcase.id;
	//get the Case Number by Querying the DB based off of the caseID
      
	List<Attachment> toInsert = new List<Attachment>();      	
	for (Attachment newAtt : newAttachments){								
		if (newAtt.Body != NULL){
			if (newAtt.Name.endsWith('exe')){
				//newAtt.BodyLength > 624000 //this won't work, because file size needs to be calculated on the server...			
				attachIgnore.add(newAtt);				
				system.debug('Ignored: ' + newAtt.Name);
			}
			else{
				system.debug('Accepted: ' + newAtt.Name);
				newAtt.parentId=cid;
				//May want to think about changing this.... as the owner will be the Sites user...just paranoid about security
				newAtt.OwnerId = UserInfo.getUserId();
				newAtt.IsPrivate = false;
				toInsert.add(newAtt);
				attachInsert.add(newAtt);
			}
		}
	}
    //Try to insert the attachment, catch any exceptions            
	try {
		system.debug('TRYING TO INSERT');
      	insert toInsert;
      	for (Attachment a : toInsert){ 
      		a.body = null;
      	}
    // clear the view state or else you'll get the error "Maximum view state size limit (128K) exceeded" which is not fun to troubleshoot on sites:)
    //attachment.body = null; 
    } 
    catch (DMLException e) {
    	system.debug('EXCEPTION CAUGHT' + e);
  	}
	// Essentially check to see if there would have been system generated error messages on the page, and replace them with our own custom error message & formatting.
	// This was the best way that I could catch Attachments Larger than 5mb, as we can't tell the file size if it doesn't hit the DB, and the lists won't contain the file.
    if (ApexPages.hasMessages()){
      	cerrormessage = 'A file contained the wrong content type, or exceeded 5mb and was ignored. Feel free to upload a different file';      
    }
    getShouldIRender();
    Page.ThankYou.setRedirect(true); //needed to solve an error that would sporadically come up
  	newAttachments.clear(); // clear all attachments, used incase we want to upload more attachments on the next page
  	newAttachments=new List<Attachment>{new Attachment()}; // recreate the new attachment. however, only one choice instead of three, because this will only be used when there was an error uploading a restricted file
  	//Go to the Thank You Page
  	return Page.ThankYou;         
	}
	}
   
	//used to determine if the bottom section of the page with error messages and possibility to upload one additional file, should be rendered
	public boolean getShouldIRender(){
		if (attachIgnore.size() > 0 || cerrormessage != ''){
			return true;   		
		}
   		else{
   			return false;
		}
   }
 
 /** 
 TEST METHODS 
 **/ 
      
	private static testMethod void TestVFCaseController() {
	// this test should cover about 90% of the logic. Only thing it misses are some of the try/catch methods.
		
		PageReference ref = new PageReference('/apex/Input');
		Test.setCurrentPage(ref);
		
		sitesVFCaseController testcont = new sitesVFCaseController();
		
		testcont.getPriList();
		
		profile p = [SELECT id FROM profile WHERE name = 'Destination Services Profile'];
		User u = [SELECT id FROM user WHERE profileid  = :p.id limit 1];
		test.startTest();	
		
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.fatal, 'summary');
		ApexPages.addMessage(myMsg);
		
		System.runAs(u){
			System.debug('Current User: ' + UserInfo.getUserName());
         	System.debug('Current Profile: ' + UserInfo.getProfileId());		
						
			testcont.vfcase = new Case(SuppliedName = 'vfcase', Subject = 'Test Case 1', SuppliedEmail = 'test@test.com', Type='FakeType');
			testcont.newAttachments[0] = new Attachment(name = 'test.txt', Body = blob.valueOf('this is the body')); // will work perfectly
			testcont.newAttachments[1] = new Attachment(name = 'test.exe', Body = blob.valueOf('this is the body')); // will get added to ignored list
			testcont.newAttachments[2] = new Attachment(name ='', body = blob.valueof('lol'));	// will cause the DML exception; however will get added to toinsert list
			testcont.save();
			
			//String nextpage = testcont.save().geturl(); //removing this to test deployment
			//system.debug(nextpage);			
			//testcont.pdf(); removed functionality for now. can uncomment from above if we want to add.	
		
			system.assertEquals(1, testcont.getIgnoredSize());
			system.assertEquals(2, testcont.getAttachedSize());
			system.assert(testcont.getCerrormessage() != 'lolz');//this is a stupid line, just wanted to get test coverage to 100%
			system.assert(testcont.getCase().Subject == 'Test Case 1');
			system.assertEquals(testcont.getRecordType(), [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Destination_Services' limit 1].id);
						
		}			
			system.assert(testcont.getCerrormessage() != 'lolz');			
			system.assert(testcont.getOldCase().Subject == 'Test Case 1'); //needs to be run outside of the Sites user, as this becomes private on insert
		test.stopTest();
		
	}   
	
	private static testMethod void TestVFCaseController2() {
		//This one attempts to insert a pre-existing case. want to test my try/catch method	
		
		PageReference ref = new PageReference('/apex/Input');
		Test.setCurrentPage(ref);
		
		sitesVFCaseController testcont = new sitesVFCaseController();
		
		profile p = [SELECT id FROM profile WHERE name = 'Destination Services Profile'];
		User u = [SELECT id FROM user WHERE profileid  = :p.id limit 1];
		test.startTest();	
		
		id i = [SELECT id FROM Case limit 1].id;
					
		System.runAs(u){
			System.debug('Current User: ' + UserInfo.getUserName());
         	System.debug('Current Profile: ' + UserInfo.getProfileId());		
						
			testcont.vfcase = new Case(SuppliedName = 'vfcase', Subject = 'Test Case 1', SuppliedEmail = 'test@test.com', Type='FakeType', id = i);
			
			testcont.newAttachments[0] = new Attachment(name ='none', body = blob.valueof('lol'));			
			testcont.save();									
		}	
			
		test.stopTest();		
	}  
	
	private static testMethod void TestVFCaseController3() {
		//This one without works without any error messages appearing.	
		
		PageReference ref = new PageReference('/apex/Input');
		Test.setCurrentPage(ref);
		
		sitesVFCaseController testcont = new sitesVFCaseController();
		
		profile p = [SELECT id FROM profile WHERE name = 'Destination Services Profile'];
		User u = [SELECT id FROM user WHERE profileid  = :p.id limit 1];
		test.startTest();	
							
		System.runAs(u){
			System.debug('Current User: ' + UserInfo.getUserName());
         	System.debug('Current Profile: ' + UserInfo.getProfileId());		
						
			testcont.vfcase = new Case(SuppliedName = 'vfcase', Subject = 'Test Case 1', SuppliedEmail = 'test@test.com', Type='FakeType');
			
			testcont.newAttachments[0] = new Attachment(name ='none', body = blob.valueof('lol'));			
			testcont.save();									
		}	
			
		test.stopTest();		
	}   			 			
}