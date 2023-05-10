global class MA_Territory_Geometry_Update_Batch implements Database.Batchable<sObject> {

    list <ID> geometryIDs;
    
    global MA_Territory_Geometry_Update_Batch(list <ID> geometryIDs_To_Process) 
    {
        geometryIDs = geometryIDs_To_Process;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, maps__Geometry__c, maps__ShapeLayer__r.name FROM maps__ShapeLayerGeometry__c WHERE ID in : geometryIDs';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<maps__ShapeLayerGeometry__c> geometries) {
        list <ID> geometryIDs = new list <ID>();
        for(maps__ShapeLayerGeometry__c geo : geometries){
            geometryIDs.add(geo.ID);
        }
        MA_Territory_Geometry.Populate_Geometry_Regions(geometryIDs);
        MA_Territory_Geometry.Populate_Territory_Regions(geometryIDs);        
    }   
    
    global void finish(Database.BatchableContext BC) {
        system.debug('Finished');
    }
}