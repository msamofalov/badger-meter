trigger SFMaps_Territory_Geometry_Trigger on maps__ShapeLayerGeometry__c (before insert, before update, after insert, after update) {

    // Created by Allium 6/19/18

    if (!System.isBatch() && trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        list <ID> geometryIDs = new list<ID>();
        for (maps__ShapeLayerGeometry__c geo : trigger.new){
            // Don't update regions if Geo was created with Regions already set (by the cloner).
            if (trigger.isUpdate || string.isBlank(geo.Regions__c)){
                if (!MA_Territory_Geometry_checkRecursive.SetOfIDs.contains(geo.ID)){
                    geometryIDs.add(geo.ID);
                    MA_Territory_Geometry_checkRecursive.SetOfIDs.add(geo.ID);
                }
            }
        }
        if (geometryIDs.size() > 0){
            database.executebatch(new MA_Territory_Geometry_Update_Batch(geometryIDs), 1);            
        }
    }

}