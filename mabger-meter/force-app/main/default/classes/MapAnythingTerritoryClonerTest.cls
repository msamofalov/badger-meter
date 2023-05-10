@IsTest(SeeAllData=false)
public class MapAnythingTerritoryClonerTest {
    
    public static maps__Folder__c agricultureTerritoryFolder;
    
    public static testmethod void test () {
        createTestData();
        
        Test.startTest();
        
        maps__ShapeLayer__c agriculteralTerritory = new maps__ShapeLayer__c ();
        agriculteralTerritory.Name = 'Test Agriculture';
        agriculteralTerritory.maps__Folder__c = agricultureTerritoryFolder.Id;
        agriculteralTerritory.Regions__c = 'Midwest; West';
        agriculteralTerritory.Territory_Type__c = 'Market';
        agriculteralTerritory.maps__Options__c = '{"country":"shapesV2","advancedOptions":{"calculateTerritoryAggregates":false,"dissolveGeometry":true,"affectVisibility":false},"colorOptions":{"fillColor":"#3083D3","borderColor":"#16325C","fillOpacity":"0.2","labelEnabled":false,"labelOverride":"","labelJustification":"center","labelFontSize":"10px","labelFontColor":"#FFFFFF","labelBGColor":"#000000","labelBGOpacity":"0.3"}}';
        insert agriculteralTerritory;
        
        maps__ShapeLayerGeometry__c agriculteralTerritoryGeometry = new maps__ShapeLayerGeometry__c();
        agriculteralTerritoryGeometry.maps__Geometry__c = '{"4":["USA-53110","USA-53129","USA-53130","USA-53132","USA-53154","USA-53172"]}';
        agriculteralTerritoryGeometry.maps__ShapeLayer__c = agriculteralTerritory.Id;
        agriculteralTerritoryGeometry.Geometry_Type__c = 'Market';
        agriculteralTerritoryGeometry.Regions__c = 'Midwest; West';
        insert agriculteralTerritoryGeometry;
        
        
        agriculteralTerritory = [Select Id, Name, (Select Id From maps__ShapeLayerGeometries__r) From maps__ShapeLayer__c Where Id = :agriculteralTerritory.Id];
        List <maps__ShapeLayerGeometry__c> geometries = agriculteralTerritory.maps__ShapeLayerGeometries__r;
        
        MapAnythingTerritoryTriggerAntirecursion.reset();
        update agriculteralTerritory;

        list<maps__ShapeLayer__c> territoryList = new list<maps__ShapeLayer__c>();
        territoryList.add(agriculteralTerritory);
        MapAnythingTerritoryCloner.cloneTerritories(territoryList);

        Test.stopTest();    
    }
    
    
    
    
    public static void createTestData () {
        maps__Folder__c rootRegionsFolder = new maps__Folder__c();
        rootRegionsFolder.Name = 'Regions';
        insert rootRegionsFolder;
        
        maps__Folder__c centralRegionFolder = new maps__Folder__c();
        centralRegionFolder.Name = 'Central';
        centralRegionFolder.Prefix__c = 'C';
        centralRegionFolder.maps__ParentFolder__c = rootRegionsFolder.Id;
        insert centralRegionFolder;
        
        maps__Folder__c midwestRegionFolder = new maps__Folder__c();
        midwestRegionFolder.Name = 'Midwest';
        midwestRegionFolder.Prefix__c = 'MW';
        midwestRegionFolder.maps__ParentFolder__c = rootRegionsFolder.Id;
        insert midwestRegionFolder;
        
        maps__Folder__c southwestRegionFolder = new maps__Folder__c();
        southwestRegionFolder.Name = 'Southeast';
        southwestRegionFolder.Prefix__c = 'SW';
        southwestRegionFolder.maps__ParentFolder__c = rootRegionsFolder.Id;
        insert southwestRegionFolder;
        
        maps__Folder__c northeastRegionFolder = new maps__Folder__c();
        northeastRegionFolder.Name = 'Northeast';
        northeastRegionFolder.Prefix__c = 'NE';
        northeastRegionFolder.maps__ParentFolder__c = rootRegionsFolder.Id;
        insert northeastRegionFolder;
        
        maps__Folder__c westernRegionFolder = new maps__Folder__c();
        westernRegionFolder.Name = 'West';
        westernRegionFolder.Prefix__c = 'W';
        westernRegionFolder.maps__ParentFolder__c = rootRegionsFolder.Id;
        insert westernRegionFolder;
        
        
        
        maps__Folder__c rootTerritoriesFolder = new maps__Folder__c();
        rootRegionsFolder.Name = 'Territories';
        insert rootTerritoriesFolder;
    
        agricultureTerritoryFolder = new maps__Folder__c();
        agricultureTerritoryFolder.Name = 'Agriculture';
        agricultureTerritoryFolder.maps__ParentFolder__c = rootTerritoriesFolder.Id;
        insert agricultureTerritoryFolder;
        
        MapAnythingTerritoryCloner.populatePrefixFieldsOnRegionalFolders();
    }
    
}