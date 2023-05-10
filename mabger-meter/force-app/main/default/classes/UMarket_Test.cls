@isTest
private class UMarket_Test {

	@isTest
	private static void ChangeMarkctProduct() {
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

		TMT__c tmt = helper.getTMT(zip, market.Id);
		
		INSERT tmt;

		System.Test.startTest();
			market.Product__c = 'Hedland;Cox;';
			UPDATE market;
		System.Test.stopTest();

	//	TMT__c aTMT = [SELECT id,ProductText__c FROM TMT__c where id =: tmt.Id];
	//	System.assertEquals('Cox;Hedland', aTMT.ProductText__c);



	}
}