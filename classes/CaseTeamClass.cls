public with sharing class CaseTeamClass {

	public static Case_Team__c FindBy(String condition) {
		// dynamically build query
		String objectName = Case_Team__c.sObjectType.getDescribe().getName();
		List<SObject> listObjects = SoqlBuilder.ExecuteSelectQuery(objectName, condition);
		
		return (Case_Team__c)listObjects.get(0);
	}
}