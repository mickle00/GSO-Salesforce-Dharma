public with sharing class SuperRegionClass {

	public static Super_Region__c FindSuperRegionByName(String superRegionName) {
		return [Select Id From Super_Region__c Where Name = : superRegionName];
	}
}