@isTest
public class UUtil_Test 
{
    @isTest
    static void testGetBaseQueryString()
    {
        User uStand = [SELECT Id FROM User WHERE Profile.Name LIKE '%System Administrator%' AND IsActive = true LIMIT 1];

		String query = '';

		Test.startTest();
        System.runAs(uStand)
        {
            query = UUtil.getBaseQueryString('Account');
        }
        Test.stopTest();

		System.assertEquals(false, String.isBlank(query));
    }

    @isTest
    static void testReturnObj()
    {
        User uStand = [SELECT Id FROM User WHERE Profile.Name LIKE '%System Administrator%' AND IsActive = true LIMIT 1];

		UUtil.ReturnObj retObj = null;

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

        Test.startTest();
        System.runAs(uStand)
        {
			retObj = new UUtil.ReturnObj(markets, UEnum.DML.UPD);
        }
        Test.stopTest();

		System.assertEquals(markets.size(), retObj.objects.size());
		System.assertEquals(UEnum.DML.UPD, retObj.dmlType);
    }
}