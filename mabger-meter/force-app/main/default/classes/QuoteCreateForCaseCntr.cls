/**
    @Name           :   QuoteCreateForCaseCntr
    @Created Date   :   07 April, 2016 by Trekbin
    @Description    :   An apex page controller for QuoteCreateForCase.page which will create a Quote on both Bigmachine and Salesforce.
    @TestClass      :   TestQuoteCreateForCaseCntr.cls
*/
public with sharing class QuoteCreateForCaseCntr {
  
    private Id                      caseId;
    private Id                      accountId;

  	//public  BigMachines__Quote__c   objNewQuote     {get;set;}
	
    //public  List <SelectOption>     siteOptions     {get; private set;}
    //public  Id                      selectedSiteId  {get; set;}
    
    private String                  strCaseNumber;
    
    public  String                  messages                {get; private set;}
    public  Boolean                 hasPONumber             {get; private set;}
    //@TestVisible
    //public  String                  isOrderOrQuote          {get; set;}
    //public  Boolean                 userChoseQuoteOption    {get; private set;}
    public  Boolean                 hasExistingQuotes       {get; private set;}

    public  List <BigMachines__Quote__c> existingQuotes     {get; private set;}

    public String                   forwardingURL           {get; private set;}
  

  	public QuoteCreateForCaseCntr () {
        initialize();
        validate();
    }

      
    private void initialize () {
        caseId       = System.currentPageReference().getParameters().get('caseId');
        accountId    = System.currentPageReference().getParameters().get('accId');

        //objNewQuote = new BigMachines__Quote__c (Case__c = caseId);
        
        //if (!String.isEmpty(accountId)) objNewQuote.BigMachines__Account__c = accountId;
    
        //strCaseNumber = '';

        messages = '';
        //isOrderOrQuote = '';
        //userChoseQuoteOption = true;
        forwardingURL = '';
        hasExistingQuotes = false;

        //loadSiteOptions();
        validate();
    }

    /*
    private void loadSiteOptions () {
        siteOptions = new List <SelectOption> ();

        // This query orders the site configurations so that the larger number (SITE-173) comes first, and SITE-000, which is not used, does not appear.
        for (BigMachines__Configuration_Record__c option : [Select Id, Name From BigMachines__Configuration_Record__c Where Name != 'SITE-000' Order By Name Desc]) {
            siteOptions.add(new SelectOption(option.Id, option.Name));
        }
    }
    */

    private void validate () {
        Case theCase = [Select Id, AccountId, PO_Number__c From Case Where Id = :caseId];
        hasPONumber = !String.isEmpty(theCase.PO_Number__c) && theCase.PO_Number__c != 'BADGER SERVICES';
        
        if (hasPONumber) getExistingQuotes(theCase.AccountId, theCase.PO_Number__c);

        System.debug('MESSAGES: '+ messages);
        System.debug('hasPONumber: '+ hasPONumber);
        //System.debug('userChoseQuoteOption: '+ userChoseQuoteOption);
    }

    public void continueOn () {
        System.debug('HAS EXISTING QUOTES: '+ hasExistingQuotes);
        if (hasExistingQuotes == false) createQuote();
        
        /*
        if (isOrderOrQuote == 'Order')      return returnToCase();
        else {
            userChoseQuoteOption = true;
            return createQuote();
        }
        */
    }

    /*
    public PageReference createQuoteAnyway () {
        userChoseQuoteOption = true;
        return null;
    }
    */

    @TestVisible
    private void getExistingQuotes (String accountId, String poNumber) {
        existingQuotes = new List <BigMachines__Quote__c> ([Select Id, Name, CreatedDate, CreatedBy.Name, BigMachines__Status__c, BigMachines__Total_Amount__c From BigMachines__Quote__c Where BigMachines__Account__c = :accountId And PO_Number__c = :poNumber And CreatedDate = LAST_N_DAYS:30]);
        hasExistingQuotes = existingQuotes.size() > 0;
    }
  

    public PageReference createQuote () {
        
        // Get the case and it's account.
        Case c = [Select Id, AccountId, Account.Name From Case Where Id = :caseId];
        
        // Construct an update for the owning account that places this case ID in a particular field.
        Account a = new Account();
        a.Id = c.AccountId;
        a.Case_for_Quote__c = c.Id;
        
        update a;
        
        // Schedule a job that will remove the case id from the account in a few seconds.
        QuoteCreateForCaseSchedule.scheduleJob(a.Id, 30);
        
        // Now, return the URL for the quote creation so that navigation can continue onward.
        String host = System.URL.getSalesforceBaseUrl().getHost();
        //System.debug(host);
        host = host.replace('--c', '--bigmachines');
        //System.debug(host);
        //String baseURL = 'https://badgermeter--test--bigmachines.visualforce.com/';
        String accountName = EncodingUtil.urlEncode(c.Account.Name, 'UTF-8');
        forwardingURL = 'https://'+host+'/apex/QuoteCreate?CF00N50000002povU='+ accountName +'&CF00N50000002povU_lkid='+ c.AccountId +'&scontrolCaching=1&retURL=%2F'+ c.AccountId +'&sfdc.override=1';
        
        return new PageReference(forwardingURL);
        /*
        System.debug('Creating quote...');

        objNewQuote.BigMachines__Site__c = selectedSiteId;
      
        String          endPointValue;
        Http            http = new Http();
        HttpResponse    response;
        PageReference   pageRef;
    
        //Get the credentials from custom setting.
        BigmachinesIntegration__c objCustomSetting = BigmachinesIntegration__c.getValues('Credentials');
    
        if (objCustomSetting != null) {
            System.debug('Retrieved BigMachines credentials.');

            //Get the userName and password.
            String userName = objCustomSetting.UserName__c;
            String password = objCustomSetting.Password__c;
            
            //Combine username and password and convert it into 64 bit encoded string.
            String encodedString = EncodingUtil.base64Encode(Blob.valueOf(userName+':'+password));
            
            // Send http post request to create Quote on Bigmachine.
            HttpRequest insertRequest = setHttpRequest(objCustomSetting, encodedString, 'Create');
            response = http.send(insertRequest);      
                
            //Get cpqId.
            parseAuthJSON(response.getBody());
            
            if (objNewQuote.BigMachines__Transaction_Id__c != null) {
                //send http post request to update the quote on BigMachine.
                HttpRequest updateRequest = setHttpRequest(objCustomSetting, encodedString, 'Update');
                
                response = http.send(updateRequest);
                System.debug('UPDATE RESPONSE: '+ response.getStatusCode() +' - '+response.getBody());
                
                if (response.getStatusCode() == 200) {
                    //sendEmail('BADGER JSON UPDATE', res.getBody());
                    
                    //Create quote in Salesforce.
                    insert objNewQuote;
                    
                    //redirect to Quote Edit page of the created quote.
                    pageRef = new PageReference('/apex/BigMachines__QuoteEdit?retURL=%2F'+objNewQuote.Id+'&scontrolCaching=1&sfdc.override=1&id='+objNewQuote.Id);
                    pageRef.setRedirect(true);
                    return pageRef;
                }
                else {
                    messages = response.getBody();
                }
                
            }
        }
        
        return null;
        */
    }
  
  	/*	@Name           :   setHttpRequest
      	@Description    :   Constructs HTTPRequest
      */
    /*  
	private HttpRequest setHttpRequest (BigmachinesIntegration__c objCustomSetting, String encodedString, String typeOfOperation) {
    
        BigMachines__Configuration_Record__c siteConfig = [Select Id, Name, Case_Specific_Process_Name__c, Save_Action__c From BigMachines__Configuration_Record__c Where Id = :selectedSiteId];
        
        String baseEndpoint = objCustomSetting.EndPointURL__c.remove(objCustomSetting.Core_Workflow__c);
          
        HttpRequest request = new HttpRequest();
        request.setHeader('content-type', 'application/json');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Basic '+encodedString);
        
        String endPointValue;
        
        if (typeOfOperation == 'Create') {
            endpointValue = baseEndpoint+siteConfig.Case_Specific_Process_Name__c;
        }
        else {
            endpointValue = baseEndpoint+siteConfig.Case_Specific_Process_Name__c+'/'+objNewQuote.BigMachines__Transaction_Id__c+'/actions/'+siteConfig.Save_Action__c;
            
            String jsonBody = '';
            if      (siteConfig.Name == 'SITE-173') jsonBody = getDocumentJSONForSite173(objNewQuote.BigMachines__Account__c, objNewQuote.Case__c);
            else if (siteConfig.Name == 'SITE-016') jsonBody = getDocumentJSONForSite016(objNewQuote.BigMachines__Account__c, objNewQuote.Case__c);

            request.setBody(jsonBody);
        }

        request.setEndpoint(endPointValue);
          
        System.debug('OPERATION: '+ typeOfOperation +' - ENDPOINT: '+ endpointValue);

        return request;
	}
    
    
    public static String getDocumentJSONForSite173 (String accountId, String caseId) {
        
        Case                    c   = [Select Id, CaseNumber, Account_Relationship_Ship_To__c, PO_Number__c From Case Where Id = :caseId];
        Account                 a   = [Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Default_Ship_To__c, Customer_Number__c, Primary_Sales_Credit_Number__c, payment_TermsP_3__c, Priority_Code__c, Acknowledgment__c, Customer_Service_Rep_Name__c, Organization_Type__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry From Account Where Id = :accountId];
        Account_Relationship__c ar  = null;
        User                    u   = [Select Id, FirstName, LastName, Email From User Where Id = :UserInfo.getUserId()];

        if (!String.isBlank(c.Account_Relationship_Ship_To__c)) {
            ar = [Select Id, Ship_To_Name__c, Partner_2__c, Partner_2_Warehouse_Order_Code__c, Partner_2_Shipping_Street__c, Partner_2_Shipping_City__c, Partner_2_Shipping_Country__c, Partner_2_Shipping_State__c, Partner_2_Shipping_Postal_Code__c, Bill_To_Country_Code__c From Account_Relationship__c Where Id = :c.Account_Relationship_Ship_To__c];
        }
        
        BigmachinesQuote_Site173 bmq = new BigmachinesQuote_Site173();
        bmq.customer_id 				        = accountId;
        bmq.caseNumber_quote 			        = c.CaseNumber;
        bmq.sFCaseID_quote				        = c.Id;
        bmq.bill_to_company_name		        = a.Name;
        bmq.bill_to_address				        = a.BillingStreet;
        bmq.bill_to_city				        = a.BillingCity;
        bmq.bill_to_state				        = a.BillingState;
        bmq.bill_to_zip					        = a.BillingPostalCode;
        bmq.bill_to_country				        = a.BillingCountry;
        bmq.bill_to_phone				        = a.Phone;
        bmq.shipToNumber_quote			        = a.Default_Ship_To__c;
        bmq.billToNumber_quote			        = a.Customer_Number__c;
        bmq.salesCreditNum_quote		        = a.Primary_Sales_Credit_Number__c;
        //bmq.proposedPaymentTerms_quote	        = a.payment_TermsP_3__c;
        bmq.customerServiceRep_quote	        = a.Customer_Service_Rep_Name__c;
        bmq.organizationType_quote		        = trimOrganizationType(a.Organization_Type__c);
        bmq.quoteType_quote                     = 'Order';
        bmq.pONumber_quote                      = c.PO_Number__c;
        bmq.priorityCode_quote                  = a.Priority_Code__c;
        bmq.masterPaymentTermsDisplay_quote     = a.payment_TermsP_3__c;
        bmq.printExternalAcknowledgement_quote  = translateAcknowledgement(a.Acknowledgment__c);
        bmq.crmUserId_quote                     = u.Id;
        bmq.preparedByName_quote                = u.FirstName+' '+u.LastName;
        bmq.preparedByEmail_quote               = u.Email;
        
        if (ar != null) {
            bmq.ship_to_company_name		= ar.Ship_To_Name__c;
            bmq.ship_to_address				= ar.Partner_2_Shipping_Street__c;
            bmq.ship_to_city				= ar.Partner_2_Shipping_City__c;
            bmq.ship_to_state				= ar.Partner_2_Shipping_State__c;
            bmq.ship_to_zip					= ar.Partner_2_Shipping_Postal_Code__c;
            bmq.ship_to_country				= ar.Bill_To_Country_Code__c;
            bmq.bSBAccount_quote			= ar.Partner_2__c;
            bmq.warehouseOrder_quote		= ar.Partner_2_Warehouse_Order_Code__c;
        }
        //bmq.crmOpportunityId_quote		= o.Id;
        //bmq.opportunityName_quote		= o.Name;
        
        
        BigmachinesQuoteBody_Site173 bmqb = new BigmachinesQuoteBody_Site173(bmq);
        String jsonBody = JSON.serialize(bmqb);
        
        jsonBody = jsonBody.replace('customer_id',          '_customer_id');
        jsonBody = jsonBody.replace('bill_to_company_name', '_bill_to_company_name');
        jsonBody = jsonBody.replace('bill_to_address',      '_bill_to_address');
        jsonBody = jsonBody.replace('bill_to_city',         '_bill_to_city');
        jsonBody = jsonBody.replace('bill_to_state',        '_bill_to_state');
        jsonBody = jsonBody.replace('bill_to_zip',          '_bill_to_zip');
        jsonBody = jsonBody.replace('bill_to_phone',        '_bill_to_phone');
        jsonBody = jsonBody.replace('bill_to_country',      '_bill_to_country');
        jsonBody = jsonBody.replace('ship_to_company_name', '_ship_to_company_name');
        jsonBody = jsonBody.replace('ship_to_address',      '_ship_to_address');
        jsonBody = jsonBody.replace('ship_to_city',         '_ship_to_city');
        jsonBody = jsonBody.replace('ship_to_state',        '_ship_to_state');
        jsonBody = jsonBody.replace('ship_to_zip',          '_ship_to_zip');
        jsonBody = jsonBody.replace('ship_to_country',      '_ship_to_country');
        
        return jsonBody;
    }

    public static String getDocumentJSONForSite016 (String accountId, String caseId) {
        
        Case c   = [Select Id, CaseNumber, Account_Relationship_Ship_To__c, PO_Number__c From Case Where Id = :caseId];
        

        BigmachinesQuote_Site016 bmq = new BigmachinesQuote_Site016();
        bmq.customer_id 				= accountId;
        bmq.sFCaseID_quote				= caseId;
        bmq.PONumber_quote              = c.PO_Number__c;
        
        BigmachinesQuoteBody_Site016 bmqb = new BigmachinesQuoteBody_Site016(bmq);
        String jsonBody = JSON.serialize(bmqb);
        
        jsonBody = jsonBody.replace('customer_id',          '_customer_id');
        
        return jsonBody;
    }
    

    private class BigmachinesQuoteBody_Site173 {
        public BigmachinesQuote_Site173 documents;
        
        public BigmachinesQuoteBody_Site173 (BigmachinesQuote_Site173 document) {
            this.documents = document;
        }
    }

    private class BigmachinesQuoteBody_Site016 {
        public BigmachinesQuote_Site016 documents;
        
        public BigmachinesQuoteBody_Site016 (BigmachinesQuote_Site016 document) {
            this.documents = document;
        }
    }
    

    private class BigmachinesQuote_Site173 {
        public String customer_id;
        public String caseNumber_quote;
        public String sFCaseID_quote;
        public String preparedByName_quote;
        public String bill_to_company_name;
        public String bill_to_address;
        public String bill_to_city;
        public String bill_to_state;
        public String bill_to_zip;
        public String bill_to_country;
        public String bill_to_phone;
        public String shipToNumber_quote;
        public String billToNumber_quote;
        public String salesCreditNum_quote;
        public String proposedPaymentTerms_quote;
        public String customerServiceRep_quote;
        public String organizationType_quote;
        public String ship_to_company_name;
        public String ship_to_address;
        public String ship_to_city;
        public String ship_to_state;
        public String ship_to_zip;
        public String ship_to_country;
        public String bSBAccount_quote;
        public String warehouseOrder_quote;
        public String quoteType_quote;
        public String pONumber_quote;
        //public String crmOpportunityId_quote;
        //public String opportunityName_quote;
        public String priorityCode_quote;
        public String masterPaymentTermsDisplay_quote;
        public String printExternalAcknowledgement_quote;
        public String crmUserId_quote;
        public String preparedByEmail_quote;
    }

    private class BigmachinesQuote_Site016 {
        public String customer_id;
        public String sFCaseID_quote;
        public String PONumber_quote;
    }
  

    private void parseAuthJSON(String strJSONValue) {
        
        JSONParser parser = JSON.createParser(strJSONValue);
        Integer counter = 0;
        
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                //Get cpqId and quote number.
                if (parser.getText() == '_id') {
                    parser.nextToken();
                    objNewQuote.BigMachines__Transaction_Id__c = parser.getText();
                
                } 
                else if (parser.getText() == 'propNum_quote') {
                    parser.nextToken();
                    objNewQuote.Name = parser.getText();
                }
                
                if (objNewQuote.BigMachines__Transaction_Id__c != null && objNewQuote.Name !=null)
                    break;
            }      
        }
    }


    private static String trimOrganizationType (String input) {
        return input != null ? input.substring(0, 2) : '';
    }


    private static String translateAcknowledgement (String input) {
        return input != null ? input.substring(0, 1).toUpperCase() : '';
    }
    */

    /*
    private static void sendEmail (String subject, String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setPlainTextBody(body);
        email.setSubject(subject);
        email.setToAddresses(new List<String> {'jbunda@alliumit.com'});
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email});
    }
    */



    public PageReference returnToCase () {
        return new PageReference('/'+caseId);
    }

}