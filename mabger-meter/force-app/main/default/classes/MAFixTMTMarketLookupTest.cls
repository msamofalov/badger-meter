@isTest
private class MAFixTMTMarketLookupTest 
{
	private static testMethod void test() 
	{
        UnitTestHelper helper = new UnitTestHelper();
        
        Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        
        List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        INSERT salesCreditIDs;
        
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;

        Market__c tMrkt2 = new Market__c();
        tMrkt2.Name = 'Utility Direct';
        tMrkt2.Product__c = 'BEACON; Cox; E-Series; High Resolution Encoders; ModMAG M-Series; ORION; Recordall';
        tMrkt2.Sandbox_ID__c = '1234';
        insert tMrkt2;

        list<TMT__c> testTMTS = new list<TMT__c>();
        for (integer i=0; i < 50; i++) {
            TMT__c t = new tmt__c();
            t.Market__c = tMrkt2.id;
            t.Sales_Credit_Number__c = salesCreditIDs[0].Sales_Credit_Number__c;
            t.Zip_Postal_Code__c = '28105';
            t.MATest__c = true;
            t.country__c = 'USA';
            t.country2__c = 'USA';
            t.Market_Sandbox_ID__c = '1234';
            testTMTS.add(t);
        }

        insert testTMTs;
        
        test.startTest();
        
        Database.executeBatch(new MAFixTMTMarketLookup(), 200);
        
        test.stopTest();        
	}
}