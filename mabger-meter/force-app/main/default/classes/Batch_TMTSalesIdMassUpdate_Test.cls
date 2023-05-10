@isTest
private class Batch_TMTSalesIdMassUpdate_Test
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

		insert new List<TMT__c>{
			new TMT__c(
				Sales_Credit_Number__c = '061060'
			),
			new TMT__c(
				Sales_Credit_Number__c = '061061'
			)
		};

		insert new List<Sales_Credit_ID__c>{
			new Sales_Credit_ID__c(
    			Active__c = true,
    			Region__c = 'IE',
    			Sales_Credit_Number__c = '061060',
    			User__c = UserInfo.getUserId()
    		),
			new Sales_Credit_ID__c(
    			Active__c = true,
    			Channel_Partner__c = a.Id,
    			Region__c = 'IE',
    			Sales_Credit_Number__c = '061061'
    		)
		};
    }

	@isTest
	static void syncTest()
	{
		Test.startTest();
		Id tmtSync = Database.executeBatch(new Batch_TMTSalesIdMassUpdate());
		Test.stopTest();
		
		Map<String, TMT__c> tmtMap = new Map<String, TMT__c>();
		
		for (TMT__c tmt : [SELECT Id, Sales_Credit_Number__c, Sales_Credit_Name__c FROM TMT__c])
		{
			tmtMap.put(tmt.Sales_Credit_Number__c, tmt);
		}

        System.assertEquals(true, tmtMap.containsKey('061060') && tmtMap.get('061060').Sales_Credit_Name__c == UserInfo.getName());
        System.assertEquals(true, tmtMap.containsKey('061061') && tmtMap.get('061061').Sales_Credit_Name__c == 'Gears Test Account');
	}
}