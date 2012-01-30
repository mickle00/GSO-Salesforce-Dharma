global class EmailServicesHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
       
    system.debug('*** EmailServicesHandler => envelope.toAddress = ' + envelope.toAddress + ' ***');      
    CaseClass objCase = new CaseClass();
    
    // Lookup the record type and team based on the envelope.toAddress
    Case_Team__c caseTeam = CaseTeamClass.FindBy('Email_Service_Address__c = \'' + String.escapeSingleQuotes(envelope.toAddress) + '\'');
    
    if(caseTeam != null) {
	  // Look at To envelope.toAddress and call appropriate case, passing correct record type
	  system.debug('LANGUAGE IS: ' + caseTeam.Language__c);
      objCase.processEmail(email, caseTeam.Record_Type_Developer_Name__c, caseTeam.Team__c, caseTeam.Language__c);    	
    }else {
      // email not handled so create a
      //Support Request
      objCase.processEmail(email, 'Support_Request', null, null);
    }

    system.debug('***EmailServicesHandler => Before Return***');    
    return result;  
  }
    
/*    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
    try {
    system.debug('*** EmailServicesHandler => envelope.toAddress = ' + envelope.toAddress + ' ***');      
    CaseClass objCase = new CaseClass();
    
    // get mapping of email service addresses from custom settings
    Map<String, Email_Service_Addresses__c> mapEmailServiceAddresses = Email_Service_Addresses__c.getAll();

    // Look at To envelope.toAddress and call appropriate case, passing correct record type
    if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'ADM')) {       
      system.debug('***EmailServicesHandler => Before processEmail for ADM');
      //ADM case 
      objCase.processEmail(email, 'ADM',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'AIR_CPR')) {        
      system.debug('***EmailServicesHandler => Before processEmail for Air CPR');
      //Air CPR case 
      objCase.processEmail(email, 'Air_CPR',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'AIR_FULFILLMENT_PROCESS_SUPPORT')) {        
      system.debug('***EmailServicesHandler => Before processEmail for Air Fulfillment Process & Support');
      //Air Fulfillment Process & Support
      objCase.processEmail(email, 'Air_Fulfillment_Process_Support',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'CAR_OPS')) {        
      system.debug('***EmailServicesHandler => Before processEmail for Car OPS');
      //Car Ops case 
      objCase.processEmail(email, 'CarOps',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'COMMISSIONS')) {        
      system.debug('***EmailServicesHandler => Before processEmail for Commissions');
      //Commissions case 
      objCase.processEmail(email, 'Commissions',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'DESTINATION_SERVICES') ||
              IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'DS_MAINTENANCE')) {
      
      //Destination services case 
      system.debug('***EmailServicesHandler => Before processEmail for DS');
      objCase.processEmail(email, 'Destination_Services',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TRANSPORT_FARE')) { 
      // Transport Fare Filing case
      system.debug('***EmailServicesHandler => Before processEmail for FF'); 
      objCase.processEmail(email, 'Fare_Filing',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'GEOGRAPHY') ||
              IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'GEO_SUP')) {
      
      //Geography case 
      system.debug('***EmailServicesHandler => Before processEmail for GEO');
      objCase.processEmail(email, 'Geography',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HDM')){
      system.debug('***EmailServicesHandler => Before processEmail for HDM');
      //HDM
      objCase.processEmail(email, 'HDM',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HEALTH_SAFETY')) {
      system.debug('***EmailServicesHandler => Before processEmail for Health & Safety');
      //Health & Safety
      objCase.processEmail(email,'Health_Safety',null);   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HSTS_DCHELP') ||
             envelope.toAddress.toLowerCase().contains('codeproof.hsts_dchelp@p-whjeqqayfquejy5nxrhm03l3.m9uqhmau.m.apex.sandbox.salesforce.com')){        
      system.debug('***EmailServicesHandler => Before processEmail for HSTS dchelp');
      //HSTS dchelp
      objCase.processEmail(email, 'Hotel_Systems_Technical_Support','DC Help');
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HSTS_HOTHELP') ||
             envelope.toAddress.toLowerCase().contains('codeproof.hsts_hothelp@bdxvupxxlur1zzjc0ljxhgj5.m9uqhmau.m.apex.sandbox.salesforce.com')){        
      system.debug('***EmailServicesHandler => Before processEmail for HSTS Hothelp');
      //HSTS Hothelp
      objCase.processEmail(email, 'Hotel_Systems_Technical_Support','Hothelp');
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HSTS_NONENGLISH') ||
            envelope.toAddress.toLowerCase().contains('codeproof.hsts_nonenglish@77wkg5qimblv9qasmlqou78kx.m9uqhmau.m.apex.sandbox.salesforce.com')){        
      system.debug('***EmailServicesHandler => Before processEmail for HSTS non english');
      //HSTS non english
      objCase.processEmail(email, 'Hotel_Systems_Technical_Support','Non-English');
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HSTS_NYCTECH') ||
            envelope.toAddress.toLowerCase().contains('codeproof.hsts_nyc_tech@2-6q5bqa9cffenqmpnayqvm4swz.m9uqhmau.m.apex.sandbox.salesforce.com')){        
      system.debug('***EmailServicesHandler => Before processEmail for HSTS NYC Tech');
      //HSTS nyc tech
      objCase.processEmail(email, 'Hotel_Systems_Technical_Support','NYC Tech');
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'LODGING_CONTENT')) {
        system.debug('***EmailServicesHandler => Before processEmail for Lodging Content');
      //Lodging Content
        objCase.processEmail(email,'Lodging_Content',null);     
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'LOCALISATION')) {
        system.debug('***EmailServicesHandler => Before processEmail for Localisation');
      //Lodging Content
        objCase.processEmail(email,'Localisation',null);     
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'LODGING_CONTENT_APACONT')) {
      system.debug('***EmailServicesHandler => Before processEmail for Lodging Content - apacont');
      //Lodging Content - APACONT
      objCase.processEmail(email,'Lodging_Content','apacont');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'LODGING_CONTENT_EMEA')) {
      system.debug('***EmailServicesHandler => Before processEmail for Lodging Content - EMEA');
      //Lodging Content - EMEA
      objCase.processEmail(email,'Lodging_Content','emea');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'LODGING_CONTENT_INFOSITE')) {
      system.debug('***EmailServicesHandler => Before processEmail for Lodging Content - Infosite');
      //Lodging Content - INFOSITE
      objCase.processEmail(email,'Lodging_Content','infosite');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'Financial_Operations')) {
      //Lodging Operations - Finops Breakage
      system.debug('***EmailServicesHandler => Financial_Operations'); 
      objCase.processEmail(email, 'Financial_Operations',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'Media_Content') ||
             envelope.toAddress.toLowerCase().contains('staging.mediacontent@6uin9ht7wuyx2j81kxjo0h55b.mcsk1mac.m.apex.sandbox.salesforce.com')){        
      system.debug('***EmailServicesHandler => Before processEmail for Media Content');
      //Media Content
      objCase.processEmail(email, 'Media_Content','Media');
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'Media_Asset_Operations') ||
             envelope.toAddress.toLowerCase().contains('staging.mediaassetoperations@u-r3at5q5niuh3ad5fpw5yl1lo.mcsk1mac.m.apex.sandbox.salesforce.com')){        
      system.debug('***EmailServicesHandler => Before processEmail for Media Asset Operations');
      //Media Asset Operations
      objCase.processEmail(email, 'Media_Content','Media Asset Operations');
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TRANSPORT_QUALITY')){
      system.debug('***EmailServicesHandler => Before processEmail for Quality');
      //Transport - Quality
      objCase.processEmail(email,'Quality',null);   
    }    
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'SCHEDULE_CHANGE')) {      
      system.debug('***EmailServicesHandler => Before processEmail for Schedule Change');
      //Schedule Change case 
      objCase.processEmail(email, 'Schedule_Change',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'SETTLEMENT')) {       
      system.debug('***EmailServicesHandler => Before processEmail for Settlement');
      //Settlement case 
      objCase.processEmail(email, 'Settlement_Reporting',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'STAR_RATING')){        
      system.debug('***EmailServicesHandler => Before processEmail for Star Ratings');
      //Star Ratings
      objCase.processEmail(email, 'Star_Ratings',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'SUPPORT_REQUEST')) {
      system.debug('***EmailServicesHandler => Before processEmail for HSTS non english');
      //Support Request
      objCase.processEmail(email, 'Support_Request', null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TICKETING')) {      
      system.debug('***EmailServicesHandler => Before processEmail for Ticketing');
      //Ticketing case 
      objCase.processEmail(email, 'Ticketing',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TRANSPORT_TRAINING')){
      system.debug('***EmailServicesHandler => Before processEmail for Training');
      //Transport - Training
      objCase.processEmail(email,'Curriculum_Design_Training',null);   
    }    
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TROUBLESHOOTING') ||
             IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TROUBLESHOOTING_3PP') ||
             IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TROUBLESHOOTING_AMER') ||
             IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TROUBLESHOOTING_APAC') ||
             IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'TROUBLESHOOTING_EMEA')) {        
      system.debug('***EmailServicesHandler => Before processEmail for Transport Troubleshooting Case');
      //Troubleshooting Case
      objCase.processEmail(email, 'Troubleshooting',null);
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'USER_GENERATED_CONTENT')) {
      system.debug('***EmailServicesHandler => Before processEmail for User Generated Content');
      //User Generated Content
      objCase.processEmail(email,'User_Generated_Content',null);   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'VIRTUAL_TOURS_CONTENT')) {
      system.debug('***EmailServicesHandler => Before processEmail for Virtual Tours Content');
      //Virtual Tours Content
      objCase.processEmail(email,'Virtual_Tours_Content',null);   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HSTS_EQC')) {
      system.debug('***EmailServicesHandler => Before processEmail for HSTS EQC');
      //HSTS EQC
      objCase.processEmail(email,'Hotel_Systems_Technical_Support','EQC Help');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HSTS_VC')) {
      system.debug('***EmailServicesHandler => Before processEmail for HSTS VC');
      //HSTS VC
      objCase.processEmail(email,'Hotel_Systems_Technical_Support','VC Help');   
    }    
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'FINOPS')) {
      system.debug('***EmailServicesHandler => Before processEmail for FinOps');      
      objCase.processEmail(email,'Financial_Operations',null);   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'FINOPS_INTERNATIONAL')) {
      system.debug('***EmailServicesHandler => Before processEmail for FinOps');      
      objCase.processEmail(email,'Financial_Operations',null);   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'FINOPS_DOMESTIC')) {
      system.debug('***EmailServicesHandler => Before processEmail for FinOps');      
      objCase.processEmail(email,'Financial_Operations',null);   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'FINOPS_EXPPAY')) {
      system.debug('***EmailServicesHandler => Before processEmail for FinOps');      
      objCase.processEmail(email,'Financial_Operations','Expedia Pay');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'FINOPS_EXPPAYNU')) {
      system.debug('***EmailServicesHandler => Before processEmail for FinOps');      
      objCase.processEmail(email,'Financial_Operations','Expedia Pay');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'FINOPS_VIRTUALCARDSS')) {
      system.debug('***EmailServicesHandler => Before processEmail for FinOps');      
      objCase.processEmail(email,'Financial_Operations','Expedia Virtual Card');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'FINOPS_VENDOR_BANKING')) {
      system.debug('***EmailServicesHandler => Before processEmail for FinOps');      
      objCase.processEmail(email,'Financial_Operations', 'Vendor Banking');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'FINOPS_BREAKAGE')) {
      system.debug('***EmailServicesHandler => Before processEmail for FinOps');      
      objCase.processEmail(email,'Financial_Operations','Breakage');   
    }

    /// MPS prefaced all HPS team values with HPS 10/12/11

    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HPS')) {
      system.debug('***EmailServicesHandler => Before processEmail for HPS');      
      objCase.processEmail(email,'Lodging_Operations_HPS','HPS-General');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HPS_CLOSEOOUT')) {
      system.debug('***EmailServicesHandler => Before processEmail for HPS');      
      objCase.processEmail(email,'Lodging_Operations_HPS','HPS-DS Closeouts');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HPS_RELOMGT')) {
      system.debug('***EmailServicesHandler => Before processEmail for HPS');      
      objCase.processEmail(email,'Lodging_Operations_HPS','HPS-Relo Management');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HPS_DS')) {
      system.debug('***EmailServicesHandler => Before processEmail for HPS');      
      objCase.processEmail(email,'Lodging_Operations_HPS','HPS-Destination Services');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HPS_ELITE_PLUS')) {
      system.debug('***EmailServicesHandler => Before processEmail for HPS');      
      objCase.processEmail(email,'Lodging_Operations_HPS','HPS-Elite Plus VIP');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'HPS_STPSEL')) {
      system.debug('***EmailServicesHandler => Before processEmail for HPS');      
      objCase.processEmail(email,'Lodging_Operations_HPS','HPS-DS Stopsell');   
    }
    else if (IsCaseType(mapEmailServiceAddresses, envelope.toAddress, 'SCORE')) {
      system.debug('***EmailServicesHandler => Before processEmail for HPS');      
      objCase.processEmail(email,'Score',null);   
    }
    
    else { 
        // email not handled so create a
      //Support Request
      objCase.processEmail(email, 'Support_Request', null);
    }
    system.debug('***EmailServicesHandler => Before Return***');    

    }catch (Exception ex) {
        system.debug('***EmailServicesHandler => Exception***');
        ExceptionClass objException = new ExceptionClass();
        objException.InsertException(email, ex);
    }

    return result;  
  }

  /////// Private Methods
  private Boolean IsCaseType(Map<String, Email_Service_Addresses__c> mapEmailServiceAddresses, String toAddress, String customSetting) {
    //locate the custom setting for the case type
    Email_Service_Addresses__c emailServiceAddress = mapEmailServiceAddresses.get(customSetting);

    //if a custom setting is found determine if the enevelop.toAddress matches the email address of the custom setting
    return (emailServiceAddress != null ? toAddress.toLowerCase().contains(emailServiceAddress.Email_Address__c) : false);
  }
*/
}