@isTest 
public class test_UAccount
{

	private static final String ZIP1 = '68137';
	private static final String ZIP2 = '68138';
	private static final Id PROFID = [SELECT Id, Name FROM Profile WHERE Name = '2017 Sales User' LIMIT 1].Id;
	private static final List<User> USERS = [SELECT Id, Name FROM User WHERE ProfileId = : PROFID AND IsActive = true Limit 5];
	private static final Id ACCOUNTRECORDTYPEID = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Direct_End_Customer'].Id;

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

		List<Sales_Credit_ID__c> salesCreditIds = new List<Sales_Credit_ID__c>{
			new Sales_Credit_ID__c(
				Active__c = true,
				Name = 'Unit Test 1',
				Sales_Credit_Number__c = '996691',
				User__c = USERS[0].Id
			),
			new Sales_Credit_ID__c(
				Active__c = true,
				Name = 'Unit Test 2',
				Sales_Credit_Number__c = '996692',
				User__c = USERS[1].Id
			)
		};

		insert salesCreditIds;

		List<TMT__c> tmts = new List<TMT__c>{
			new TMT__c(
				Zip_Postal_Code__c = ZIP1,
				Market__c = markets[0].Id,
				Country__c =  'USA',
				Sales_Credit_Number__c = '996691'
			),
			new TMT__c(
				Zip_Postal_Code__c = ZIP2,
				Market__c = markets[0].Id,
				Country__c =  'USA',
				Sales_Credit_Number__c = '996692'
			),
			new TMT__c(
				Zip_Postal_Code__c = ZIP1,
				Market__c = markets[2].Id,
				Country__c =  'USA',
				Sales_Credit_Number__c = '996691'
			),
			new TMT__c(
				Zip_Postal_Code__c = ZIP2,
				Market__c = markets[3].Id,
				Country__c =  'USA',
				Sales_Credit_Number__c = '996692'
			)
		};

