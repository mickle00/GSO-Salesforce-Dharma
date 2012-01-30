trigger OutOfOfficeNoticeTrigger on Out_of_Office_Notice__c (after update) {
	
	OutOfOfficeNoticeClass objOOFNotice = new OutOfOfficeNoticeClass(); 
  objOOfNotice.setStatus(trigger.new);
}