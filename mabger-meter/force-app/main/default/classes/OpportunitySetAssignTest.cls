@IsTest
public class OpportunitySetAssignTest {

    public static testmethod void test () {        
        List <Opportunity> opps = new List <Opportunity> ([Select Id, OwnerId From Opportunity Limit 1]);
        
        // Get a reference to the page controller:
        PageReference testPageReference = Page.OpportunitySetAssignPage;
        
        // Set the page reference to the test.
        Test.setCurrentPage(testPageReference);
        
        ApexPages.StandardSetController testStandardSetController = new ApexPages.StandardSetController(opps);
        
        // Initialize the page controller itself:
        OpportunitySetAssign testPageController = new OpportunitySetAssign(testStandardSetController);
        testPageController.Opps = opps;
        
        testPageController.UpdateOwnership();
    } 
    
}