		insert tmts;
    }
	
	static testMethod void testAccountInsert()
	{
		Test.startTest();

		List<Account> accounts = new List<Account>{
			new Account(
				RecordTypeId = ACCOUNTRECORDTYPEID,
				Name = 'Unit Test Account',
				Organization_Type__c = 'UC-Utility Customer',
				Active__c = true,
				BillingPostalCode = ZIP1,
				BillingCountry = 'UNITED STATES',
				BillingCountryCode = 'US',
				National_Strategic_Account__c = false,
				Market__c = 'Turf Irrigation'
			),
			new Account(
				RecordTypeId = ACCOUNTRECORDTYPEID,
				Name = 'Unit Test Account',
				Organization_Type__c = 'UD-Utility Distributor',
				Active__c = true,
				BillingPostalCode = ZIP1,
				BillingCountry = 'UNITED STATES',
				BillingCountryCode = 'US',
				National_Strategic_Account__c = false,
				Market__c = 'Turf Irrigation'
			),
			new Account(
				RecordTypeId = ACCOUNTRECORDTYPEID,
				Name = 'Unit Test Account',
				Organization_Type__c = 'IR-Flow Industrial/Commercial Rep',
				Active__c = true,
				BillingPostalCode = ZIP1,
				BillingCountry = 'UNITED STATES',
				BillingCountryCode = 'US',
				National_Strategic_Account__c = false,
				Market__c = 'Turf Irrigation'
			)
		};

		insert accounts;

		Test.stopTest();
		
		Account a1 = [SELECT Id, OwnerId, BillingPostalCode, National_Strategic_Account__c, TMT_Account_Owner__c FROM Account WHERE Id = : accounts[0].Id];
		System.assertEquals(a1.OwnerId, USERS[0].Id);
	}

	static testMethod void testAccountUpdate1()
	{		
		Account acc = new Account(
			RecordTypeId = ACCOUNTRECORDTYPEID,
			Name = 'Unit Test Account',
			Organization_Type__c = 'DC-Distributor Customer',
			Active__c = true,
			BillingPostalCode = ZIP1,
			BillingCountry = 'UNITED STATES',
			BillingCountryCode = 'US',
			National_Strategic_Account__c = false,
			Market__c = 'Turf Irrigation'
		);

		insert acc;

		Product2 p = new Product2();
		p.Name = '68886-101';
		p.Description = 'Test';
        insert p;
		
		Test.startTest();

		// Tests BEACON code in the Account Trigger
        insert new Beacon_Service_Pricing__c(
            Account_ID__c = acc.Id,
            Bill_To_Number__c = '09324041',
			Ship_To_Number__c = '0001',
			Increment__c = 1,
			Item_Number__c = p.Id,
			Price__c = 1.00
        );        
        
		acc.BillingPostalCode = ZIP2;
        acc.Default_Ship_To__c = '0002'; // Tests BEACON code in the Account Trigger
		update acc;

		Test.stopTest();

		Account a2 = [SELECT Id, OwnerId, BillingPostalCode, National_Strategic_Account__c, TMT_Account_Owner__c FROM Account WHERE Id = : acc.Id];		
		//System.assertEquals(a2.OwnerId, USERS[1].Id);
	}

	static testMethod void testAccountUpdate2()
	{		
		Account acc = new Account(
			RecordTypeId = ACCOUNTRECORDTYPEID,
			Name = 'Unit Test Account',
			Organization_Type__c = 'WM-Wyco OEM',
			Active__c = true,
			BillingPostalCode = ZIP1,
			BillingCountry = 'UNITED STATES',
			BillingCountryCode = 'US',
			National_Strategic_Account__c = false,
			Market__c = 'Turf Irrigation'
		);

		insert acc;
		
		Test.startTest();

		acc.BillingPostalCode = ZIP2;
		acc.Organization_Type__c = 'FE-Flow End Customer';
		update acc;

		Test.stopTest();

		Account a2 = [SELECT Id, OwnerId, BillingPostalCode, National_Strategic_Account__c, TMT_Account_Owner__c FROM Account WHERE Id = : acc.Id];		
		System.assertEquals(a2.OwnerId, USERS[1].Id);
	}
	
	static testMethod void testAccountInsertPSC()
	{
		Account acc = new Account(
			RecordTypeId = ACCOUNTRECORDTYPEID,
			Name = 'Unit Test Account',
			Organization_Type__c = 'UC-Utility Customer',
			Active__c = true,
			BillingPostalCode = ZIP1,
			BillingCountry = 'UNITED STATES',
			BillingCountryCode = 'US',
			National_Strategic_Account__c = false
		);

		insert acc;

		Test.startTest();

		acc.BillingPostalCode = ZIP2;
		update acc;

		Test.stopTest();

		Account a2 = [SELECT Id, OwnerId, BillingPostalCode , National_Strategic_Account__c, Primary_Sales_Credit_Number__c, TMT_Account_Owner__c FROM Account WHERE Id = : acc.Id];	
		//System.assertEquals(a2.Primary_Sales_Credit_Number__c, '996692');
	}
	
	static testMethod void testContactProductUpdate()
    {
		Account acc = new Account(
			RecordTypeId = ACCOUNTRECORDTYPEID,
			Name = 'Unit Test Account',
			Organization_Type__c = 'UC-Utility Customer',
			Active__c = true,
			BillingPostalCode = ZIP1,
			BillingCountry = 'UNITED STATES',
			BillingCountryCode = 'US',
			National_Strategic_Account__c = false,
			Market__c = 'Turf Irrigation',
			Products__c = 'test product ; test product2; test product 3',
			Type = 'End User - 1'
		);

		insert acc;
        
        List<Contact> contacts = new List<Contact>{
			new Contact(
				LastName= 'TestCon1',
				AccountId = acc.Id,
				Inactive__c = false
			),
			new Contact(
				LastName= 'TestCon2',
				AccountId = acc.Id,
				Inactive__c = false,
				Products_for_Extranet__c = ''
			)
		};

		insert contacts;
        
		Test.startTest();
		
        acc.Active__c = true;
        acc.Products__c = 'test product ; test product2; test product 4';
        
        update acc;

		Test.stopTest();
	}

}