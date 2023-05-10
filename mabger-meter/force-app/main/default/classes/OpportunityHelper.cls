public class OpportunityHelper {
    
    static boolean isRefresh=false;
    
    public static void setTotalAmountBasedOnQuotes (List<Opportunity> opportunityList){
        Map<Id, Decimal> oqBmAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> oqPartialMap = new Map<Id, Decimal>();
        Decimal temp=0.0;
        
        if(isRefresh){
        } else {
            List<BigMachines__Quote__c> quotesList = [Select Id, BigMachines__Opportunity__c,BigMachines__Total_Amount__c, Partial_Win_dollar_Amount2__c //Partial_Win_Product_Dollars__c 
                                                      from BigMachines__Quote__c 
                                                      where BigMachines__Opportunity__c in :opportunityList];
            //compute the total sum for each opportunity
            for(BigMachines__Quote__c quote:quotesList){
                // summation for Total Opportunity field
                if(quote.BigMachines__Total_Amount__c != null || quote.Partial_Win_dollar_Amount2__c != null){
                    if(oqBmAmountMap.containsKey(quote.BigMachines__Opportunity__c)){
                        temp = oqBmAmountMap.get(quote.BigMachines__Opportunity__c) + quote.BigMachines__Total_Amount__c;
                        oqBmAmountMap.put(quote.BigMachines__Opportunity__c, temp);
                    } else {
                        oqBmAmountMap.put(quote.BigMachines__Opportunity__c, quote.BigMachines__Total_Amount__c);
                    }
                } else {} //do nothing since amount is null
                
                // summation for Opportunity Amount
                if(quote.Partial_Win_dollar_Amount2__c != null){
                    if(oqPartialMap.containsKey(quote.BigMachines__Opportunity__c)){
                        temp = oqPartialMap.get(quote.BigMachines__Opportunity__c) + quote.Partial_Win_dollar_Amount2__c;
                        oqPartialMap.put(quote.BigMachines__Opportunity__c, temp);
                    } else {
                        oqPartialMap.put(quote.BigMachines__Opportunity__c, quote.Partial_Win_dollar_Amount2__c);
                    }
                } else {} //do nothing since amount is null
            }
            
            //sets the value of amount on opportunity
            for(Opportunity opp:opportunityList){
                if(oqBmAmountMap.get(opp.Id) != null) {
                    opp.Amount = oqPartialMap.get(opp.Id);	// oqBmAmountMap.get(opp.Id);
                }
                if(oqPartialMap.get(opp.Id) != null) {
                    //opp.Total_Opportunity__c = oqPartialMap.get(opp.Id);
                    opp.Original_Value__c = oqBmAmountMap.get(opp.Id);
                }
            }
        }
        
    }
    
    public static void setOpportunityAmount(Map<Id, BigMachines__Quote__c> quoteMap){
        Map<Id, Decimal> oqBmAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> oqBmPartialMap = new Map<Id, Decimal>();
        List<Id> oppIdList = new List<Id>();
        Decimal totalAmount = 0.0;
        
        // get the opportunity related to the given BM Quotes
        if(quoteMap != null){
            for(BigMachines__Quote__c quote:quoteMap.values()){
                if (quote.BigMachines__Opportunity__c!=null) {
                    oppIdList.add(quote.BigMachines__Opportunity__c);
                } //else continue;
            }
        }
        
        // search all the BM Quotes with related opportunity
        List<BigMachines__Quote__c> bmQuoteList = [Select id, BigMachines__Opportunity__c, BigMachines__Total_Amount__c, Partial_Win_dollar_Amount2__c 
                                                   from BigMachines__Quote__c 
                                                   where BigMachines__Opportunity__c in :oppIdList];
        
        for(BigMachines__Quote__c bmq:bmQuoteList){
            if(oqBmAmountMap.containsKey(bmq.BigMachines__Opportunity__c)){
                totalAmount = oqBmAmountMap.get(bmq.BigMachines__Opportunity__c) + bmq.BigMachines__Total_Amount__c;
                oqBmAmountMap.put(bmq.BigMachines__Opportunity__c, totalAmount);
             } else {
                oqBmAmountMap.put(bmq.BigMachines__Opportunity__c, bmq.BigMachines__Total_Amount__c);
             }
            if(oqBmPartialMap.containsKey(bmq.BigMachines__Opportunity__c)){
                totalAmount = oqBmPartialMap.get(bmq.BigMachines__Opportunity__c) + bmq.Partial_Win_dollar_Amount2__c;
                oqBmPartialMap.put(bmq.BigMachines__Opportunity__c, totalAmount);
             } else {
                oqBmPartialMap.put(bmq.BigMachines__Opportunity__c, bmq.Partial_Win_dollar_Amount2__c);
             }
        }
        
        // Set the opportunity amount with the correct total of all related BM Quotes
        List<Opportunity> opportunityList = [Select id, amount, Original_Value__c from Opportunity where id in :oqBmAmountMap.keySet()];
        List<Opportunity> oppUpdatedList = new List<Opportunity>();
        for(Opportunity opp:opportunityList){
            // opp.Amount = oqBmAmountMap.get(opp.id);
            opp.Amount = oqBmPartialMap.get(opp.id);
            // opp.Total_Opportunity__c = oqBmPartialMap.get(opp.id);
            opp.Original_Value__c = oqBmAmountMap.get(opp.id);
            oppUpdatedList.add(opp);
        }
        Database.update(oppUpdatedList);
    }
    
    public static void setOpportunityAmountDeletion(Map<Id, BigMachines__Quote__c> quoteMap){
        Map<Id, Decimal> oqBmAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> oqBmPartialMap = new Map<Id, Decimal>();
        List<Id> oppIdList = new List<Id>();
        Decimal totalAmount = 0.0;
        
        // get the opportunity related to the given BM Quotes
        if(quoteMap != null){
            for(BigMachines__Quote__c quote:quoteMap.values()){
                if (quote.BigMachines__Opportunity__c!=null) {
                    oppIdList.add(quote.BigMachines__Opportunity__c);
                } //else continue;
            }
        }
        
        // search all the BM Quotes with related opportunity
        List<BigMachines__Quote__c> bmQuoteList = [Select id, BigMachines__Opportunity__c, BigMachines__Total_Amount__c, Partial_Win_dollar_Amount2__c 
                                                   from BigMachines__Quote__c 
                                                   where BigMachines__Opportunity__c in :oppIdList];
        for(BigMachines__Quote__c bmq:bmQuoteList){
            if(quoteMap.containsKey(bmq.Id)){
                continue; 
            } else {
                if(oqBmAmountMap.containsKey(bmq.BigMachines__Opportunity__c)){
                    totalAmount = oqBmAmountMap.get(bmq.BigMachines__Opportunity__c) + bmq.BigMachines__Total_Amount__c;
                    oqBmAmountMap.put(bmq.BigMachines__Opportunity__c, totalAmount);
                } else {
                    oqBmAmountMap.put(bmq.BigMachines__Opportunity__c, bmq.BigMachines__Total_Amount__c);
                }
                if(oqBmPartialMap.containsKey(bmq.BigMachines__Opportunity__c)){
                    totalAmount = oqBmPartialMap.get(bmq.BigMachines__Opportunity__c) + bmq.Partial_Win_dollar_Amount2__c;
                    oqBmPartialMap.put(bmq.BigMachines__Opportunity__c, totalAmount);
                } else {
                    oqBmPartialMap.put(bmq.BigMachines__Opportunity__c, bmq.Partial_Win_dollar_Amount2__c);
                }
            }
        }
        
        // Set the opportunity amount with the correct total of all related BM Quotes
        List<Opportunity> opportunityList = [Select id, amount, Original_Value__c from Opportunity where id in :oqBmAmountMap.keySet()];
        List<Opportunity> oppUpdatedList = new List<Opportunity>();
        for(Opportunity opp:opportunityList){
            // opp.Amount = oqBmAmountMap.get(opp.id);
            opp.Amount = oqBmPartialMap.get(opp.id);
            // opp.Total_Opportunity__c = oqBmPartialMap.get(opp.id);
            opp.Original_Value__c = oqBmAmountMap.get(opp.id);
            oppUpdatedList.add(opp);
        }
        isRefresh=true;
        Database.update(oppUpdatedList);
    }
    
    // no more clones and transferring of quotes
    /*public static void cloneOpportunity(Map<Id, Opportunity> oppMap){
        List<Opportunity> oppList = [Select id from Opportunity where id in :oppMap.keySet()];
        Database.update(oppList);
    }*/
    
}