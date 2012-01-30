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
private class CasePointOfSaleClass_Test {

    static testMethod void testPointOfSaleClass() {
        CasePointOfSaleClass objPOS = new CasePointOfSaleClass();
    
        List <Case> testCases = new List<Case>();
        Case myCase = new Case(Subject = 'TestCase', Status = 'New', Points_of_Sale__c = '12-Expedia Mexico;66-Expedia Norway');
        testCases.add(myCase);
        insert testCases;
        objPOS.insertCasePointsOfSaleForNewCases(testCases);    

        Map<Id, Case> cMapOld = new Map<Id, Case>();
        Map<Id, Case> cMapNew = new Map<Id, Case>();
        for (Case c : testCases){
            cMapOld.put(c.Id, c);
        }
        Case caseToUpdate = [SELECT Id, Points_of_Sale__c FROM Case WHERE Id = :myCase.Id];
        caseToUpdate.Points_of_Sale__c = '30028-WWTE Sam\'s Club';
    
        cMapNew.put(caseToUpdate.Id, caseToUpdate);
        
        //simulate changes
        objPOS.syncCasePointsOfSale(cMapOld, cMapNew);
        
        //simulate no changes
        objPOS.syncCasePointsOfSale(cMapOld, cMapOld);
    }
}