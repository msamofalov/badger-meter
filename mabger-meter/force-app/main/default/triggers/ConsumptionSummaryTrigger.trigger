trigger ConsumptionSummaryTrigger on Consumption_Summary__c (before insert, before update) {
    if (trigger.isBefore) {
        BeaconHelper.updateAggregatorFields(trigger.new);
    }
}