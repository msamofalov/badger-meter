@isTest
private class test_UAccountRelationship
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
				Name = 'Water Distribution',
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
				Name = 'Oil & Gas',
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
				Sales_Credit_Number__c = '996691',
                Market_Text__c = '1'
			),
			new TMT__c(
				Zip_Postal_Code__c = ZIP2,
				Market__c = markets[0].Id,
				Country__c =  'USA',
				Sales_Credit_Number__c = '996692',
                Market_Text__c = '2'
			),
			new TMT__c(
				Zip_Postal_Code__c = ZIP1,
				Market__c = markets[2].Id,
				Country__c =  'USA',
				Sales_Credit_Number__c = '996691',
                Market_Text__c = '3'
			),
			new TMT__c(
				Zip_Postal_Code__c = ZIP2,
				Market__c = markets[3].Id,
				Country__c =  'USA',
				Sales_Credit_Number__c = '996692',
                Market_Text__c = '4'
			)
		};

		insert tmts;

		List<Account> accounts = new List<Account>{
			new Account(
				RecordTypeId = ACCOUNTRECORDTYPEID,
				Name = 'Unit Test Account 1',
				Organization_Type__c = 'UC-Utility Customer',
				Active__c = true,
				BillingPostalCode = ZIP1,
				BillingCountry = 'UNITED STATES',
				BillingCountryCode = 'US',
				National_Strategic_Account__c = false,
				Market__c = 'Agriculture Irrigation',
				Customer_Number__c = '09324041',
                Company_Number__c = '10 - BADGER METER, INC. (US)',
                Default_Ship_To__c = '0001'
			),
			new Account(
				RecordTypeId = ACCOUNTRECORDTYPEID,
				Name = 'Unit Test Account 2',
				Organization_Type__c = 'DC-Distributor Customer',
				Active__c = true,
				BillingPostalCode = ZIP1,
				BillingCountry = 'UNITED STATES',
				BillingCountryCode = 'US',
				National_Strategic_Account__c = false,
				Market__c = 'Agriculture Irrigation',
				Customer_Number__c = '09324042',
                Company_Number__c = '10 - BADGER METER, INC. (US)',
                Default_Ship_To__c = '0001'
			),
			new Account(
				RecordTypeId = ACCOUNTRECORDTYPEID,
				Name = 'Unit Test Account 3',
				Organization_Type__c = 'UD-Utility Distributor',
				Active__c = true,
				BillingPostalCode = ZIP1,
				BillingCountry = 'UNITED STATES',
				BillingCountryCode = 'US',
				National_Strategic_Account__c = false,
				Market__c = 'Agriculture Irrigation',
				Customer_Number__c = '09324043',
                Company_Number__c = '10 - BADGER METER, INC. (US)',
                Default_Ship_To__c = '0001'
			),
			new Account(
				RecordTypeId = ACCOUNTRECORDTYPEID,
				Name = 'Unit Test Account 4',
				Organization_Type__c = 'IR-Flow Industrial/Commercial Rep',
				Active__c = true,
				BillingPostalCode = ZIP1,
				BillingCountry = 'UNITED STATES',
				BillingCountryCode = 'US',
				National_Strategic_Account__c = false,
				Market__c = 'Agriculture Irrigation',
				Customer_Number__c = '09324044',
                Company_Number__c = '10 - BADGER METER, INC. (US)',
                Default_Ship_To__c = '0001'
			)
		};

		insert accounts;

		List <Account_Relationship__c> arList = new List <Account_Relationship__c> ();
		
        arList.add(new Account_Relationship__c(
    			Partner_1__c = accounts[0].Id,
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
    		)
        );
		
        insert arList;
    }

	@isTest
	static void testAccountRelationshipInsert()
	{
		Map<String, Account> accountMap = new Map<String, Account>();

		for (Account a : [SELECT Id, Organization_Type__c FROM Account])
		{
			accountMap.put(a.Organization_Type__c, a);
		}
		
		Test.startTest();

		List<Account_Relationship__c> accountRelationships = new List<Account_Relationship__c>{
			new Account_Relationship__c(
    			Partner_1__c = accountMap.get('UC-Utility Customer').Id,
    			Market__c = 'Agriculture Irrigation',
    			Ship_To_Name__c = 'test',
                Ship_To_Number__c = '0001',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = ZIP1,
    			Partner_2_Sales_Cred_Num__c = '996691',
    			TMT_Search__c = 'USA-' + ZIP1,
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		),
			new Account_Relationship__c(
    			Partner_1__c = accountMap.get('DC-Distributor Customer').Id,
    			Market__c = 'Water Distribution',
    			Ship_To_Name__c = 'test',
                Ship_To_Number__c = '0001',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = ZIP1,
    			Partner_2_Sales_Cred_Num__c = '996691',
    			TMT_Search__c = 'USA-' + ZIP1,
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		),
			new Account_Relationship__c(
    			Partner_1__c = accountMap.get('UD-Utility Distributor').Id,
    			Market__c = 'Oil & Gas',
    			Ship_To_Name__c = 'test',
                Ship_To_Number__c = '0001',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = ZIP1,
    			Partner_2_Sales_Cred_Num__c = '996691',
    			TMT_Search__c = 'USA-' + ZIP1,
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		),
			new Account_Relationship__c(
    			Partner_1__c = accountMap.get('IR-Flow Industrial/Commercial Rep').Id,
    			Market__c = 'Water Distribution',
    			Ship_To_Name__c = 'test',
                Ship_To_Number__c = '0001',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = ZIP1,
    			Partner_2_Sales_Cred_Num__c = '996691',
    			TMT_Search__c = 'USA-' + ZIP1,
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		)
		};

		insert accountRelationships;

		Test.stopTest();
	}

	@isTest
	static void testAccountRelationshipUpdate()
	{
		Map<String, Account> accountMap = new Map<String, Account>();

		for (Account a : [SELECT Id, Organization_Type__c FROM Account])
		{
			accountMap.put(a.Organization_Type__c, a);
		}

		List<Account_Relationship__c> accountRelationships = new List<Account_Relationship__c>{
			new Account_Relationship__c(
    			Partner_1__c = accountMap.get('UC-Utility Customer').Id,
    			Market__c = 'Agriculture Irrigation',
    			Ship_To_Name__c = 'test',
                Ship_To_Number__c = '0001',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = ZIP1,
    			Partner_2_Sales_Cred_Num__c = '996691',
    			TMT_Search__c = 'USA-' + ZIP1,
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		),
			new Account_Relationship__c(
    			Partner_1__c = accountMap.get('DC-Distributor Customer').Id,
    			Market__c = 'Water Distribution',
    			Ship_To_Name__c = 'test',
                Ship_To_Number__c = '0001',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = ZIP1,
    			Partner_2_Sales_Cred_Num__c = '996691',
    			TMT_Search__c = 'USA-' + ZIP1,
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		),
			new Account_Relationship__c(
    			Partner_1__c = accountMap.get('UD-Utility Distributor').Id,
    			Market__c = 'Oil & Gas',
    			Ship_To_Name__c = 'test',
                Ship_To_Number__c = '0001',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = ZIP1,
    			Partner_2_Sales_Cred_Num__c = '996691',
    			TMT_Search__c = 'USA-' + ZIP1,
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		),
			new Account_Relationship__c(
    			Partner_1__c = accountMap.get('IR-Flow Industrial/Commercial Rep').Id,
    			Market__c = 'Water Distribution',
    			Ship_To_Name__c = 'test',
                Ship_To_Number__c = '0001',
    			Partner_2_Shipping_Street__c = '01192',
    			Partner_2_Shipping_City__c = 'OMAHA',
    			Partner_2_Shipping_State__c = 'NE - NEBRASKA',
    			Partner_2_Shipping_Country__c = 'UNITED STATES',
    			Partner_2_Shipping_Postal_Code__c = ZIP1,
    			Partner_2_Sales_Cred_Num__c = '996691',
    			TMT_Search__c = 'USA-' + ZIP1,
    			Sales_Credit_Name__c = 'CAROLINA METER & SUPPLY'
    		)
		};

		insert accountRelationships;
        
        Product2 testProduct = new Product2(Name='Test Product',Description='TEST');
        insert testProduct;

		// Tests BEACON code in the Account Relationship Trigger
        insert new Beacon_Service_Pricing__c(
            Account_ID__c = accountMap.get('UC-Utility Customer').Id,
            Bill_To_Number__c = '09324041',
            Ship_To_Number__c = '0001',
            Increment__c = 1, 
            Item_Number__c = testProduct.Id,
         	Price__c = 1.0
        );              
        
		Test.startTest();

		accountRelationships[0].Market__c = 'Water Distribution';
		accountRelationships[0].Partner_2_Shipping_Country__c = 'CANADA';
        accountRelationships[0].Partner_2_Sales_Cred_Num__c = '121212'; // Tests BEACON code in the Account Relationship Trigger
        accountRelationships[0].Partner_2_Shipping_Postal_Code__c = 'A9A 9A9';
        accountRelationships[0].Ship_To_Number__c = '0001';
        

		accountRelationships[1].Market__c = 'Oil & Gas';
		accountRelationships[1].Partner_2_Shipping_Country__c = 'MEXICO';
		accountRelationships[1].Ship_To_Number__c = '0001';
        
		accountRelationships[2].Partner_2_Shipping_State__c = 'NC - NORTH CAROLINA';
		accountRelationships[2].Ship_To_Number__c = '0001';
        
		accountRelationships[3].Market__c = 'Agriculture Irrigation';
		accountRelationships[3].Ship_To_Number__c = '0001';
        
		update accountRelationships;

		Test.stopTest();
	}
}