/*
	Intended as a one-time sync for TMT records where User__c/Channel_Partner__c != matching Sales_Credit_ID__c record
	
	Sample Execute Code
	
	ID batchProcessId = Database.executeBatch(new Batch_TMTSalesIdMassUpdate());
*/

public class Batch_TMTSalesIdMassUpdate implements Database.Batchable<sObject>
{
	
	final String query = 'SELECT Id, Sales_Credit_Name__c, Sales_Credit_Number__c FROM TMT__c WHERE Sales_Credit_Number__c != null AND Sales_Credit_Name__c = null';
	
	public Batch_TMTSalesIdMassUpdate() {}
	
	public Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
   		List<TMT__c> records = (List<TMT__c>) scope;
   		Set<String> scIds = new Set<String>();
		Map<String, Sales_Credit_ID__c> scIdMap = new Map<String, Sales_Credit_ID__c>();

		for (TMT__c tmt : records)
		{
			scIds.add(tmt.Sales_Credit_Number__c);
		}

		for (Sales_Credit_ID__c sc : [SELECT 
											Channel_Partner__c, 
											Channel_Partner__r.Name, 
											User__c, 
											User__r.Name, 
											Sales_Credit_Number__c 
									  FROM 
									  		Sales_Credit_ID__c 
									  WHERE 
									  		Active__c = true
									  AND
									  		Sales_Credit_Number__c in : scIds
									  AND
									  		(Channel_Partner__c != null OR User__c != null)])
		{
			scIdMap.put(sc.Sales_Credit_Number__c, sc);
		}

		if (scIdMap.isEmpty())
		{
			return;
		}

		List<TMT__c> toUpdate = new List<TMT__c>();

		for (TMT__c tmt : records)
		{
			if (scIdMap.containsKey(tmt.Sales_Credit_Number__c))
			{
				Sales_Credit_ID__c sc = scIdMap.get(tmt.Sales_Credit_Number__c);
				String creditName;

				if (sc.User__c != null)
				{
					creditName = sc.User__r.Name;
				}
				else if (sc.Channel_Partner__c != null)
				{
					creditName = sc.Channel_Partner__r.Name;
				}

				if (creditName == null)
				{
					continue;
				}

				tmt.Sales_Credit_Name__c = (creditName.length() > 50) ? creditName.left(50) : creditName;
				toUpdate.add(tmt);
			}
		}

		if (toUpdate.isEmpty())
		{
			return;
		}

		UUtil.inBatch = true;
		handleSaveResult(Database.update(toUpdate, false));
		UUtil.inBatch = false;
	}

	private void handleSaveResult(List<Database.SaveResult> saveResult)
    {
        for (Database.SaveResult sr : saveResult)
        {
            if (sr.isSuccess())
            {

            }
            else
            {
                handleErrors(sr.getErrors());
            }
        }
    }
    
    private void handleErrors(List<Database.Error> errors)
    {
        for (Database.Error e : errors)
        {                  
        	System.debug('****Error: ' + e.getStatusCode() + ' - ' + e.getMessage());
        	System.debug('****Fields: ' + e.getFields());
        }
    }
	
	public void finish(Database.BatchableContext BC) 
	{
		
	}
	
}