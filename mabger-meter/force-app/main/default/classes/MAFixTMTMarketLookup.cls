global class MAFixTMTMarketLookup implements Database.Batchable<sObject>, Database.Stateful 
{
    //usage: Database.executeBatch(new MAFixTMTMarketLookup(), 200);

    global map<string, string> MarketSandboxProdIdMap;

    global MAFixTMTMarketLookup()
    {

    }

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        FillMarketMap();
        
        return Database.getQueryLocator ([SELECT Id, Name, Market__c, Market_Sandbox_ID__c FROM TMT__c]);
    }

    global void execute(Database.BatchableContext BC, List<TMT__c> scope) 
    {
        list<TMT__c> TMTUpdateList = new list<TMT__c>();
        
        for (TMT__c tmt : scope) 
        {
            if (tmt.Market_Sandbox_ID__c != null)
            {
                if (MarketSandboxProdIdMap.containsKey(tmt.Market_Sandbox_ID__c))
                {
                    tmt.Market__c = MarketSandboxProdIdMap.get(tmt.Market_Sandbox_ID__c);
                    TMTUpdateList.add(tmt);
                }
            }
        }
        
        update TMTUpdateList;
    }

    global void finish(Database.BatchableContext BC)
    {

    }
    
    private void FillMarketMap()
    {
        MarketSandboxProdIdMap = new map<string, string>();
        
        for (Market__c mkt : [SELECT Id, Sandbox_ID__c FROM Market__c])
        {
            if (mkt.Sandbox_ID__c != null)
            {
                MarketSandboxProdIdMap.put(mkt.Sandbox_ID__c, mkt.Id);    
            }
        }
    }
}