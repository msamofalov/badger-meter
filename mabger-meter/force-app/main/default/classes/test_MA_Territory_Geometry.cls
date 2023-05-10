@istest
public class test_MA_Territory_Geometry {

    @istest
    static void Run_Territory_Geometry_Test(){

        list <TMT__c> Tmts = new list <TMT__c>{
            // Northeast
            new TMT__c(
                Zip_Postal_Code__c = '00000',
                Sales_Credit_Number__c = '061779',
                Country__c = 'USA'
            ),
            // Southeast
            new TMT__c(
                Zip_Postal_Code__c = '11111',
                Sales_Credit_Number__c = '061060',
                Country__c = 'USA'
            ),
            // Midwest
            new TMT__c(
                Zip_Postal_Code__c = '22222',
                Sales_Credit_Number__c = '060613',
                Country__c = 'USA'
            ),
            // Central
            new TMT__c(
                Zip_Postal_Code__c = '33333',
                Sales_Credit_Number__c = '061044',
                Country__c = 'USA'
            ),
            // West
            new TMT__c(
                Zip_Postal_Code__c = '44444',
                Sales_Credit_Number__c = '061612',
                Country__c = 'USA'           
            ),
            // TMT Records to add this Territory to all Regions
            // Zip code matches a Zip in each Territory
            // SC# matches the first 6 characters of the name of the Territory
            new TMT__c(
                Zip_Postal_Code__c = '00000',
                Sales_Credit_Number__c = '123456',
                Country__c = 'USA'
            ),
            new TMT__c(
                Zip_Postal_Code__c = '11111',
                Sales_Credit_Number__c = '123456',
                Country__c = 'USA'
            ),
            new TMT__c(
                Zip_Postal_Code__c = '22222',
                Sales_Credit_Number__c = '123456',
                Country__c = 'USA'
            ),
            new TMT__c(
                Zip_Postal_Code__c = '33333',
                Sales_Credit_Number__c = '123456',
                Country__c = 'USA'
            ),
            new TMT__c(
                Zip_Postal_Code__c = '44444',
                Sales_Credit_Number__c = '123456',
                Country__c = 'USA'
            )
        };
        insert TMTs;
        
        list <maps__Folder__c> Folders = new List <maps__Folder__c>{
            new maps__Folder__c(
                name = 'Regions'
            )
        };
        insert Folders;
        
        list <maps__ShapeLayer__c> Territories = new List <maps__ShapeLayer__c>{
            new maps__ShapeLayer__c(
                Name = '123456 - Test Territory'
            )
        };
        insert Territories;
        
        list <maps__ShapeLayerGeometry__c> Geometries = new List <maps__ShapeLayerGeometry__c>{
            new maps__ShapeLayerGeometry__c(
                Name = 'Test Geometry',
                maps__ShapeLayer__c = Territories[0].id
            )
        };
        // Test Insert Geometry
        insert Geometries;
        
        // Test Update Geometry
        update Geometries;
    }    
}