@isTest
private class test_USalesCreditID {

	@isTest
	private static void testInsertSCID() {
		String zip1 = '68137';
		Market__c market1 = new Market__c();
			market1.Name =  'Utility Direct' ;
			market1.Product__c = 'Hedland';
		INSERT market1;
        
		Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
		List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
		
		Sales_Credit_ID__c scid = new Sales_Credit_ID__c();
		scid.Name = 'test Scid';
		scid.Sales_Credit_Number__c = '008969';
		scid.User__c = users[0].id;
		scid.Active__c = true;
		
		INSERT scid;
	
    	TMT__c tmt1 = new TMT__c();
			tmt1.Zip_Postal_Code__c = zip1;
			tmt1.Country__c = 'USA';
			tmt1.Market__c = market1.Id ;
			tmt1.Sales_Credit_Number__c = '008969';
		INSERT tmt1;    
		
		
		Test.startTest();        
        scid.User__c = users[1].id;
		update scid;
		Test.stopTest();

		TMT__c t1 = [SELECT id, User__c  FROM TMT__C WHERE Id =: tmt1.Id limit 1] ;
		System.assertEquals(t1.User__c, users[1].id);

	}
}