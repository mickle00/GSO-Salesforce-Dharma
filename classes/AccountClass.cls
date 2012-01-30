public with sharing class AccountClass {

	public void BeforeInsertUpdateAccount(List<Account> accounts) {
		Region__c MEXICO = RegionClass.FindRegionByName('Mexico & Central America');
		Region__c SOUTH_AMERICA = RegionClass.FindRegionByName('South America');
		Super_Region__c SUPER_REGION = SuperRegionClass.FindSuperRegionByName('LATAM');

		for(Account newAcct : accounts) {
			if(newAcct.Region__c == SOUTH_AMERICA.Id || newAcct.Region__c == MEXICO.Id) {
				// set the super region if the region field equals South America or Mexico
				newAcct.Super_Region__c = SUPER_REGION.Id;
			}else if(newAcct.Region__c == NULL && newAcct.Super_Region__c == SUPER_REGION.Id) {
				// clear the super region field if there is no value for region
				newAcct.Super_Region__c = NULL;
			}
		}
	}
}