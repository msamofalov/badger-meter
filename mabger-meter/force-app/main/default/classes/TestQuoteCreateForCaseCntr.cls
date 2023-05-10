@isTest
public class TestQuoteCreateForCaseCntr implements HttpCalloutMock {

	static testMethod void myUnitTest() {
		
		Account objAcc = new Account(Name = 'Test Acc', BillingCountryCode = 'US', BillingPostalCode = '68137');
        insert objAcc;
        
        Case objCase = new Case(AccountId = objAcc.Id, status = 'open', subject = 'test123');
        insert objCase;
        
        insert new BigmachinesIntegration__c(Name = 'Credentials', EndPointURL__c = 'https://test2badgermeter.bigmachines.com/rest/v1/commerceDocumentsBadgerMeterWorkflowQuote',
        									 UserName__c = 'testUserName', Password__c = 'testPW');
        									 
    	System.currentPageReference().getParameters().put('caseId', objCase.Id);
        System.currentPageReference().getParameters().put('accId', objAcc.id);
        
        QuoteCreateForCaseCntr objCntr = new QuoteCreateForCaseCntr();
        
        Test.setMock(HttpCalloutMock.class, new TestQuoteCreateForCaseCntr());
        
        Test.startTest() ;
        	objCntr.createQuote();
		Test.stopTest();
		
		List<BigMachines__Quote__c> lstQuotes = [SELECT Case__c, BigMachines__Account__c, Name FROM BigMachines__Quote__c];
		System.assertEquals(1, lstQuotes.size());
		System.assertEquals(objCase.Id, lstQuotes[0].Case__c);
		System.assertEquals(objAcc.Id, lstQuotes[0].BigMachines__Account__c);
		System.assertEquals('240056', lstQuotes[0].Name);
	}
	
	/*
		@Name 			: respond
		@Description	: Creates a mock HTTP response.
		@Type 			: public
		@Parameters		: HTTPRequest
	*/
	public HTTPResponse respond(HTTPRequest req) {
		
		HttpResponse res = new HttpResponse();
		
		res.setHeader('Content-Type', 'application/json');
	    res.setBody('{"_id":"260285836",' 
	    			+ '"_customer_id":"0015000000zS11AAAS","caseNumber_quote":"00001402", "transDescription_quote" : "", "includesLiquidatedDamages_quote" : "false",'
	    			+ '"transactionType_quote" : "Test", "quoteType_quote" : "null", "status_quote" : "preparation", "propEffectiveDate_quote" : "2016-03-24 00:00:00",'
	    			+ '"propExpDate_quote" : "2016-09-20 00:00:00", "PONumber_quote" : "null", "orderNumber_quote" : "null", "propCreateBy_quote": "Test User","propNum_quote": "240056"}'
	            );
	    res.setStatus('OK'); 
	    res.setStatusCode(200);
		            
		return res;
	}
}