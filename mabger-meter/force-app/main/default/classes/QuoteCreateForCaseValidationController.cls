global class QuoteCreateForCaseValidationController {
    
    private Case theCase;
    
    public 	List <BigMachines__Quote__c> quotes {get; set;}
    
    public 	Boolean hasPONumber 		{get; private set;}
    public	Boolean hasExistingQuotes 	{get; private set;}
    
    
    public QuoteCreateForCaseValidationController (ApexPages.StandardController controller) {
        String caseId = controller.getId();
        //String status = ApexPages.currentPage().getParameters().get('status');
        initialize(caseId);
    }
    
    public QuoteCreateForCaseValidationController () {
        String caseId = ApexPages.currentPage().getParameters().get('caseId');
        //String status = ApexPages.currentPage().getParameters().get('status');
        initialize(caseId);
    }
    
    
    private void initialize (String caseId) {
        theCase = getCase(caseId);
        
        if (String.isEmpty(theCase.PO_Number__c)) {
            hasPONumber = false;
        }
        else {
            hasPONumber = true;
            quotes = getQuotes(theCase.AccountId, theCase.PO_Number__c);
            
            if (quotes.size() != 0) {
                hasExistingQuotes = true;
            }
            else {
                hasExistingQuotes = false;
            }
        }
    }
    
    
    private static Case getCase (String Id) {
        Case theCase = [Select Id, AccountId, PO_Number__c From Case Where Id = :Id];
        return theCase;
    }
    
    private static List <BigMachines__Quote__c> getQuotes (String accountId, String poNumber) {
        List <BigMachines__Quote__c> quotes = [Select Id, Name, CreatedDate, CreatedBy.Name, BigMachines__Status__c, BigMachines__Total_Amount__c From BigMachines__Quote__c Where BigMachines__Account__c = :accountId And PO_Number__c = :poNumber And CreatedDate = LAST_N_DAYS:30 Limit 1];
        return quotes;
    }
    
    
    public PageReference cancel () {
        return new PageReference('/'+theCase.Id);
    }
    
    public PageReference ok () {
        String bigMachinesURL = getGenerateBigMachinesURL();
        return new PageReference(bigMachinesURL);
    }
    
    public String getGenerateBigMachinesURL () {
        String url = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('URL 1: '+ url);
        url = url.replace('c.', 'bigmachines.');
        System.debug('URL 2: '+ url);
        return url+'/apex/QuoteCreate?actId='+theCase.AccountId;
    }
    
    
	/**	Validates whether or not a case can have a new quote created from it.
     */ 
    webservice static String validateCanCreateNewQuoteFromCase (String caseId) {
        try {
            // Get the case.
            Case theCase = getCase(caseId);
            
            // Is there a PO number on this case?
            if (String.isBlank(theCase.PO_Number__c)) {
                return 'Please enter PO Number before Creating Quote.';
            }
            
            // Is there an existing quote with the case's account and PO number?
            List <BigMachines__Quote__c> quotes = getQuotes(theCase.AccountId, theCase.PO_Number__c);

            // If the quote couldn't be found, return this "not found" message and carry on.
            if (quotes.size() == 0) {
                return 'OK';
            }
			// Otherwise, the quote already exists. Go to the validation page.
            else {
                return '/apex/QuoteCreateForCaseValidation?caseId='+theCase.Id;
            } 
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }
}