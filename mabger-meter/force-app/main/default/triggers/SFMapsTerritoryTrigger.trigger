trigger SFMapsTerritoryTrigger on maps__ShapeLayer__c (after insert, after update) {

    if (MapAnythingTerritoryTriggerAntirecursion.runOnce()) {
        List <maps__ShapeLayer__c> territories = trigger.new;
        MapAnythingTerritoryCloner.cloneTerritories(territories);
    }

}