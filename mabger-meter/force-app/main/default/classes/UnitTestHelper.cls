@isTest
public class UnitTestHelper {

	public Market__c getMarket(){
		Market__c market = new Market__c();
		market.Name =  'Process' ;
		market.Product__c = 'Hedland';
		
		return market;
	}
	public Market__c getMarketUtilityDirect(){
		Market__c market = new Market__c();
		market.Name =  'Utility Direct' ;
		market.Product__c = 'Hedland';
		
		return market;
	}
	public List<Sales_Credit_ID__c> getSalesCreditIDs(Integer count, List<User> users){
		List<Sales_Credit_ID__c> tempsalesCreditIDs = new List<Sales_Credit_ID__c>();
		for (Integer i = 0; i < count; i++){
			Sales_Credit_ID__c scid = new Sales_Credit_ID__c();
			scid.Active__c = true;
			scid.Name = 'Unit Test' + i;
			scid.Sales_Credit_Number__c = '99669' + i;
			scid.User__c = users[i].id;
			System.debug('scid: ' + scid);
			tempsalesCreditIDs.add(scid);
		}
		return tempsalesCreditIDs;
	}
	public TMT__c getTMT(String zip, id marketId){
		TMT__c tmt = new TMT__c();
		tmt.Zip_Postal_Code__c = zip;
		tmt.Country__c = 'USA';
		tmt.Market__c = marketId;
		tmt.Sales_Credit_Number__c = '996691';
		
		return tmt;
	
	}

	public Account getAccount(String zip){
		Account acc = new Account();
		Id accountRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Direct_End_Customer'].Id;
		
		acc.RecordTypeId = accountRecordTypeId;
		acc.Name = 'Unit Test Account';
		acc.Organization_Type__c = 'UC-Utility Customer';
	//	acc.Organization_Type_v2__c = 'UC-Utility Customer';
	//	acc.Badger_Meter_Business_Unit__c = 'Utility';
		acc.Active__c = true;
		acc.BillingPostalCode = zip;
		acc.BillingCountry= 'United States';
		acc.BillingCountryCode = 'US';
		acc.National_Strategic_Account__c = false;
		return acc;
	}

}