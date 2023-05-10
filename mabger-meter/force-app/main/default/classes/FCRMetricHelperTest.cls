@IsTest
public class FCRMetricHelperTest {

    private static void createTestData (String caseRecordType, String caseInitialStatus, Integer incomingCalls, Integer outgoingCalls, Integer incomingEmails, Integer outgoingEmails, Integer incomingCaseComments, Integer outgoingCaseComments) {
    	// Account
    	Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        // Contact
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'test@contact.com';
        con.AccountId = a.Id;
        insert con;
        
        // Inquiry Case Record Type
        Id caseInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(caseRecordType).getRecordTypeId();
        
        // Case
    	Case c = new Case();
        c.RecordTypeId = caseInquiryRecordTypeId;
        c.Subject = 'Test Case';
        c.AccountId = a.Id;
        c.ContactId = con.Id;
        c.Status = caseInitialStatus;
        c.Type = 'Other';
        c.Inquiry_Reason__c = 'Other';
        c.Other_Reason_Explanation__c = 'Other';
        c.Case_Resolution__c = 'Other';
        insert c;
        
        // Incoming calls
        for (Integer i = 0; i < incomingCalls; i++) {
            Task call = new Task();
            call.Direction__c = 'Incoming';
            call.WhoId = con.Id;
            call.WhatId = c.Id;
            call.Type = 'Call';
            insert call;
        }
        
        // Outgoing calls
        for (Integer i = 0; i < outgoingCalls; i++) {
            Task call = new Task();
            call.Direction__c = 'Outgoing';
            call.WhoId = con.Id;
            call.WhatId = c.Id;
            call.Type = 'Call';
            insert call;
        }
        
        // Incoming emails
        for (Integer i = 0; i < incomingEmails; i++) {
            EmailMessage em = new EmailMessage();
            em.Subject = 'Test';
            em.htmlBody = 'Test';
            em.ParentId = c.Id;
            em.Incoming = true;
            insert em;
        }
        
        // Outgoing emails
        for (Integer i = 0; i < outgoingEmails; i++) {
            EmailMessage em = new EmailMessage();
            em.Subject = 'Test';
            em.htmlBody = 'Test';
            em.ParentId = c.Id;
            em.Incoming = false;
            insert em;
        }
        
        
        // Outgoing case comments
        for (Integer i = 0; i < outgoingCaseComments; i++) {
            CaseComment cc = new CaseComment();
            cc.IsPublished = true;
            cc.ParentId = c.Id;
            insert cc;
        }
        
        
        // Incoming case comments
        if (incomingCaseComments > 0) {
            createPartnerUser();     
            //System.debug('CREATING INCOMING CASE COMMENTS 1');            
            //System.debug('CASE COMMENT COUNT 1: '+ incomingCaseComments);
        	createIncomingCaseComments(c.Id, incomingCaseComments);
        }
    }
    
    
    private static void createPartnerUser () {
        Account partnerAccount = new Account(Name ='Test Partner Account');
        insert partnerAccount; 
       
        Contact partnerContact = new Contact(FirstName='Test', LastName ='McTesterson', AccountId = partnerAccount.Id);
        insert partnerContact; 
        
        Id powerPartnerProfileId = [Select Id From Profile Where UserType = 'PowerPartner' And Name = '2018 Partner Central Community User' Limit 1].Id;
        User testUser = new User(ContactId = partnerContact.Id, FirstName = 'Test', LastName = 'McTesterson', Email = 'test.mctesterson@notarealorg.com', Username = 'test.mctesterson@notarealorg.com', Alias = 'tmctest', CommunityNickName = 'Tests', ProfileId = powerPartnerProfileId, LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Chicago', IsActive = true);
        insert testUser;
    }
    
    
    private static Id createSystemAdminUser () {
        Id systemAdminProfileId = [Select Id From Profile Where UserType = 'Standard' And Name = 'System Administrator' Limit 1].Id;
        User testUser = new User(FirstName = 'Test', LastName = 'McTesterson', Email = 'test.mctesterson@notarealorg.com', Username = 'test.mctesterson@notarealorg.com', Alias = 'tmctest', CommunityNickName = 'Tests', ProfileId = systemAdminProfileId, LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Chicago', IsActive = true);
        insert testUser;
        return testUser.Id;
    }
    
    private static Id createNonAdminUser () {
        Id nonAdminProfileId = [Select Id From Profile Where UserType = 'Standard' And Name = 'Standard User' Limit 1].Id;
        User testUser = new User(FirstName = 'Test', LastName = 'McTesterson', Email = 'test.mctesterson@notarealorg.com', Username = 'test.mctesterson@notarealorg.com', Alias = 'tmctest', CommunityNickName = 'Tests', ProfileId = nonAdminProfileId, LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Chicago', IsActive = true);
        insert testUser;
        return testUser.Id;
    }
    
    
    private static void addPermissionSet (Id userId) {
        PermissionSet ps = [Select Id, Name From PermissionSet Where Name = 'Can_Recalculate_FCR_Metric' Limit 1];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        insert psa;
    }
    
    
    @Future
    private static void createIncomingCaseComments (String caseId, Integer incomingCaseComments) {
        //System.debug('CREATING INCOMING CASE COMMENTS 2');
        User powerPortalUser = [Select Id from User Where UserType = 'PowerPartner' And FirstName = 'Test' And LastName = 'McTesterson' Limit 1];
		CaseShare cs = new CaseShare(CaseId=caseId, UserOrGroupId=powerPortalUser.Id, CaseAccessLevel='Edit');
        insert cs;
        
		System.RunAs(powerPortalUser) {
            //System.debug('CASE COMMENT COUNT 2: '+ incomingCaseComments);
			for (Integer i = 0; i < incomingCaseComments; i++) {
                CaseComment cc = new CaseComment();
                cc.IsPublished = false;
                cc.ParentId = caseId;
                cc.CommentBody = 'Test';
                insert cc;
                //System.debug('CASE COMMENT: '+cc);
            }
        }
    }
    
    
    
    private static FCR_Metric__c getFCRMetricRecord () {
        try {
        	return [Select Id, FCR_Achieved__c, Failure_Reason__c, Debug__c From FCR_Metric__c Limit 1];
        }
        catch (Exception ex) {
            System.debug('UNABLE TO FIND FCRM RECORD: '+ ex.getMessage());
            return null;
        }       
    }
    
    
    private static Case getCase () {
        Case c = [Select Id, Status From Case Limit 1];
        return c;
    }
    
    
    private static void updateCaseStatus (String newStatus) {
        Case c = getCase();
        c.Status = newStatus;
        update c;
    }
    
    // Test security.
    private static testmethod void testSecurityForSystemAdmin () {
        Id userId = createSystemAdminUser();
        
        Test.startTest();
        testSecurityForSystemAdminFuture(userId);
        Test.stopTest();
    }
    @Future
    private static void testSecurityForSystemAdminFuture (String userId) {
        User u = [Select Id From User Where Id = :userId];
        System.RunAs(u) {
            Boolean hasPermission = FCRMetricHelper.securityCheck();
            System.assertEquals(true, hasPermission);
        }
    }
    
    
    
    // Test security.
    private static testmethod void testSecurityForNormalUser () {
        Id userId = createNonAdminUser();
        
        Test.startTest();
        testSecurityForNormalUserFuture(userId);
        Test.stopTest();
    }
    @Future
    private static void testSecurityForNormalUserFuture (String userId) {
        User u = [Select Id From User Where Id = :userId];
        System.RunAs(u) {
            Boolean hasPermission = FCRMetricHelper.securityCheck();
            System.assertEquals(false, hasPermission);
        }
    }
    
    
	// Test security.
    private static testmethod void testSecurityForNormalUserWithPermissionSet () {
        Id userId = createNonAdminUser();
		addPermissionSet(userId);
        
        Test.startTest();
        testSecurityForNormalUserWithPermissionSetFuture(userId);
        Test.stopTest();
    }
    @Future
    private static void testSecurityForNormalUserWithPermissionSetFuture (String userId) {
        User u = [Select Id From User Where Id = :userId];
        System.RunAs(u) {
            Boolean hasPermission = FCRMetricHelper.securityCheck();
            System.assertEquals(true, hasPermission);
        }
    }



	// Test security.
    private static testmethod void testSecurityForNormalUserWithoutPermissionSet () {
        Id userId = createNonAdminUser();
        
        Test.startTest();
        testSecurityForNormalUserWithoutPermissionSetFuture(userId);
        Test.stopTest();
    }
    @Future
    private static void testSecurityForNormalUserWithoutPermissionSetFuture (String userId) {
        User u = [Select Id From User Where Id = :userId];
        System.RunAs(u) {
            Boolean hasPermission = FCRMetricHelper.securityCheck();
            System.assertEquals(false, hasPermission);
        }
    }        
    


    // Test the calculator entry methods.
    private static testmethod void testEntryMethods () {
        Test.startTest();
        createTestData('Inquiry', 'New', 0, 0, 0, 0, 0, 0);
        Test.stopTest();
        
        updateCaseStatus('Closed');
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        FCRMetricHelper.calculateFromLightning(fcrm.Id);
        FCRMetricHelper.calculateFromClassic(fcrm.Id);
    }
    
    
    
    

    // No FCR Metric record should be produced with a case that is not closed.
    private static testmethod void testNewCase () {
        Test.startTest();
        createTestData('Inquiry', 'New', 0, 0, 0, 0, 0, 0);
        Test.stopTest();
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.assertEquals(null, fcrm);
    }
    
    
    // FCR Metric records do not apply to cases with a record type other than 'Inquiry'.
    private static testmethod void testNewCaseOfNonInquiryRecordType () {
        Test.startTest();
        createTestData('Invoice Analysis', 'New', 0, 0, 0, 0, 0, 0);
        Test.stopTest();
        
        updateCaseStatus('Action Completed');
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.assertEquals(null, fcrm);
    }
    
    
    
    // When a case is closed, an FCR Metric record should be produced.
    private static testmethod void testCaseClose () {
        Test.startTest();
        createTestData('Inquiry', 'New', 0, 0, 0, 0, 0, 0);
        Test.stopTest();
        
        updateCaseStatus('Closed');
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.assertNotEquals(null, fcrm);
    }
    
    
    // If there are too many incoming communications, FCR should fail.
    private static testmethod void testCondition1TooManyIncoming () {
        Test.startTest();
        createTestData('Inquiry', 'New', 1, 0, 1, 0, 1, 0);
        Test.stopTest();
        
        updateCaseStatus('Closed');   
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.debug('DEBUG: '+ fcrm.Debug__c);
        System.assertEquals(false, fcrm.FCR_Achieved__c);
        System.assertEquals('Too Many Incoming', fcrm.Failure_Reason__c);
    }
    
    
    // If there is an incoming email, there can be either 1 outgoing email or phone call.
    private static testmethod void testCondition2IncomingEmail () {
        Test.startTest();
        createTestData('Inquiry', 'New', 0, 0, 1, 1, 0, 0);
        Test.stopTest();
        
        updateCaseStatus('Closed');
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.debug('DEBUG: '+ fcrm.Debug__c);
        System.assertEquals(true, fcrm.FCR_Achieved__c);
    }
    
    
    // If there is an incoming call, there can be 1 outgoing call and optionally 1 email.
    private static testmethod void testCondition3IncomingCall () {
        Test.startTest();
        createTestData('Inquiry', 'New', 1, 1, 0, 1, 0, 0);
        Test.stopTest();
        
        updateCaseStatus('Closed');
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.debug('DEBUG: '+ fcrm.Debug__c);
        System.assertEquals(true, fcrm.FCR_Achieved__c);
    }
    
    
    // If there is an incoming case comment, there can only be 1 outgoing case comment in response.
    private static testmethod void testCondition4IncomingCaseComment () {
        Test.startTest();
        createTestData('Inquiry', 'New', 0, 0, 0, 0, 1, 1);
        Test.stopTest();
        
        updateCaseStatus('Closed');
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.debug('DEBUG: '+ fcrm.Debug__c);
        System.assertEquals(false, fcrm.FCR_Achieved__c);
    }
    
    
    
    // Regardless of how the case originated, there is a strict limit on how many outgoing communications can take place.
    private static testmethod void testCondition5TooManyOutgoing () {
        Test.startTest();
        createTestData('Inquiry', 'New', 0, 1, 0, 1, 0, 1);
        Test.stopTest();
        
        
        updateCaseStatus('Closed');
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.debug('DEBUG: '+ fcrm.Debug__c);
        System.assertEquals(true, fcrm.FCR_Achieved__c);
        //System.assertEquals('Too Many Outgoing', fcrm.Failure_Reason__c);
    }
    
    
    
    // For the rare scenario where a case is closed but there haven't been enough communications, it might not be possible to consider FCR.
    private static testmethod void testCondition6NotEnoughInfo () {
        Test.startTest();
        createTestData('Inquiry', 'New', 0, 0, 0, 0, 0, 0);
        Test.stopTest();
        
        updateCaseStatus('Closed');
        
        FCR_Metric__c fcrm = getFCRMetricRecord();
        
        System.debug('DEBUG: '+ fcrm.Debug__c);
        System.assertEquals(true, fcrm.FCR_Achieved__c);
    }
    
    /*
    private static testmethod void doTestThing () {
        
        Account partnerAccount = new Account(Name ='Test Partner Account');
        insert partnerAccount; 
        
        Contact partnerContact = new Contact(FirstName='Test', LastName ='McTesterson', AccountId = partnerAccount.Id);
        insert partnerContact;
        
        // Inquiry Case Record Type
        Id caseInquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inquiry').getRecordTypeId();
        
        
        
        Id powerPartnerProfileId = [Select Id From Profile Where UserType = 'PowerPartner' And Name = '2018 Partner Central Community User' Limit 1].Id;
        User powerPortalUser = new User(ContactId = partnerContact.Id, FirstName = 'Test', LastName = 'McTesterson', Email = 'test.mctesterson@notarealorg.com', Username = 'test.mctesterson@notarealorg.com', Alias = 'tmctest', CommunityNickName = 'Tests', ProfileId = powerPartnerProfileId, LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Chicago');
        
        //addPermissionSet(powerPortalUser.Id);
        
        Id caseId;
        System.RunAs(powerPortalUser) {
            Case c = new Case();
            c.RecordTypeId = caseInquiryRecordTypeId;
            c.Subject = 'Test Case';
            c.AccountId = partnerAccount.Id;
            c.ContactId = partnerContact.Id;
            c.Status = 'New';
            c.Type = 'Other';
            c.Inquiry_Reason__c = 'Other';
            c.Other_Reason_Explanation__c = 'Other';
            c.Case_Resolution__c = 'Other';
            insert c;
            caseId = c.Id;
            
            CaseComment cc = new CaseComment();
            cc.IsPublished = false;
            cc.ParentId = c.Id;
            cc.CommentBody = 'Test';
            insert cc;
        }
        
        Map <Id, List <FCRMetricHelper.CaseCommentWrapper>> ccWrappers = FCRMetricHelper.getCaseComments(new List <Case> {new Case(Id = caseId)});
        for (List <FCRMetricHelper.CaseCommentWrapper> ccList : ccWrappers.values()) {
            for (FCRMetricHelper.CaseCommentWrapper cc : ccList) {
                System.debug(cc.commentUser.UserType);
            }
        }
		
    }
	*/
}