global with sharing class TMTDeleteBatchJob implements Database.Batchable<SObject>, Database.Stateful
{
    global list<TMT__c> TMTList {get; set;}
    
    global TMTDeleteBatchJob()
    {
        if (TMTList == null){
            TMTList = new list<tmt__c>();
        }
    }
    
    global TMTDeleteBatchJob(list<TMT__c> TempTMTList)
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
            Database.DeleteResult[] deleteDR = Database.delete(TMTs);               
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