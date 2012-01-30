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
private class EmailServicesHandler_Test {

    static testMethod void myUnitTest() {
        EmailServicesHandler objEmail = new EmailServicesHandler();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        
        String[] toAddresses = new String[]{'dsmaint@expedia.com'};
        email.toAddresses = toAddresses;
        email.fromAddress = 'yuk@yucky.com';
        email.plainTextBody = 'This is a test, only a test';
        email.htmlBody = email.plainTextBody;
        email.subject = 'This is a test';
        
        Messaging.InboundEmail.Binaryattachment emailAttachment = new Messaging.InboundEmail.Binaryattachment();
        emailAttachment.Body = Blob.valueOf('Some Text');
        emailAttachment.mimeTypeSubType = 'application/pdf';
        emailAttachment.fileName = 'Test File.pdf';
        
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { emailAttachment };
        
        Messaging.InboundEmail.Textattachment emailTextAttachment = new Messaging.InboundEmail.Textattachment();
        emailTextAttachment.Body = 'Some Text';
        emailTextAttachment.mimeTypeSubType = 'text/plain';
        emailTextAttachment.fileName = 'Test File.txt';
        
        email.Textattachments = new Messaging.inboundEmail.Textattachment[] { emailTextAttachment };
        
        envelope.toAddress = 'dsmaint@expedia.com';
        envelope.fromAddress = 'yuk@yucky.com';
        
        
        result = objEmail.handleInboundEmail(email, envelope);
        
        email.subject = email.subject + 'ref: 0000000:989809 :ref';
        result = objEmail.handleInboundEmail(email, envelope);
    }
}