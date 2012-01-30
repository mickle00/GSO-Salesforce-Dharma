public with sharing class RegionClass {
	
	public static Region__c FindRegionByName(String regionName) {
		return [Select Id From Region__c Where Name = : regionName];
	}
}