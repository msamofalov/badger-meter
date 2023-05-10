trigger BigMachinesQuoteTotalAmount on BigMachines__Quote__c (before insert, before update, before delete) {
    if(Trigger.isBefore && Trigger.isInsert){
        OpportunityHelper.setOpportunityAmount(trigger.newmap);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityHelper.setOpportunityAmount(trigger.newmap);
    }
    
    if(Trigger.isBefore && Trigger.isDelete){
        OpportunityHelper.setOpportunityAmountDeletion(trigger.oldmap);
    }
    
}