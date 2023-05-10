/**
    @Name           :   NewQuoteCreateForCaseCntr
    @Created Date   :   08 Jan, 2021 by KKake
    @Description    :   An apex page controller for QuoteCreateForCase.page which will create a Quote on both Bigmachine and Salesforce.
    @TestClass      :   TestQuoteCreateForCaseCntr.cls
*/
public with sharing class NewQuoteCreateForCaseCntr {
  
    private Id                      caseId;
    private Id                      accountId;   
    private String                  strCaseNumber;
    public  String                  messages                {get; private set;}
    public  Boolean                 hasPONumber             {get; private set;} 

    public  Boolean                 hasExistingQuotes       {get; private set;}
    public  List <BigMachines__Quote__c> existingQuotes     {get; private set;}

    public String                   forwardingURL           {get; private set;}
      
    public  String                  companyNumber           {get; private set;}  
    public  String                  accountCurrency         {get; private set;}  
    
    public NewQuoteCreateForCaseCntr () {
        initialize();
        validate();
    }

      
    private void initialize () {
        caseId       = System.currentPageReference().getParameters().get('caseId');
        accountId    = System.currentPageReference().getParameters().get('accId');
        messages = '';
        forwardingURL = '';
        hasExistingQuotes = false;

        companyNumber = '';
        accountCurrency = '';
                       
        validate();
    }

 
    private void validate () {
        Case theCase = [Select Id, AccountId, PO_Number__c From Case Where Id = :caseId];
        Account account = [Select Company_Number__c, CurrencyIsoCode From Account Where Id = :accountId];
        
        companyNumber = account.Company_Number__c;
        accountCurrency = account.CurrencyIsoCode;
        
        hasPONumber = !String.isEmpty(theCase.PO_Number__c) && theCase.PO_Number__c != 'BADGER SERVICES';
        
        if (hasPONumber) getExistingQuotes(theCase.AccountId, theCase.PO_Number__c);

        System.debug('MESSAGES: '+ messages);
        System.debug('hasPONumber: '+ hasPONumber);        
        System.debug('Company Number: ' + companyNumber);
        System.debug('Account Currency: ' + accountCurrency);
    }

    public void continueOn () {
        System.debug('HAS EXISTING QUOTES: '+ hasExistingQuotes);
        
        if (accountCurrency != 'EUR' && companyNumber == '14 - BADGER METER EUROPA GmbH (Germany)')
        {                 
            return; 
         }
        else if(hasExistingQuotes == false)  
        {                                
                     
             createQuote();
         }
        
    }


    @TestVisible
    private void getExistingQuotes (String accountId, String poNumber) {
        existingQuotes = new List <BigMachines__Quote__c> ([Select Id, Name, CreatedDate, CreatedBy.Name, BigMachines__Status__c, BigMachines__Total_Amount__c From BigMachines__Quote__c Where BigMachines__Account__c = :accountId And PO_Number__c = :poNumber And CreatedDate = LAST_N_DAYS:30]);
        hasExistingQuotes = existingQuotes.size() > 0;
    }
  

    public PageReference createQuote () {
        
        // Get the case and it's account.
        Case c = [Select Id, AccountId, Account.Name, CaseNumber, PO_Number__c, ContactEmail From Case Where Id = :caseId];
        
        // Construct an update for the owning account that places this case ID in a particular field.
        Account a = new Account();
        a.Id = c.AccountId;
        a.Case_for_Quote__c = c.Id;
        a.CaseNum_to_Quote__c = c.CaseNumber;
        a.PONum_to_Quote__c   = c.PO_Number__c;
        a.Case_Contact_Email_to_Quote__c   = c.ContactEmail;
              
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
        
        System.debug('Forwarding URL : '+ forwardingURL);
        
        return new PageReference(forwardingURL);
    }
  

    public PageReference returnToCase () {
        return new PageReference('/'+caseId);
    }

}