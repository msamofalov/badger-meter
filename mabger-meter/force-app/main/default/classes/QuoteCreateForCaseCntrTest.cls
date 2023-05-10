@IsTest(SeeAllData=true)
public class QuoteCreateForCaseCntrTest {

    public static void createTestData () {
        Account a = new Account();
        a.Name = 'Test Account for Quote Create';
        a.Customer_Number__c = 'TEST';
        insert a;

        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Ship_To_Name__c = 'Test Account Relationship';
        ar.Partner_1__c = a.Id;
        ar.Partner_2_Shipping_Street__c = '12345 Noway Drive';
        ar.Partner_2_Shipping_Street__c = 'USA';
        ar.Partner_2_Shipping_City__c = 'Testcity';
        ar.Partner_2_Shipping_Country__c = 'UNITED STATES';
        ar.Partner_2_Shipping_Postal_Code__c = '12345';
        ar.Partner_2_Shipping_State__c = 'AA - ARMED FORCES THE AMERICAS';
        ar.Market__c = 'Energy';
        insert ar;

        Case c = new Case();
        c.AccountId = a.Id;
        c.Subject = 'Test Case for Quote Create';
        c.Account_Relationship_Ship_To__c = ar.Id;
        insert c;

        /*
        BigMachines__Configuration_Record__c cr1 = new BigMachines__Configuration_Record__c();
        cr1.BigMachines__bm_site__c = 'SITE-173';
        cr1.BigMachines__action_id_copy__c = 'test'; 
        cr1.BigMachines__action_id_open__c = 'test';
        cr1.BigMachines__document_id__c = 'test';
        cr1.BigMachines__process__c = 'test';
        cr1.BigMachines__process_id__c = 'test';
        cr1.BigMachines__version_id__c = 'test';
        cr1.Case_Specific_Process_Name__c = 'test';
        cr1.Save_Action__c = 'test';
        cr1.BigMachines__Is_Active__c = true;
        insert cr1;

        BigMachines__Configuration_Record__c cr2 = new BigMachines__Configuration_Record__c();
        cr2.BigMachines__bm_site__c = 'SITE-016';
        cr2.BigMachines__action_id_copy__c = 'test'; 
        cr2.BigMachines__action_id_open__c = 'test';
        cr2.BigMachines__document_id__c = 'test';
        cr2.BigMachines__process__c = 'test';
        cr2.BigMachines__process_id__c = 'test';
        cr2.BigMachines__version_id__c = 'test';
        cr2.Case_Specific_Process_Name__c = 'test';
        cr2.Save_Action__c = 'test';
        cr2.BigMachines__Is_Active__c = true;
        insert cr2;

        BigmachinesIntegration__c bi = new BigmachinesIntegration__c();
        bi.Name = 'Credentials';
        bi.UserName__c = 'test';
        bi.Password__c = 'test';
        bi.EndPointURL__c = 'https://notarealurl.com/testprocess';
        bi.Core_Workflow__c = 'testprocess';
        insert bi;
        */
    }


    public static testmethod void testControllerFunctions () {
        createTestData();

        PageReference testPageReference = Page.QuoteCreateForCase;
        
        // Set the page reference to the test.
        Test.setCurrentPage(testPageReference);
         
        // Get/Put a parameter for the page.
        Case testCase = [Select Id From Case Where Subject = 'Test Case for Quote Create' Limit 1];
        Account testAccount = [Select Id From Account Where Name = 'Test Account for Quote Create' Limit 1];
        testPageReference.getParameters().put('caseId', testCase.Id);
        testPageReference.getParameters().put('accId', testAccount.Id);

         
        // Initialize the page controller itself:
        QuoteCreateForCaseCntr testPageController = new QuoteCreateForCaseCntr();

        //testPageController.isOrderOrQuote = 'Quote';
        testPageController.continueOn();         
        
        //testPageController.isOrderOrQuote = 'Order';
        //testPageController.continueOn();

        //testPageController.createQuoteAnyway();

        testPageController.getExistingQuotes(testAccount.Id, 'TESTPONUMBER');

        testPageController.returnToCase();
    }


    /*
    public static testmethod void testQuoteCreationForSite173 () {
        createTestData();
        doTheTestSite173();
    }

    @Future(Callout=true)
    private static void doTheTestSite173 () {
        // Get a reference to the page controller:
        PageReference testPageReference = Page.QuoteCreateForCase;
        
        // Set the page reference to the test.
        Test.setCurrentPage(testPageReference);
         
        // Get/Put a parameter for the page.
        Case testCase = [Select Id From Case Where Subject = 'Test Case for Quote Create' Limit 1];
        Account testAccount = [Select Id From Account Where Name = 'Test Account for Quote Create' Limit 1];
        testPageReference.getParameters().put('caseId', testCase.Id);
        testPageReference.getParameters().put('accId', testAccount.Id);

         
        // Initialize the page controller itself:
        QuoteCreateForCaseCntr testPageController = new QuoteCreateForCaseCntr();

        BigMachines__Configuration_Record__c cr = [Select Id, Name From BigMachines__Configuration_Record__c Where Name = 'SITE-173'];
        testPageController.selectedSiteId = cr.Id;

        Test.setMock(HttpCalloutMock.class, new QuoteCreateForCaseCntrMock());
         
        testPageController.createQuote();
    }


    public static testmethod void testQuoteCreationForSite016 () {
        createTestData();
        doTheTestSite016();
    }

    @Future(Callout=true)
    private static void doTheTestSite016 () {
        // Get a reference to the page controller:
        PageReference testPageReference = Page.QuoteCreateForCase;
        
        // Set the page reference to the test.
        Test.setCurrentPage(testPageReference);
         
        // Get/Put a parameter for the page.
        Case testCase = [Select Id From Case Where Subject = 'Test Case for Quote Create' Limit 1];
        Account testAccount = [Select Id From Account Where Name = 'Test Account for Quote Create' Limit 1];
        testPageReference.getParameters().put('caseId', testCase.Id);
        testPageReference.getParameters().put('accId', testAccount.Id);

         
        // Initialize the page controller itself:
        QuoteCreateForCaseCntr testPageController = new QuoteCreateForCaseCntr();

        BigMachines__Configuration_Record__c cr = [Select Id, Name From BigMachines__Configuration_Record__c Where Name = 'SITE-016'];
        testPageController.selectedSiteId = cr.Id;

        Test.setMock(HttpCalloutMock.class, new QuoteCreateForCaseCntrMock());
         
        testPageController.createQuote();
    }
    */
    
}