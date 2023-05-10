public class MapAnythingTerritoryCloner {
    
    public static void cloneTerritories (List <maps__ShapeLayer__c> territories) {
        
        
        
        
        
        // We need to get all folders and keep track of the structure that exists.
        maps__Folder__c rootRegionsFolder = [Select Id, Name From maps__Folder__c Where Name = 'Regions' Limit 1];
        
        // Maps and lists to hold information about the regional folders.
        Map <String, maps__Folder__c > regionalFoldersMap = new Map <String, maps__Folder__c > ();
        Map <String, Map <String, maps__Folder__c>> regionalMarketFoldersMap = new Map <String, Map <String, maps__Folder__c>> ();
        List <Id> regionalFolderIds = new List <Id> ();
        
        // Get and organize the regional folders.
        for (maps__Folder__c regionalFolder : [Select Id, Name, Prefix__c, maps__ParentFolder__c From maps__Folder__c Where maps__ParentFolder__c = :rootRegionsFolder.Id]) {
            regionalFolderIds.add(regionalFolder.Id);
            regionalFoldersMap.put(regionalFolder.Name, regionalFolder);
            regionalMarketFoldersMap.put(regionalFolder.Name, new Map <String, maps__Folder__c> ());
        }
        
        
        // Get all folders underneath the regional folders.
        for (maps__Folder__c regionMarketFolder : [Select Id, Name, maps__ParentFolder__c, maps__ParentFolder__r.Name From maps__Folder__c Where maps__ParentFolder__c in :regionalFolderIds]) {
            regionalMarketFoldersMap.get(regionMarketFolder.maps__ParentFolder__r.Name).put(regionMarketFolder.Name, regionMarketFolder);
        }
        
        
        
        
        
        
        
        // Create a list of the ids involved.
        List <Id> territoryIdList = createIdList(territories);
        
        // Transfer that id list into a string to use in a dynamic query.
        String territoryIdString = createStringFromIdList(territoryIdList);
        
        // Create a dynamic query that selects all fields on the object.
        String selectStarQuery = createSelectStarQuery('maps__ShapeLayer__c');
        
        String mainTerritoryQuery =  selectStarQuery+', maps__Folder__r.Name, (Select Id, Name, maps__Description__c, maps__Geometry__c, Geometry_Type__c, Regions__c, maps__ShapeLayer__c, Territory_Sandbox_ID__c From maps__ShapeLayerGeometries__r) From maps__ShapeLayer__c Where maps__ShapeLayer__c = null And Id in ('+ territoryIdString +')';
        String childTerritoryQuery =  selectStarQuery+', (Select Id, Name, maps__Description__c, maps__Geometry__c, Geometry_Type__c, Regions__c, maps__ShapeLayer__c, Territory_Sandbox_ID__c From maps__ShapeLayerGeometries__r) From maps__ShapeLayer__c Where maps__ShapeLayer__c != null And maps__ShapeLayer__c in ('+ territoryIdString +')';
        
        // Query the database to retrieve the full records from the indicated changes.
        List <maps__ShapeLayer__c> loadedMainTerritories = Database.query(mainTerritoryQuery);
        List <maps__ShapeLayer__c> loadedChildTerritories = Database.query(childTerritoryQuery);
        
        
        // Sort both sets of territories into maps. The main map is keyed by the record's id, and the child map is keyed by the parent's id for easy reference.
        Map <Id, maps__ShapeLayer__c> mainTerritoriesMap = new Map <Id, maps__ShapeLayer__c> ();
        for (maps__ShapeLayer__c mainTerritory : loadedMainTerritories) mainTerritoriesMap.put(mainTerritory.Id, mainTerritory);
        
        // Remove the child territories, we will be recreating them in a later step.
        delete loadedChildTerritories;
        
        
        
        // This list of folders will be inserted.
        List <maps__Folder__c> foldersToInsert = new List <maps__Folder__c> ();
        
        
        
        // For each territory, we want to make or maintain a clone that exists in a different part of the MapAnything folder hierarchy.
        for (maps__ShapeLayer__c mainTerritory : loadedMainTerritories) {
            
            List <maps__ShapeLayerGeometry__c> territoryGeometries = mainTerritory.maps__ShapeLayerGeometries__r;

            if (territoryGeometries != null && territoryGeometries.size() > 0) {
                // Take the regions multi-select picklist and split all of the values, trimming each one.
                String[] regions = cleanSplit(mainTerritory.Regions__c);
                
                for (String region : regions) {
                    if (regionalFoldersMap.containsKey(region)) {
                        
                        // We also need to check and see that we have an appropriate subfolder to put this in.
                        maps__Folder__c folder;
                        maps__Folder__c regionalFolder = regionalFoldersMap.get(region);
                        Map <String, maps__Folder__c> marketMap = regionalMarketFoldersMap.get(region);
                        
                        String regionalMarketFolderName = regionalFolder.Prefix__c + ' - ' + mainTerritory.maps__Folder__r.Name;
                        
                        
                        if (!marketMap.containsKey(regionalMarketFolderName)) {
                            maps__Folder__c newMarketFolder = new maps__Folder__c();
                            newMarketFolder.Name = regionalMarketFolderName;
                            newMarketFolder.maps__ParentFolder__c = regionalFoldersMap.get(region).Id;
                            
                            marketMap.put(regionalMarketFolderName, newMarketFolder);
                            foldersToInsert.add(newMarketFolder);
                            folder = newMarketFolder;
                        }
                    }
                }
            }
            
        }
        
        insert foldersToInsert;
        
        
        
        // This is the list of territories that will be upserted.
        List <maps__ShapeLayer__c> territoriesToUpsert = new List <maps__ShapeLayer__c> ();
        
        // A wrapper that links cloned territories with their related geometry to be created later.
        List <TerritoryClone> territoryClones = new List <TerritoryClone> ();
        
        // Get a list of the updateable fields on the territory object.
        List <String> updateableFields = getUpdateableFields('maps__ShapeLayer__c');
        
        List <maps__ShapeLayerGeometry__c> geometriesToUpsert = new List <maps__ShapeLayerGeometry__c> ();
        
        
        // For each territory, we want to make or maintain a clone that exists in a different part of the MapAnything folder hierarchy.
        for (maps__ShapeLayer__c mainTerritory : loadedMainTerritories) {
            
            List <maps__ShapeLayerGeometry__c> territoryGeometries = mainTerritory.maps__ShapeLayerGeometries__r;
            
            if (territoryGeometries != null && territoryGeometries.size() > 0) {
                
                // Take the regions multi-select picklist and split all of the values, trimming each one.
                String[] regions = cleanSplit(mainTerritory.Regions__c);
                
                for (String region : regions) {
                    maps__Folder__c regionalFolder = regionalFoldersMap.get(region);
                    String regionalMarketFolderName = regionalFolder.Prefix__c + ' - ' + mainTerritory.maps__Folder__r.Name;
                    
                    maps__Folder__c folder = regionalMarketFoldersMap.get(region).get(regionalMarketFolderName);
                    
                    maps__ShapeLayer__c clonedRegionTerritory = mainTerritory.clone(false, true, false, false);
                    clonedRegionTerritory.maps__ShapeLayer__c = mainTerritory.Id;
                    clonedRegionTerritory.Regions__c = region;
                    clonedRegionTerritory.maps__Folder__c = folder.Id;
                    clonedRegionTerritory.Territory_Type__c = 'Region';
                    
                    territoriesToUpsert.add(clonedRegionTerritory);
                    TerritoryClone tc = new TerritoryClone();
                    tc.clonedTerritory = clonedRegionTerritory;
                    for (maps__ShapeLayerGeometry__c geometry : territoryGeometries) {
                        maps__ShapeLayerGeometry__c clonedGeometry = geometry.clone(false, true, false, false);
                        clonedGeometry.Regions__c = region;
                        tc.geometries.add(clonedGeometry);
                    }
                    territoryClones.add(tc);
                }
            }
        }
        
        upsert territoriesToUpsert;
        
        
        
        for (TerritoryClone tc : territoryClones) {
            for (maps__ShapeLayerGeometry__c g : tc.geometries) {
                g.maps__ShapeLayer__c = tc.clonedTerritory.Id;
                geometriesToUpsert.add(g);
            }
        }
        
        upsert geometriesToUpsert;
    }
    
    
    public class TerritoryClone {
        public maps__ShapeLayer__c clonedTerritory;
        public List <maps__ShapeLayerGeometry__c> geometries;
        
        public TerritoryClone () {
            geometries = new List <maps__ShapeLayerGeometry__c> ();
        }
    }
    
    
    
    public static List <String> getUpdateableFields (String objectName) {
        List <String> updateableFields = new List <String> ();
        
        Map <String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) if(objectFields.get(s).getDescribe().isUpdateable()) updateableFields.add(s);
        
        return updateableFields;
    }
    
    
    public static String[] cleanSplit (String input) {
        if (!String.isBlank(input)) {
            String[] tokens = input.split(';');
            for (Integer i = 0; i < tokens.size(); i++) tokens[i] = tokens[i].trim();
            return tokens;
        }
        else {
            return new String[0];
        }
    }
    
    
    
    public static List <Id> createIdList (List <maps__ShapeLayer__c> territories) {
        List <Id> idList = new List <Id> ();
        for (maps__ShapeLayer__c t : territories) idList.add(t.Id);
        return idList;
    }
    
    
    public static String createStringFromIdList (List <Id> idList) {
        String idString = '';
        
        for (Id i : idList) idString += ('\''+ i + '\',');
        
        idString = idString.substring(0, idString.length()-1);
        
        return idString;
    }
    
    
    public static String createSelectStarQuery (String objectName) {
        String query = 'Select';
        
        Map <String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) query += ' ' + s + ',';

        // Strip off the last comma if it exists.
        String lastCharacter = query.subString(query.Length()-1,query.Length());
        //System.debug('LAST CHARACTER: '+ lastCharacter);
        if (lastCharacter == ',') query = query.subString(0,query.Length()-1);
        
        // Add FROM statement
        //query += ' From ' + objectName;
        //System.debug('QUERY: '+ query);
        return query;
    }
    
    
    public static void populatePrefixFieldsOnRegionalFolders () {
        // Get the root folder.
        maps__Folder__c rootRegionsFolder = [Select Id, Name From maps__Folder__c Where Name = 'Regions' Limit 1];
        
        List <maps__Folder__c> regionalFolders = [Select Id, Name, Prefix__c, maps__ParentFolder__c From maps__Folder__c Where maps__ParentFolder__c = :rootRegionsFolder.Id];
        
        // Get and organize the regional folders.
        for (maps__Folder__c regionalFolder : regionalFolders) {
            if (regionalFolder.Name == 'Northeast') regionalFolder.Prefix__c = 'NE';
            if (regionalFolder.Name == 'Midwest')   regionalFolder.Prefix__c = 'MW';
            if (regionalFolder.Name == 'West')      regionalFolder.Prefix__c = 'W';
            if (regionalFolder.Name == 'Central')   regionalFolder.Prefix__c = 'C';
            if (regionalFolder.Name == 'Southeast') regionalFolder.Prefix__c = 'SE';
        }
        
        update regionalFolders;
    }
}