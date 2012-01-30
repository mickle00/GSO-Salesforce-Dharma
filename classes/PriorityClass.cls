public with sharing class PriorityClass {
	
	public Map<Id,PriorityClass.Priority> getPriority(List<Case> myCases){
		// query to get related objects
		myCases = [SELECT Id
						 ,Priority
						 ,Type
						 ,Team__c
						 ,Contact.Case_Priority__c
						 ,Account.Rating 
					FROM Case 
				   WHERE Id IN:myCases];
				   
				   
	   // Map<TeamName, Map<CaseType, Priority>>
					   
	   Map<Id,PriorityClass.Priority> casePriorityMap = new Map<Id,PriorityClass.Priority>();
	   
	   for (Case myCase : myCases){
	   		PriorityClass.Priority myPriority = new PriorityClass.Priority();
	   		myPriority.casePriority = myCase.Priority;
	   		myPriority.contactPriority = myCase.Contact.Case_Priority__c;
	   		myPriority.accountPriority = myCase.Account.Rating;	 
	   		casePriorityMap.put(myCase.Id, myPriority);  	
	   }
	   
	   return casePriorityMap;
	}
	
	public Map<Id,PriorityClass.Priority> getPriority(Case myCase){
		List<Case> myCases = new List<Case>{myCase};
		return this.getPriority(myCases);
	}
	
	public class Priority{
		// List<Schema.PicklistEntry> casePriorityValues = Case.Priority.getDescribe().getPicklistValues();
		public string casePriority;
		public string contactPriority;
		public string accountPriority;
		
		public String getHighestPriority(){
			String highestPriority = '';
			return highestPriority;
		}
		/**		
		public Priority(){
							
		}
		**/			
	}
}