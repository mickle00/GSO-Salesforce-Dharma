public class CaseClass {
  public Map<String,Contact> createdContactsByEmail = new Map<String,Contact>(); 
  public Map<String,Contact> existingContacts = new Map<String,Contact>();
  public Map<String,String> casePriority = new Map<String,String>();
  public Map<String,Id> emailContactId = new Map<String,Id>();
  public Map<String,Id> emailAccountId = new Map<String,Id>();
  public Map<String,Id> nameToQueueId = new Map<String,Id>(); 

  //____________________________________________________
  public Map<String,List<Account_Contact__c>> emailToListOfAccountContacts = new Map<String,List<Account_Contact__c>>();
  public Map<String,List<Contact>> emailToListOfContacts = new Map<String,List<Contact>>(); 
  //----------------------------------------------------
    
  public String sfdcURL = 'https://na8.salesforce.com/'; // CHANGE Per environment
  public CaseClass(){}
    
  public Case processEmail(Messaging.Inboundemail email, String recordType, String team, id languageId) {
        
    Case myCase = new Case();
    EmailMessage newEmail = new EmailMessage();
    Map<String,RecordType> mapRecordTypes = Utilities.getRecordTypesMap('Case',true);
      
    EmailMessageClass objEmail = new EmailMessageClass();
    TaskClass objTask = new TaskClass();  
    Id replyEmailCaseParentId = objTask.getTaskParentId(email.subject); 
        
    if(replyEmailCaseParentId != null) { // creat new email message object  
      myCase = this.updateCase(replyEmailCaseParentId, email);  
    }
    else{ // New Case  
      myCase = this.insertCase(email,recordType, mapRecordTypes, team, languageId);  
    }
    
    if(myCase != null){ //handle any attachments
      EmailUtilities objEmailUtilities = new EmailUtilities();
      objEmailUtilities.saveAttachmentsToParentFromInboundEmail(email, myCase.Id, true);        
    }
    return myCase;
  }
  
       
  public void linkAccountAndContactToCase(Case[] cases){
        
    system.debug('>>>> linkAccountAndContactToCase size = ' + cases.size());
        
    ContactClass objContact = new ContactClass();
    AccountContactClass objAccountContact = new AccountContactClass();
    List<Case> casesToCreate = new List<Case>();
      
      // 1.) Get Set of all the emails in the incoming cases
      Set<String> suppliedEmails = new Set<String>(this.getSuppliedEmails(cases));
      
      // 2.) Get a map with email, supplied name for parsing into fname and lname
      Map<String,String> suppliedEmailsAndNames = new Map<String,String>(this.getSuppliedEmailsAndNames(cases));
      
      Set<String> emailContactKeys = new Set<String>(EmailUtilities.getEmailContactKeys(cases)); 
      
      // 3.) Get All existing contacts <Email, Contact>
      //existingContacts = objContact.getExistingContacts(suppliedEmails);
      emailToListOfContacts = objContact.getExistingContacts(suppliedEmails);
      
      // Set of all matching emails in contact table
      Set<String> existingContactEmails = new Set<String>(emailToListOfContacts.keySet());
       
      // 4.) Get a List of contacts that need to be added
      List<Contact> contactsToCreate = new List<Contact>(objContact.getContactsToCreate(suppliedEmails, suppliedEmailsAndNames, existingContactEmails));
      
      system.debug('<<<<<<<<<<<<<before contact to create>>>>>>>>>>>');
      try{ //insert new contacts
        
        insert contactsToCreate;
      }
      catch (system.Dmlexception e) {
        system.debug('DML Exception >>> ' + e.getMessage());
        return;
      }
      
      // 5.) add new contacts to map of existing contacts
      for(Contact c : contactsToCreate){
        List<Contact> newContact = new List<Contact>();
        newContact.add(c);
        emailToListOfContacts.put(c.Email,newContact);
        createdContactsByEmail.put(c.Email,c);
      }
        
      // 6.)  Get a map of all emails and the number of times found in AccountContacts
      Map<String,Integer> emailCount = new Map<String,Integer>();   
      emailCount = objAccountContact.getEmailCountsForEmails(suppliedEmails);
    
      // 7.)  Get a list of all AccountContact Records, Contact Id, Account Id, Case Priority for All Emails
      List<Account_Contact__c> matchingAccountContacts = objAccountContact.getAllByContactEmail(suppliedEmails);
      
      // 7a.) Get a map of email to list of account contacts
      emailToListOfAccountContacts = objAccountContact.getEmailToListOfAccountContacts(matchingAccountContacts);
      
      // 8.) Query the AccountContactTable for contacts with this email address
      for (Account_Contact__c accountContact : matchingAccountContacts) {
        
        //TODO: TO CHANGE METHOD NAME
        this.editMaps(accountContact);   
      }
      
      for (Case thisCase : cases){
        
        // get Contacts from Map to iterate over them 
        system.debug('>>>>>> CASE CLASS inside Case LOOP');
        system.debug('>>>> SUPPLIED EMAIL IS = ' + thisCase.suppliedEmail); 
        //system.debug('Size of loop is' + emailToListOfContacts.get(thisCase.suppliedEmail).size());           
        system.debug('Existing Contacts is  ' + existingContacts);     
      
        //this loop has 0 items in it...         
        for(Contact c : emailToListOfContacts.get(thisCase.suppliedEmail)){

          system.debug ('CONTACT PRIORITY = >>>>>>>' + c.Case_Priority__c);
          String contactPriority = c.Case_Priority__c;          
          String accountPriority = casePriority.get(c.email);
        
          if(!casePriority.containsKey(c.email) || casePriority.get(c.email) == NULL || casePriority.get(c.email) == '') { //mps
              casePriority.put(c.email,c.Case_Priority__c);
          }
          else {
              if(contactPriority != null) {
                  try {
                      if(integer.valueOf(contactPriority) < integer.valueOf(accountPriority)){
                        CasePriority.put(c.email,c.Case_Priority__c);
                      }
                  }
                catch (TypeException e) {
                    system.debug('Exception: ' + e);
                }
              }
          }
        }
        // Get the size of the list of contacts for the email
        Integer contactListSize = emailToListOfContacts.get(thisCase.suppliedEmail).size();
        
        // get the list of contacts by email and check size of list 
        if(contactListSize == 0) {
            // do something
            system.debug('Why dont we have a contact?');
        }
        else {
          if (casePriority.get(thisCase.SuppliedEmail) != NULL) thisCase.Priority = casePriority.get(thisCase.SuppliedEmail); //mps
          Integer accountContactListSize = 0;
          system.debug('*** CaseClass.LinkAccountsAndContacts' + emailToListOfAccountContacts.get(thisCase.suppliedEmail));
          if(emailToListOfAccountContacts.get(thisCase.suppliedEmail) != null) {
            accountContactListSize = emailToListOfAccountContacts.get(thisCase.suppliedEmail).size();
          }
            
          if(contactListSize == 1) {
            thisCase.ContactId = emailToListOfContacts.get(thisCase.suppliedEmail)[0].Id;               
            
            if(accountContactListSize == 0) {
              thisCase.Contact_Account_Lookup_Results__c = 'No Account Contacts';   
            }
            else if(accountContactListSize == 1) {
                thisCase.AccountId = emailToListOfAccountContacts.get(thisCase.suppliedEmail)[0].Account__c;
                thisCase.Contact_Account_Lookup_Results__c = 'Only One Match Found; Linked'; //MPS Added
            }
            else { // List of account contacts 
                
                // Build out web lookup status field to display possible accounts per contact
                thisCase.Contact_Account_Lookup_Results__c = Utilities.truncateField(this.buildAccountContactPossiblesText(emailToListOfAccountContacts.get(thisCase.suppliedEmail)),25000,'<br/>');
            }
          }
                 
          if(contactListSize > 1) {
            if(accountContactListSize > 0){                 
              thisCase.Contact_Account_Lookup_Results__c = Utilities.truncateField(this.buildAllPossiblesText(emailToListOfAccountContacts.get(thisCase.suppliedEmail), emailToListofContacts.get(thisCase.suppliedEmail)), 25000, '<br/>');
            }else{
              List<Account_Contact__c> noAC = new List<Account_Contact__c>(); 
              thisCase.Contact_Account_Lookup_Results__c = Utilities.truncateField(this.buildAllPossiblesText(noAC, emailToListofContacts.get(thisCase.suppliedEmail)), 25000, '<br/>');                         
            }
          }       
        }
      } // END Case Loop
      system.debug('End of time size of loop is' + existingContacts.values().size());
    } // END linkAccountAndContactToCase
    
    
  public void afterUpdateCloneAndTransferCase(Map<Id, Case> caseIdtoNewCaseMap, Map<Id, Case> caseIdtoOldCaseMap){
 
    queueNameToId = Utilities.getQueueNameToIdMap('Case');   
    Map<String, RecordType> caseRecordTypes = Utilities.getRecordTypesMap('Case', false);
    
    for (RecordType myRecordType : caseRecordTypes.values()){
      queueNameToRecordTypeId.put(myRecordType.Name, myRecordType.Id);
      RecordTypeIdToName.put(myRecordType.Id, myRecordType.Name);
    }    
    
    for (Case myCase : caseIdtoNewCaseMap.values()){
      // if Case was changed to either Closed - Transferred or Transferred from any other Status AND the Additional Status returns a Record Type & Queue Name
      // 1. see if Case Status just got changed to Closed - Transferred
      // OR 
      // 2. see if Case Status just got changed to Transferred
      // AND 
      // 3. trap to make sure that Record Type AND Queue Maps return values. Don't want a DML Insert Error for a NULL value
      if (((myCase.Status == 'Closed - Transferred' && caseIdtoOldCaseMap.get(myCase.Id).Status != 'Closed - Transferred') ||
         (myCase.Status == 'Transferred' && caseIdtoOldCaseMap.get(myCase.Id).Status != 'Transferred')) && 
         (queueNameToRecordTypeId.get(myCase.Additional_Status__c) != NULL && queueNameToId.get(myCase.Additional_Status__c) != NULL)) {
          // Clone case into child case
          Case clonedCase = cloneChildCase(myCase);
          casesToInsert.add(clonedCase);        
      }    
    }// end for loop      
    insert casesToInsert;
  }    
    
  public void assignCaseToLinguist(Case parentCase, List<String> languages) {
    
    // create a child case for each language selected
  	for(Language__c language : [Select Id, Name From Language__c Where Id IN : languages]) {
        // Clone case into child case
        Case clonedCase = cloneChildCase(parentCase, language);
        casesToInsert.add(clonedCase);
    }// end for loop
    
    insert casesToInsert;
  }
  
  public static Case findById(Id myCaseId){
        CaseClass caseObj = new CaseClass();
        return caseObj.getCase(myCaseId);
    }

    /////// Private Methods
        
    private Map<String, Id> queueNameToId = new Map<String, Id>();
    private Map<String, Id> queueNameToRecordTypeId = new Map<String, Id>();
    private Map<Id, String> RecordTypeIdToName = new Map<Id, String>();
    private List<Case> casesToInsert = new List<Case>();  
    
    private Case insertCase(Messaging.InboundEmail email, String recordType, Map<String,RecordType> mapRecordTypes, String team, id languageId) {
      
      String plainTextEmailRecipientsList = EmailUtilities.buildEmailRecipientsText(email.toAddresses, email.ccAddresses, '\n');
      String htmlBodyEmailRecipientsList = EmailUtilities.buildEmailRecipientsText(email.toAddresses, email.ccAddresses, '<br/>');
      
      String plainTextBody = email.plainTextBody;
      String htmlBody = email.htmlBody;
      
      //GoogleTranslate.TranslationResult myTranslationResult = new GoogleTranslate.TranslationResult(plainTextBody);      
      
      String plainTextDescription;
      String richTextDescription;
      
      String[] unformattedToAddresses = new String[]{}; 
      String[] unformattedCCAddresses = new String[]{};
      
      unformattedToAddresses = EmailUtilities.unformattedEmailAddresses(email.toAddresses);
      unformattedCCAddresses = EmailUtilities.unformattedEmailAddresses(email.ccAddresses);
      
      String emailRecipients = EmailUtilities.buildEmailRecipientsField(unformattedToAddresses) + '\n' +
                               EmailUtilities.buildEmailRecipientsField(unformattedCCAddresses);
           
      /**
      
      if(this.supportRequestCase(recordType)) {
        //plainTextDescription =  email.plainTextBody;
        //richTextDescription =  email.htmlBody;
        htmlBody = '';
      }  
      else {
        if(starRatingsCase(recordType) && 
          fromExpediaPartnerCentral(email.fromAddress)) {
            
          plainTextDescription = plainTextEmailRecipientsList + parseStarRatingsEmailFromEPC(plainTextBody, '\n');  
          richTextDescription = plainTextEmailRecipientsList + '<br/><br/>' + parseStarRatingsEmailFromEPC(htmlBody, '<br/>');
        }
        else {
            system.debug('plainTextBody=' + plainTextBody);
            if(plainTextBody == null) {
                plainTextBody = htmlbody;
                plainTextBody = plainTextBody.replace('<br>', '\n');
                plainTextBody = plainTextBody.replace('<br/>', '\n');
                system.debug('IN PLAIN TEXT=' + plainTextBody);
            }
          plainTextDescription = plainTextEmailRecipientsList + plainTextBody;     
          richTextDescription = htmlBodyEmailRecipientsList + htmlBody;
        }
      }
      **/
      system.debug('SOURCE LANGUAGE');
      //system.debug(myTranslationResult.getSourceLanguage());      
      Case myCase = new Case(Description = plainTextBody
                            ,Subject = email.subject
                            ,SuppliedEmail = email.fromAddress
                            ,SuppliedName = email.fromName
                            ,RecordTypeId = mapRecordTypes.get(recordType).Id
                            ,Origin = this.getOrigin(email.fromAddress)
                            ,Email_Recipients__c = Utilities.truncateField(emailRecipients, 255,'\n')
                            ,Send_auto_response__c = sendAutoResponseEmail(email.fromAddress)
                            ,Team__c = team
                            //,Language__c = this.getLanguageIdByAbbreviation(myTranslationResult.getSourceLanguage())
                            //,Translation_Confidence__c = myTranslationResult.getConfidence()
                            //,Translated_Description__c = myTranslationResult.getTranslation()
                           // ,Description_Rich_Text__c = myTranslationResult.getTranslation()                  
                            );
                            
      system.debug('MYCASE.Description=' + myCase.Description);
      // Get requestor (User) if case is for a support request
      if(this.supportRequestCase(recordType)) myCase.Requestor__c = this.getRequestorId(email.fromAddress);
                             
      database.DMLOptions dmo = new database.DMLOptions();
        
      AssignmentRule[] ar = [SELECT Id 
                               FROM AssignmentRule 
                              WHERE Active = True];
                               
      if(ar.size() != 0) {
        dmo.AssignmentRuleHeader.assignmentRuleId = ar[0].Id;
      }
      
      dmo.AssignmentRuleHeader.useDefaultRule = false;
      dmo.EmailHeader.triggerUserEmail = false;
      dmo.EmailHeader.triggerAutoResponseEmail = myCase.Send_auto_response__c;
      dmo.allowFieldTruncation = true;

      myCase.setOptions(dmo);

      try {
        insert myCase;
        // Requery the DB to get the new case number.
        // STUPID that we have to do this.
        // How can we return the new case number when record is inserted
        myCase = this.getCase(myCase.Id);
                   
        system.debug('*** CaseClass.CreateCase => RecordType = ' + myCase.RecordType.DeveloperName + ' ***');
                
        String subject = 'Thank you for contacting Expedia Support.  Case Number: ' + myCase.CaseNumber + ' ' + Utilities.getCaseThreadId(myCase.Id);
        
        String autoResponseEmailText = this.getNewCaseAutoResponseEmailText(myCase.caseNumber, myCase.Id, recordType, 
          email.toAddresses, email.ccAddresses, plainTextBody, email.subject);
        
        system.debug('*** CaseClass.CreateCase => Before Create EmailMessage ***');
          
        EmailMessageClass objEmail = new EmailMessageClass();
        // log original inbound email
        Id inboundEmailId = objEmail.createEmailMessage(myCase.Id, email.subject, email.fromAddress, 
            email.fromName, email.toAddresses, Utilities.truncateField(plainTextBody, 32000, '\n'), 
            EmailMessageClass.enumEmailStatus.read, true, email.ccAddresses);
              
        // save attachments to email message
        EmailUtilities objEmailUtil = new EmailUtilities();
        objEmailUtil.saveAttachmentsToParentFromInboundEmail(email, inboundEmailId, true);
          
      /*if(!EmailUtilities.suppressSpamEmails(email.fromAddress) && !EmailUtilities.suppressEmailAutoResponse(email.fromAddress)) {
          system.debug('*** CaseClass.CreatCase sending auto response for RecordType => ' + recordType + ' ***');
          system.debug('*** CaseClass.CreatCase sending auto response for ReplyToAlias => ' + EmailUtilities.getExpediaReplyToAlias(recordType) + ' ***');
          system.debug('*** CaseClass.CreatCase sending auto response for ReplyToAliasName => ' + EmailUtilities.getExpediaReplyToAliasName(recordType) + ' ***');
          
          String aliasKey = team == null ? recordType : team;
          system.debug('aliaskey => ' + aliasKey);
          
          EmailUtilities.sendSingleEmailMessage(new String[] {email.fromAddress}, new String[]{}, 
            EmailUtilities.getExpediaReplyToAlias(aliasKey), 
            EmailUtilities.getExpediaReplyToAliasName(aliasKey), autoResponseEmailText, subject, null);
              
          system.debug('*** CaseClass.CreateCase => Before Create Task ***');
          // create a task for auto response
          TaskClass objTask = new TaskClass();
          objTask.createTask(myCase.Id, myCase.ContactId, myCase.CreatedById, autoResponseEmailText, subject,
              'Completed', system.today());
          
          // log the auto repsonse message as an email message on the case                   
          objEmail.createEmailMessage(myCase.Id, subject, EmailUtilities.getExpediaReplyToAlias(aliasKey), 
            EmailUtilities.getExpediaReplyToAliasName(aliasKey), new String[]{email.fromAddress}, 
            Utilities.truncateField(autoResponseEmailText, 32000, '\n'), // test outside method 
            EmailMessageClass.enumEmailStatus.sent, false, new String[]{});
        }*/         
      }
      catch (system.Dmlexception dmlE) {
        system.debug('*** CaseClass.CreateCase After case Insert. DML Exception ' + dmlE.getMessage() + ' ***');
      }
      catch (Exception e) {
        system.debug('*** CaseClass.CreateCase After case Insert. Exception ' + e.getMessage() + ' ***');
      }
      
      return myCase;
    }
    
    private Id getLanguageIdByAbbreviation(string myAbbreviation){
    	system.debug(myAbbreviation);
    	return [SELECT Id FROM Language__c WHERE Abbreviation__c = :myAbbreviation limit 1].Id;
    }
    
    private Case updateCase(Id caseId, Messaging.InboundEmail email) {
      
      // get parent case      
      Case myCase = this.getCase(caseId);
        
      //update status to reflect reply email
      if (myCase.isClosed == true){
        myCase.Status = 'Closed - Reply';
      }
      else{
        myCase.Status = 'Reply: Customer Email';
      }
      
      String taskDescription = email.plainTextBody != null ? email.plainTextBody : email.subject;
        
      // create a task
      TaskClass objTask = new TaskClass();
      objTask.createTask(myCase.Id, myCase.ContactId, myCase.CreatedById, 
        taskDescription, email.subject,'Completed',system.today());
      
      String emailBody = email.plainTextBody != null ? email.plainTextBody : email.htmlBody;
      // log the email message
      EmailMessageClass objEmail = new EmailMessageClass();
      objEmail.createEmailMessage(myCase.Id, email.subject, email.fromAddress, email.fromName, email.toAddresses,
        Utilities.truncateField(emailBody, 32000, '\n'), 
        EmailMessageClass.enumEmailStatus.replied, true, email.ccAddresses);
        
      update myCase;
      
      return myCase;
      
    }  
    private void editMaps(Account_Contact__c accountContact) {
       // add the contacts id to the map emailcid with email address as the key
         this.emailContactId.put(accountContact.contact__r.email, accountContact.contact__c);
            // add the account id to the map emailaid with email address as the key
         this.emailAccountId.put(accountContact.contact__r.email, accountContact.account__c);
            // add the priority to the map. Because priority are queried desc, the last item should always be the lowest (1) priority
            // the NULLS FIRST part of the SOQL doesn't appear to be working because the value is transversed via a relationship query, so I'll simply weed out the NULLs...that wasn't very fun to troubleshoot        
            //system.debug('The account rating is ' + ac.account__r.rating);
         if (accountContact.account__r.rating != NULL) this.casePriority.put(accountContact.contact__r.email, accountContact.account__r.rating);        
        
    }
    
    private Map<String,Case> getSuppliedEmailsAndCases(Case[] cases){
        
      Map<String,Case> suppliedEmailsAndCases = new Map<String,Case>();
      for(Case c : cases) {
        suppliedEmailsAndCases.put(c.suppliedEmail,c);
      }
      return suppliedEmailsAndCases;
      
    } 
    
    private Map<String,String> getSuppliedEmailsAndNames(Case[] cases){
    
        Map<String,String> suppliedEmailsAndNames = new Map<String,String>();
        for(Case myCase : cases){
            if(myCase.SuppliedEmail != null && !suppliedEmailsAndNames.containsKey(myCase.SuppliedEmail)){
              suppliedEmailsAndNames.put(myCase.SuppliedEmail, myCase.SuppliedName);
            }
        }
        return suppliedEmailsAndNames;
    }
    
    
    private Set<String> getSuppliedEmails(Case[] cases){
        Set<String> suppliedEmails = new Set<String>();
        for(Case thisCase : cases) {
          if(thisCase.SuppliedEmail != null){
              system.debug('>>>>>> CaseClass.getSuppliedEmails Case Id = ' + thisCase.Id );
            suppliedEmails.add(thisCase.SuppliedEmail);
          } 
      }
        return suppliedEmails;
    }
   
    private Map<String,Integer> getEmailCount(Set<String> allEmails){
      List<AggregateResult> emailCountList = [Select Contact__r.Email,count(id) Total
                                                From Account_Contact__c
                                               Where Contact__r.Email IN :allEmails
                                               Group By Contact__r.Email
                                               Order by count(id) asc];
      
      Map<String,Integer> emailCounts = new Map<String,Integer>();
      
      for(AggregateResult ar : emailCountList){
        String email = (String) ar.get('Email');
        Integer total = (Integer) ar.get('Total');
        emailCounts.put(email,total);
      }
      return emailCounts;
        
    }
        
    private void singleAccountContactForEmail(Case myCase) {
        myCase.Priority = casePriority.get(myCase.suppliedEmail);
        // get contact id
        myCase.ContactId = emailContactId.get(myCase.suppliedEmail);
            // assign the account id
        myCase.AccountId = emailAccountId.get(myCase.suppliedEmail);
            // update status to show only one row was found
        myCase.Contact_Account_Lookup_Results__c = 'Only one match found; linked ' + String.valueOf(Date.today());
        
    }
    
    private String buildAllPossiblesText(List<Account_Contact__c> myAccountContacts, List<Contact> myContacts) {        
        String returnText;
        Id cid;
        returnText = Utilities.appendToString(returnText, '<Strong><i><u>Multiple Possibilities: </u></i></strong><br><ul>');
        for(Contact contact : myContacts){          
            cid = contact.id;           
            returnText = Utilities.appendToString(returnText, this.buildMultipleContactText(contact));
            returnText = Utilities.appendToString(returnText, '<ul>');          
            for(Account_Contact__c accountContact : myAccountContacts){             
                if (accountContact.Contact__c == cid){          
                    returnText = Utilities.appendToString(returnText,
                    this.buildMultipleAccountContactText(accountContact));                  
                }           
            }
             returnText = Utilities.appendToString(returnText, '</ul>');                                 
        }       
        return returnText; 
    }   
    
    private String buildAccountContactPossiblesText(List<Account_Contact__c> myAccountContacts) {
        
        String returnText;
        // Handles the account contact mapping
        //returnText = myAccountContacts.size() + ' possible Accounts found.' +
        //'<br/><br/><strong><u>Possibilities Include:</u></strong><ol>';
        for(Account_Contact__c accountContact : myAccountContacts){
          returnText = Utilities.appendToString(returnText,
            this.buildMultipleAccountContactText(accountContact)); 
        }
        return returnText;  // = Utilities.appendToString(returnText,'</ol>');
    }
    
    private String getEmailHtmlBodyText(String emailHtmlBody, String plainTextBody) {
      
      String htmlBody = '';
      if(emailHtmlBody == null) {
        htmlBody = plainTextBody;
      }
      else {
        htmlBody = emailHtmlBody;
      }
      return htmlBody;
      
    }
    
    private void noAccountContactForEmail(Case myCase){
        //ToDo
        myCase.ContactId = existingContacts.get(myCase.SuppliedEmail).Id;
        myCase.Contact_Account_Lookup_Results__c = createdContactsByEmail.containsKey(myCase.suppliedEmail) ? 'New contact created.' : 'Contact has no associated accounts.';
    }
    
    private String buildMultipleAccountContactText(Account_Contact__c accountContact) {
        //String contactURL = sfdcURL + accountContact.Contact__c;
        String accountURL = sfdcURL + accountContact.Account__c;
        
        return '<li><a href="' + accountURL + '">' + accountContact.Account__r.Name + '</li>';
        
    }
    
    private String buildMultipleContactText(Contact contact) {
        String contactURL = sfdcURL + contact.Id;
        String fullname;
        if (contact.FirstName == NULL){
          fullname = contact.LastName;
        }
        else{
          fullname = contact.FirstName + ' ' + contact.LastName;
        }
           
        return '<li><a href="' + contactURL + '">' + fullname + '</li>';       
    }
        
    private String getNewCaseAutoResponseEmailText(String caseNumber, Id caseId, String recordType, String[] toAddresses,
      String[] ccAddresses, String plainTextBody, String subject) {
      
      String teamSignature = 'Expedia Support';
      
      if (recordType == 'Geography') teamSignature = 'Expedia Geography Team';
      if (recordType == 'Destination_Services') teamSignature = 'Destination Services Content Team';
      if (recordType == 'Ticketing') teamSignature = 'GTP Support Team';
      if (recordType == 'Schedule_Change') teamSignature = 'ASC Support Team';
      if (recordType == 'Air_Fulfillment_Process_Support') teamSignature = 'Air Fulfillment - Workflow Management';
      if (recordType == 'Air_CPR') teamSignature = 'Air CPR Workflow Management';
      if (recordType == 'ADM') teamSignature = 'ADM Workflow Management';
      if (recordType == 'CarOps') teamSignature = 'Car Operations Workflow Management';
      if (recordType == 'Localisation') teamSignature = 'Localisation';
      if (recordType == 'User_Generated_Content') teamSignature = 'User Generated Content';
      
      
      return 'Thank you for contacting Expedia Support. A case has been created to help track your issue through its resolution.' +
             '\n\n' +
             'Your Case Number is: ' + caseNumber +'.' +
             '\n\n' +
             'Thank you,' +
             '\n\n' +
             teamSignature + '\n\n' +
             '* When sending us a reply, please ensure that the "Subject" of your email is unchanged ' + 
             'and includes the case reference number.\n\n' +
             '------------------Your Request----------------------\n\n' +
             'To: ' + Utilities.listToDelimitedString(EmailUtilities.unformattedEmailAddresses(toAddresses), ';') + '\n' +
             'CC: ' + Utilities.listToDelimitedString(EmailUtilities.unformattedEmailAddresses(ccAddresses), ';') + '\n' +
             'Subject: ' + subject + '\n' +  
             '\n' + plainTextBody +
             '\n\n\n\n' + Utilities.getCaseThreadId(caseId);
    }
        
    private Case getCase(Id caseId) {
      return [Select Id
                    ,AccountId
                    ,Status
                    ,isClosed
                    ,OwnerId
                    ,CreatedById
                    ,ContactId
                    ,Case.RecordType.DeveloperName
                    ,CaseNumber
                From Case
               Where Case.Id = :caseId]; 
    }

    
    // Clone the Case Subject & Description. Link it as a child to the original case. Build out some additional text in the Description box for additional clarifiction
    private Case cloneChildCase(Case parentCase){
      String caseDescription = ''; 
      if (parentCase.Description != null) caseDescription = parentCase.Description; 
      Case newCase = new Case (Subject = parentCase.Subject
                            ,ParentId = parentCase.Id
                            ,Description = 'Transferred from Case Number: '+ parentCase.CaseNumber +'\n Old Case Id: ' + parentCase.Id + '\n Transferred from: ' + RecordTypeIdToName.get(parentCase.RecordTypeId) + '\n-----------------------------------------------------------\n\n' + caseDescription
                            ,Description_Rich_Text__c = parentCase.Description_Rich_Text__c
                            ,suppliedEmail = parentCase.suppliedEmail
                            ,suppliedName = parentCase.suppliedName
                            ,ContactId = parentCase.ContactId
                            ,AccountId = parentCase.AccountId
                            ,Status = 'New - Transferred'  
                            ,OwnerId = queueNameToId.get(parentCase.Additional_Status__c)
                            ,RecordTypeId = queueNameToRecordTypeId.get(parentCase.Additional_Status__c));
    
      return newCase;
  }
  
    // Clone the Case Subject & Description. Link it as a child to the original case. Build out some additional text in the Description box for additional clarifiction
    private Case cloneChildCase(Case parentCase, Language__c language){
      String caseDescription = ''; 
      if (parentCase.Description != null) caseDescription = parentCase.Description; 
      queueNameToId = Utilities.getQueueNameToIdMap('Case');   
      
      Case newCase = new Case (Subject = parentCase.Subject
                            ,ParentId = parentCase.Id
                            ,Description = 'Transferred from Case Number: '+ parentCase.CaseNumber +'\n Old Case Id: ' + parentCase.Id + '\n Transferred from: ' + RecordTypeIdToName.get(parentCase.RecordTypeId) + '\n-----------------------------------------------------------\n\n' + caseDescription
                            ,Description_Rich_Text__c = parentCase.Description_Rich_Text__c
                            ,suppliedEmail = parentCase.suppliedEmail
                            ,suppliedName = parentCase.suppliedName
                            ,ContactId = parentCase.ContactId
                            ,AccountId = parentCase.AccountId
                            ,Status = 'Internal - Transfer'  
                            ,OwnerId = queueNameToId.get('Localisation')
      						,Team__c = 'Localisation - ' + language.Name
      						,Language__c = language.Id
                            ,Allocated__c = true
      						,Origin = parentCase.Origin
                            ,RecordTypeId = parentCase.RecordTypeId);
      
      return newCase;
  }

  private Boolean supportRequestCase(String recordType) {
    return recordType == 'Support_Request';
  }
  
  private Boolean starRatingsCase(String recordType) {
    return recordType == 'Star_Ratings';
  }
  
  private Id getRequestorId(String email) {
    // Get the user based on Email
    UserClass objUser = new UserClass();
    User thisUser = objUser.getUserByEmail(email);
    // Return the is if one is found otherwise return null
    return thisUser == null ? null : thisUser.Id;
  }
  
   private String getOrigin(String emailAddress) {
    // Get the value to put in the origin field of a case
    // default to Email and then set to EPC or AskExpedia of source is on
    String origin = 'Email (alias)';
    if(fromExpediaPartnerCentral(emailAddress)) origin = 'EPC';
    if(fromAskExpedia(emailAddress)) origin = 'AskExpedia';
    return origin;
  }
  
  private Boolean fromExpediaPartnerCentral(String emailAddress) {
    return emailAddress.contains('@expediapartnercentral.com') &&
           !emailAddress.contains('askexpedia');
  }
  
  private Boolean fromAskExpedia(String emailAddress) {
    return emailAddress.equals('askexpedia@expedia.com') ||
           emailAddress.equals('askexpedia@expediapartnercentral.com');
  }
  
  private String parseStarRatingsEmailFromEPC(String description, String newLine) {
    String parsedString;
    
    parsedString = description.substring(0, description.indexOf(':EndEmail:'));  
    // Split out email body lines of text
    String[] splitText = parsedString.split('::\n+');
    system.debug('StarRatings[0]= ' + splitText[0].toLowerCase());
    
    if(String.valueOf(splitText[0].replaceFirst('[\\w\\d]+:','').trim()) == '1'){
      parsedString = parseExpediaRatings(splitText, newLine);
    }
    else {
      parsedString = parseNationalRatings(splitText, newLine);
    }
    return parsedString;
  }
  
  private String parseExpediaRatings(List<String> description, String newLine) {
    String parsedString = 'Hotel Id = ' + description[1].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Hotel Name = ' + description[2].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'First Name = ' + description[3].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Last Name = ' + description[4].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Email = ' + description[5].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Phone = ' + description[6].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'PSG Account Id = ' + description[7].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Vendor Id = ' + description[8].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Structure type = ' + description[9].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Reasons for star review = ' + description[10].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Bathroom features = ' + description[11].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Mattress/bedding = ' + description[12].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Furnishings in standard room = ' + description[13].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Feature kitchenettes = ' + description[14].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Complimentary evening reception = ' + description[21].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Join star rating = ' + description[22].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'How condo is decorated = ' + description[24].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Bathroom facilities = ' + description[25].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Hotel managed restaurant = ' + description[17].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'No restaurant offer breakfast = ' + description[19].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Explain amenities services = ' + description[15].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Washer/dryer = ' + description[26].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Guest Reception hours = ' + description[27].replaceFirst('[\\w\\d]+:','') + newLine
                        + 'Frequency of housekeeping = ' + description[28].replaceFirst('[\\w\\d]+:','') + newLine;
                        
    return parsedString;
  }
  
  private String parseNationalRatings(List<String> description, String newLine) {
    String parsedString;
    String StarRatingAwarded = description[9].replaceFirst('[\\w\\d]+:',''); 
    String StarRatingAwardedBy = description[10].replaceFirst('[\\w\\d]+:',''); 
    String[] dateAwarded = description[11].replaceFirst('[\\w\\d]+:','').split('/'); 

    // split out date into Month Day Year to assemble in is SF friendly way 
    String dateAwardedMonth = dateAwarded[0]; 
    String dateAwardedDay = dateAwarded[1]; 
    String dateAwardedYear = dateAwarded[2]; 
    date fullDateAwarded = Date.valueOf(dateAwardedYear + '-' + dateAwardedMonth + '-' + dateAwardedDay); 

    parsedString = 'Update National Rating' + newLine 
                 + 'Hotel Id = ' + description[1].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'Hotel Name = ' + description[2].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'First Name = ' + description[3].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'Last Name = ' + description[4].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'Email = ' + description[5].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'Phone = ' + description[6].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'PSG Account Id = ' + description[7].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'Vendor Id = ' + description[8].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'Star rating awarded = ' + description[9].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'National rating awarded by = ' + description[10].replaceFirst('[\\w\\d]+:','') + newLine
                 + 'Date awarded = ' + fullDateAwarded;
    
    return parsedString;  
  }

  private Boolean sendAutoResponseEmail(String emailAddress) {
    return !EmailUtilities.suppressSpamEmails(emailAddress) && !EmailUtilities.suppressEmailAutoResponse(emailAddress);
  }
}