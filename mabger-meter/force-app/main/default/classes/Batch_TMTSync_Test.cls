/**
	Note: this test is only to ensure the batch kicks off properly.
	All logic for Account + Account_Relationship__c objects should be tested in their own classes.
*/
@isTest
private class Batch_TMTSync_Test
{
	@TestSetup
    static void setupTestData()
    {
    	Account a = new Account(
    			Name = 'Gears Test Account',
    			BillingCity = 'Bennington',
    			BillingCountry = 'United States',
    			BillingCountryCode = 'US',
    			BillingState = 'Nebraska',
    			BillingPostalCode = '60000',
    			BillingStreet = '8229 N 150 Terrace',
    			Organization_Type__c = 'IR-Flow Industrial/Commercial Rep',
    			Market__c = 'Agriculture Irrigation',
    			Customer_Number__c = '09324042'
    		);
    	insert a;

    	insert new Account_Relationship__c(
    			Partner_1__c = a.Id,
    			Market__c = 'Agriculture Irrigation',
    			Ship_To_Name__c = 'test',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = '15000',
    			Partner_2_Sales_Cred_Num__c = '006649',
    			TMT_Search__c = 'USA-15000',
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		);
    }

	@isTest
	static void batchKickoffTest()
	{
		Id accountBatchId = Database.executeBatch(new Batch_TMTSync('ACCOUNT'));
        Id accountRelationshipBatchId = Database.executeBatch(new Batch_TMTSync('ACCOUNT_RELATIONSHIP'));

        System.assertEquals(true, accountBatchId != null);
        System.assertEquals(true, accountRelationshipBatchId != null);
	}

	@isTest
    static void testSchedule1()
    {
    	Batch_TMTSync.schedule();
		List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob];
		System.assertEquals(true, jobs != null && jobs.size() == 2);
    }

    @isTest
    static void testSchedule2()
    {
    	Batch_TMTSync.schedule(' ');
		List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob];
		System.assertEquals(true, jobs != null && jobs.size() == 2);
    }
}