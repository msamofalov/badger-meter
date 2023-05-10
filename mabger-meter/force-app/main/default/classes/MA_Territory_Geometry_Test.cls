@IsTest(SeeAllData=false)
public class MA_Territory_Geometry_Test {
        
    public static testmethod void test () {
        
        Test.startTest();
        
        maps__Folder__c mapsFolder = new maps__Folder__c();
        mapsFolder.Name = 'Regions';
        insert mapsFolder;

        TMT__c tmt = new TMT__c();
        tmt.Country__c = 'USA';
        tmt.Zip_Postal_Code__c = '28262';
        tmt.Sales_Credit_Number__c = '061060';
        insert tmt;

        TMT__c tmt2 = new TMT__c();
        tmt2.Country__c = 'USA';
        tmt2.Zip_Postal_Code__c = '28204';
        tmt2.Sales_Credit_Number__c = '061779';
        insert tmt2;
        
        maps__ShapeLayer__c shape = new maps__ShapeLayer__c();
        shape.Name = '061060 Test';
        insert shape;

        maps__ShapeLayer__c shape2 = new maps__ShapeLayer__c();
        shape2.Name = '061779 Test';
        insert shape2;

        maps__ShapeLayerGeometry__c geo = new maps__ShapeLayerGeometry__c();
        geo.maps__ShapeLayer__c = shape.Id;
        insert geo;

        maps__ShapeLayerGeometry__c geo2 = new maps__ShapeLayerGeometry__c();
        geo2.maps__ShapeLayer__c = shape2.Id;
        insert geo2;

        list<Id> geoIdList = new list<Id>();
        geoIdList.add(geo.Id);
        geoIdList.add(geo2.Id);

        MA_Territory_Geometry.Populate_Geometry_Regions(geoIdList);
        MA_Territory_Geometry.Populate_Territory_Regions(geoIdList);

        MA_Territory_Geometry_Update_Batch MATerritoryGeometryUpdateBatch = new MA_Territory_Geometry_Update_Batch(geoIdList);
        Database.executeBatch(MATerritoryGeometryUpdateBatch);

        Test.stopTest();    
    }    
}