@isTest
private class test_UTMT {

	
	private static testmethod void testNewUpdateTMT() {
		UnitTestHelper helper = new UnitTestHelper();
		String zip = '68137';

		Market__c market = new Market__c();
		market.Name =  'Flow Direct' ;
		market.Product__c = 'Hedland';
		
		INSERT market;

		Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
		List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
		
		List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
		INSERT salesCreditIDs;

		Test.startTest();
		TMT__c tmt = helper.getTMT(zip, market.Id);
		INSERT tmt;

		TMT__c testTMT1 = [SELECT ID, User__c FROM TMT__c WHERE Id =: tmt.Id];
		System.assertEquals( testTMT1.User__c , users[1].Id);

		tmt.Sales_Credit_Number__c = '996690';
		UPDATE tmt;
		Test.stopTest();

		TMT__c testTMT0 = [SELECT ID, User__c FROM TMT__c WHERE Id =: tmt.Id];
		System.assertEquals( testTMT0.User__c , users[0].Id);
	}
	
	
	private testmethod static void testNewUpdateAccountTMTInsert() {
		UnitTestHelper helper = new UnitTestHelper();
		String zip = '68137';

		Market__c market = helper.getmarket();
		
		INSERT market;

		Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
		List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
		
		List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
		INSERT salesCreditIDs;


		TMT__c tmt = helper.getTMT(zip, market.Id);
		INSERT tmt;
		Test.startTest();
		Account acc = helper.getAccount(zip);
		
		INSERT acc;
		Test.stopTest();
		Account testAcc = [SELECT Id,TMT_Account_Owner__c,TMT_Primary_Sales_Credit__c,National_Strategic_Account__c FROM Account WHERE id =: acc.Id];
		System.assertEquals(testAcc.TMT_Primary_Sales_Credit__c, 'Utility Direct');	
	
	}
	
	private static testmethod void testAccount_RelationshipTMT() {
		UnitTestHelper helper = new UnitTestHelper();
		String zip = '68137';

		Market__c market = helper.getmarket();
		
		INSERT market;

		Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
		List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
		
		List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
		INSERT salesCreditIDs;

		TMT__c tmt = helper.getTMT(zip, market.Id);
		INSERT tmt;

		Account acc = helper.getAccount(zip);
		acc.Customer_Number__c = '12345';
		INSERT acc;

		Account_Relationship__c ar = new Account_Relationship__c();
			ar.Partner_2_Shipping_Postal_Code__c = zip;
			ar.Market__c = 'Process';
			ar.Manual_SC__c = false;
			ar.Partner_2_Sales_Cred_Num__c = salesCreditIDs[1].Sales_Credit_Number__c;
			ar.Partner_1__c = acc.Id;
			ar.Ship_To_Name__c = 'test shipp2 name';
			ar.Partner_2_Shipping_City__c = 'test city';
			ar.Partner_2_Shipping_Street__c = '1234 main st';
			ar.Partner_2_Shipping_State__c = 'AK - ALASKA';
			ar.Partner_2_Shipping_Country__c = 'UNITED STATES';
		INSERT ar;
		System.debug('AR: ' + ar);
		Test.startTest();
			tmt.Sales_Credit_Number__c = salesCreditIDs[1].Sales_Credit_Number__c;
			UPDATE tmt;
		
		Test.stopTest();

		Account testAcc = [SELECT Id,TMT_Account_Owner__c,TMT_Primary_Sales_Credit__c,National_Strategic_Account__c FROM Account WHERE id =: acc.Id];
		System.assertEquals(testAcc.TMT_Primary_Sales_Credit__c, 'Utility Direct');	
	}
}