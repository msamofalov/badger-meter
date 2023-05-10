@IsTest
public class QuoteCreateForCaseValidTest {

    @TestSetup
    public static void createTestData () {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Case testCase = new Case();
        testCase.AccountId = testAccount.Id;
        testCase.Subject = 'Test Case';
        insert testCase;
    }


    public static testmethod void testController () {
        // Get a reference to the page controller:
        PageReference testPageReference = Page.QuoteCreateForCaseValidation;
        
        // Set the page reference to the test.
        Test.setCurrentPage(testPageReference);
        
        // Get/Put a parameter for the page.
        Case testCase = [Select Id From Case Limit 1];
        testPageReference.getParameters().put('caseId', testCase.Id);
        
        // Initialize the page controller itself:
        QuoteCreateForCaseValidationController testPageController = new QuoteCreateForCaseValidationController();

        testPageController.cancel();
        testPageController.ok();
        
        QuoteCreateForCaseValidationController.validateCanCreateNewQuoteFromCase(testCase.Id);
        
        
    }    
    
    public static testmethod void testNoPO () {
        // Get a reference to the page controller:
        PageReference testPageReference = Page.QuoteCreateForCaseValidation;
        
        // Set the page reference to the test.
        Test.setCurrentPage(testPageReference);
        
        // Get/Put a parameter for the page.
        Case testCase = [Select Id From Case Limit 1];
        testPageReference.getParameters().put('caseId', testCase.Id);
        
        // Initialize the page controller itself:
        QuoteCreateForCaseValidationController testPageController = new QuoteCreateForCaseValidationController();
        
        QuoteCreateForCaseValidationController.validateCanCreateNewQuoteFromCase(testCase.Id);
    }  
    
    
    public static testmethod void testWithPO () {
        // Get a reference to the page controller:
        PageReference testPageReference = Page.QuoteCreateForCaseValidation;
        
        // Set the page reference to the test.
        Test.setCurrentPage(testPageReference);
        
        // Get/Put a parameter for the page.
        Case testCase = [Select Id, PO_Number__c From Case Limit 1];
        testCase.PO_Number__c = '1234';
        update testCase;
        
        testPageReference.getParameters().put('caseId', testCase.Id);
        
        // Initialize the page controller itself:
        QuoteCreateForCaseValidationController testPageController = new QuoteCreateForCaseValidationController();
        
        QuoteCreateForCaseValidationController.validateCanCreateNewQuoteFromCase(testCase.Id);
    }  
}