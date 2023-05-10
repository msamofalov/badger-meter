@isTest
public class UQueueable_Test 
{
	@TestSetup
    static void setupTestData()
    {
        List<Market__c> markets = new List<Market__c>{
			new Market__c(
				Name = 'Utility Direct',
				Product__c = 'Hedland'
			),
			new Market__c(
				Name = 'Process',
				Product__c = 'Hedland'
			),
			new Market__c(
				Name = 'Water Distribution',
				Product__c = 'Hedland'
			),
			new Market__c(
				Name = 'Flow Direct',
				Product__c = 'Hedland'
			)
		};

		insert markets;
    }

    @isTest
    static void testListInsert()
    {
        User uStand = [SELECT Id FROM User WHERE Profile.Name LIKE '%System Administrator%' AND IsActive = true LIMIT 1];

        Test.startTest();

        List<Market__c> markets = new List<Market__c>{
			new Market__c(
				Name = 'Utility Direct',
				Product__c = 'Hedland'
			),
			new Market__c(
				Name = 'Process',
				Product__c = 'Hedland'
			),
			new Market__c(
				Name = 'Water Distribution',
				Product__c = 'Hedland'
			),
			new Market__c(
				Name = 'Flow Direct',
				Product__c = 'Hedland'
			)
		};

        System.runAs(uStand)
        {
            System.enqueueJob(new UQueueable(new List<UUtil.ReturnObj>{new UUtil.ReturnObj(markets, UEnum.DML.INS)}));
        }
        Test.stopTest();
    }

    @isTest
    static void testListUpdate()
    {
        User uStand = [SELECT Id FROM User WHERE Profile.Name LIKE '%System Administrator%' AND IsActive = true LIMIT 1];

		List<Market__c> markets = [SELECT Id FROM Market__c];

        Test.startTest();
        System.runAs(uStand)
        {
            System.enqueueJob(new UQueueable(new List<UUtil.ReturnObj>{new UUtil.ReturnObj(markets, UEnum.DML.UPD)}));
        }
        Test.stopTest();
    }

    @isTest
    static void testListDelete()
    {
        User uStand = [SELECT Id FROM User WHERE Profile.Name LIKE '%System Administrator%' AND IsActive = true LIMIT 1];

		List<Market__c> markets = [SELECT Id FROM Market__c];

        Test.startTest();
        System.runAs(uStand)
        {
            System.enqueueJob(new UQueueable(new List<UUtil.ReturnObj>{new UUtil.ReturnObj(markets, UEnum.DML.DEL)}));
        }
        Test.stopTest();
    }
}