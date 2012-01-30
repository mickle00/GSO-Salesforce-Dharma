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
private class ContactTrigger_Test {

    static testMethod void myUnitTest() {
        Contact[] contacts = new Contact[]{new Contact(LastName='Last1',FirstName='First1',email='first1@expedia.com'),
        								   new Contact(LastName='Last2',FirstName='First2',email='first2@expedia.com'),
        								   new Contact(LastName='Last3',FirstName='First3',email='first3@expedia.com'),
        								   new Contact(LastName='Last4',FirstName='First4',email='first4@expedia.com'),
        								   new Contact(LastName='Last5',FirstName='First5',email='first5@expedia.com'),
        								   new Contact(LastName='Last5',FirstName='First5',email='first5@info.com.com')
        								   };
        insert contacts;
        //ContactClass objClass=new ContactClass();
        //objClass.updateAccount(contacts);
    }
}