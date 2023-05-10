global with sharing class TMTCreateBatchJob implements Database.Batchable<SObject>, Database.Stateful
{
    global list<TMT__c> TMTList {get; set;}
    
    global TMTCreateBatchJob()
    {
        if (TMTList == null){
            TMTList = new list<TMT__c>();
        }
    }
    
    global TMTCreateBatchJob(list<TMT__c> TempTMTList)
    {
        TMTList = TempTMTList;
    }    
    
    public List<sObject> start(Database.BatchableContext context)
    {
        return TMTList;  
    }
    
    public void execute(Database.BatchableContext context, List<TMT__c> TMTs)
    {
        try
        {
            Database.UpsertResult[] uRes = Database.upsert(TMTs);                
        }
        catch (Exception e)
        {
            system.debug('ERROR: ' + e.getMessage());
            system.debug('ERROR: line number: ' + e.getLineNumber());
        }
    }
    
    public void finish(Database.BatchableContext bc)
    {
  
    }
}