/*
	This batch syncs the Account and Account_Relationship__c objects with the TMT__c table nightly, or as scheduled.
	The MATest__c field is toggled and the record updated, which sends the record through its trigger + class logic.
	This can also be done ad hoc directly from the record detail view.
	Functionality of this batch can be extended to other objects by adding additional entries to the queryMap.

	Sample Execute Code
	
	ID batchProcessId = Database.executeBatch(new Batch_TMTSync());
	
	Sample Execute Anonymous Scheduling Code
	
	//Everyday @ 1:00 AM
	Batch_TMTSync.schedule('0 0 1 * * ?');
*/

public class Batch_TMTSync implements Database.Batchable<SObject>, Schedulable 
{
	final String baseAccountFilter = ' WHERE Organization_Type__c != null'
										+ ' AND TMT_Search__c != null'
										//+ ' AND Market__c != null'
										+ ' AND National_Strategic_Account__c = FALSE';
	final String baseAccountRelFilter = ' WHERE Market__c != null'
										+ ' AND TMT_Search__c != null'
										+ ' AND Partner_1__c != null'
										+ ' AND Partner_1__r.Customer_Number__c != null'		// 2019-10-08 - Allium IT, JWB - Added this clause to filter out account relationships where the owning account does not have a customer number.
										+ ' AND Manual_SC__c = FALSE'
										+ ' AND Partner_2_Shipping_Country__c in (\'UNITED STATES\', \'CANADA\', \'MEXICO\')';

	final Map<String, String> queryMap = new Map<String, String>{
		'ACCOUNT' => 'SELECT Id, MATest__c FROM Account' + baseAccountFilter,
		'ACCOUNT_RELATIONSHIP' => 'SELECT Id, MATest__c FROM Account_Relationship__c' + baseAccountRelFilter
	};

	public String objectName;
	
	public Batch_TMTSync(String objectName) 
	{
		this.objectName = objectName;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(queryMap.get(objectName));
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
		UUtil.inBatch = true;

		for (sObject sObj : scope) 
		{
			sObj.put('MATest__c', !(Boolean) sObj.get('MATest__c'));
		}

		update scope;
	}
	
	public void finish(Database.BatchableContext BC)
    {
    	//nothing to do
    }

    public void execute(SchedulableContext SC) 
    {
        Id accountBatchId = Database.executeBatch(new Batch_TMTSync('ACCOUNT'));
        Id accountRelationshipBatchId = Database.executeBatch(new Batch_TMTSync('ACCOUNT_RELATIONSHIP'));
    }
    
    public static void schedule()
    {
        schedule(null);
    }
    
    public static void schedule(string jobSchedule)
    {
        if (jobSchedule == null || jobSchedule.trim().length() == 0)
        {
            jobSchedule = '0 0 1 * * ?'; //Run the class at 1:00 AM
        }
        
        System.schedule(
        		(Test.isRunningTest()) ? 'Batch_TMTSync Account Processing TESTING' : 'Batch_TMTSync Account Processing', 
        		jobSchedule, 
        		new Batch_TMTSync('ACCOUNT')
        	);

        System.schedule(
        		(Test.isRunningTest()) ? 'Batch_TMTSync Account Relationship Processing TESTING' : 'Batch_TMTSync Account Relationship Processing', 
        		jobSchedule, 
        		new Batch_TMTSync('ACCOUNT_RELATIONSHIP')
        	);
    }
	
}