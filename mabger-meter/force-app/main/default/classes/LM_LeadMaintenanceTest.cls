@IsTest
public class LM_LeadMaintenanceTest {
	/*	LM - Lead Maintenance
     * 	
     * 	Module:	Lead Maintenance Test
     * 
     * 	Author:	Joseph Bunda, Allium - 2020-03-01
     * 
     * 	Tests for Lead Maintenance.	
     * 
     */
    
    
    private static final Integer TEST_LEAD_VOLUME = 10;
    
    
    @TestSetup
    public static void createTestData () {
        Apex_Job_Administrator__c testJobAdministrator = new Apex_Job_Administrator__c();
        testJobAdministrator.Name__c 	= 'Test McTesterson';
        testJobAdministrator.Email__c 	= 'test@test.com';
        insert testJobAdministrator;
        
        List <Lead> testLeads = new List <Lead> ();
        for (Integer i = 0; i < TEST_LEAD_VOLUME; i++) {
            Lead testLead = new Lead();
            testLead.FirstName = 'Test'+ i;
            testLead.LastName = 'McTesterson';
            testLead.Email = 'test'+ i +'@test.com';
            testLead.Company = 'Testers R Us';
            testLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('International Lead').getRecordTypeId();
            testLead.Status = 'New';
            testLead.Lifecycle_Status__c = '';
            testLead.Pardot_Consent_Last_Updated__c = Date.today().addDays(-40);
            testLeads.Add(testLead);
        }
        insert testLeads;
    }
    
    
    public static testmethod void testNurtureOldLeads () {
        /*	Tests to ensure that a lead that fits the criteria has it's status changed appropriately.
         */
        
        // Run the test.
        Test.startTest();{
            LM_LeadMaintenance.nurtureOldLeads();
        }Test.stopTest();
        
        // Ensure that all test leads were updated to the correct status.
        List <Lead> testLeads = new List <Lead> ([Select Id, Status, Lifecycle_Status__c From Lead]);
        for (Lead l : testLeads) {
            System.assertEquals('Needs More Nurturing', l.Status);
            System.assertEquals('10 - Expired', l.Lifecycle_Status__c);
        }
    }
    
    
    
    public static testmethod void testCompileDatabaseResultsToCSV () {
        /*	Tests to ensure that results from the database operation are compiled to a CSV correctly.
         */
        
        // Get all of the test leads.
        List <Lead> testLeads = new List <Lead> ([Select Id, Company From Lead]);
        
        // Measure half of the testing volume.
        Integer halfOfTestLeadVolume = TEST_LEAD_VOLUME / 2;
        
        // The first half of the test leads will lose the value of the Company field. This should generate errors on that part of the set.
        for (Integer i = 0; i < halfOfTestLeadVolume; i++) testLeads[i].Company = null;
        
        // Update all test leads and save the results.
        List <Database.SaveResult> updateResults = Database.update(testLeads, false);
        
        // This stores the CSV that will be compiled from the update results.
        String resultCSV = '';
        
        // Run the test.
        Test.startTest();{
            resultCSV = LM_LeadMaintenance.compileDatabaseResultsToCSV(updateResults);
        }Test.stopTest();
        
        System.debug(resultCSV);
        
        // There should be 11 total lines in the CSV that is compiled - 1 header and 10 rows.
       	System.assertEquals(11, resultCSV.countMatches('\n'));
        
        // Five rows should have errors out on update, so there should be 5 occurances of the word "Error:" in the CSV.
        System.assertEquals(5, resultCSV.countMatches('Error:'));
    }
    
    
    
    public static testmethod void testEmailResultsToAdministrators () {
        /*	Tests that an email can be sent.
         */
        
        // Run the test.
        Test.startTest();{
            LM_LeadMaintenance.emailResultsToAdministrators('Results of Fake Job', 'Id,Result');
            
            // There should have been 1 email sent.
        	System.assertEquals(1, Limits.getEmailInvocations());
        }Test.stopTest();
    }
    
    
    
    public static testmethod void testScheduledJob () {
        /*	Ensures that the scheduled job runs as expected.
         */ 
        
        Test.startTest();{
            Datetime dt = Datetime.now().addMinutes(1);
            String chron = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            String jobId = System.schedule('Test Lead Maintenance Job', chron, new LM_LeadMaintenanceSchedulable());   
        }Test.stopTest();
        
        // Ensure that all test leads were updated to the correct status.
        List <Lead> testLeads = new List <Lead> ([Select Id, Status, Lifecycle_Status__c From Lead]);
        for (Lead l : testLeads) {
            System.assertEquals('Needs More Nurturing', l.Status);
            System.assertEquals('10 - Expired', l.Lifecycle_Status__c);
        }
    }
}