@isTest
public class MAShapeLayerBatchTest {
    
    static testmethod void MACreateShapeLayersBatchableTest () {
            
            // create a test market
            Market__c tMrkt = new Market__c();
            tMrkt.Name = 'Oil & Gas';
            tMrkt.Product__c = 'ORION';
            insert tMrkt;
            
            // insert territories
            maps__Folder__c regionsFldr = new maps__Folder__c();
            regionsFldr.name = 'Regions';
            insert regionsFldr;
            
            // insert territories
            maps__Folder__c parentFldr = new maps__Folder__c();
            parentFldr.name = 'Territories';
            insert parentFldr;
            
            maps__Folder__c marketFldr = new maps__Folder__c();
            marketFldr.name = 'Oil & Gas';
            marketFldr.maps__ParentFolder__c = parentFldr.Id;
            insert marketFldr;            
            
            //UnitTestHelper helper = new UnitTestHelper();
            
            //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
            
            //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 6 ];
            //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
            
            //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(6, users);
            //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
            
            //INSERT salesCreditIDs;
            
            list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
            Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
            sc.Sales_Credit_Number__c = '151515';
            scList.add(sc);
            insert scList;
            
            // insert some test tmts
            list<TMT__c> testTMTS = new list<TMT__c>();
            
            TMT__c m1 = new tmt__c();
            m1.MATest__c = true;
            m1.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIds[0].Sales_Credit_Number__c;
            m1.Zip_Postal_Code__c = string.valueof('TMC8');
            m1.Market__c = tMrkt.id;
            m1.country__c = 'MEX';
            m1.country2__c = 'MEX';
            testTMTS.add(m1);
            
            /*tmt__c m2 = new tmt__c();
            m2.MATest__c = true;
            m2.Sales_Credit_Number__c = salesCreditIds[1].Sales_Credit_Number__c;
            m2.Zip_Postal_Code__c = string.valueof(28105);
            m2.Market__c = tMrkt.id;
            m2.country__c = 'CAN';
            m2.country2__c = 'CAN';
            testTMTS.add(m2);
            
            tmt__c m3 = new tmt__c();
            m3.MATest__c = true;
            m3.Sales_Credit_Number__c = salesCreditIds[2].Sales_Credit_Number__c;
            m3.Zip_Postal_Code__c = string.valueof(76225);
            m3.Market__c = tMrkt.id;
            m3.country__c = 'USA';
            m3.country2__c = 'USA';
            testTMTS.add(m3);*/   
            
            insert testTMTS;

            test.startTest();
            MACreateShapeLayersBatchableV2 mcslb = new MACreateShapeLayersBatchableV2(tMrkt.Name);
            Database.executeBatch(mcslb);
            
            test.stopTest();
    }
    
    static testmethod void MACustomLogicTest () {
        // insert territories
        maps__Folder__c regionsFldr = new maps__Folder__c();
        regionsFldr.name = 'Regions';
        insert regionsFldr;
    
        maps__Folder__c parentFldr = new maps__Folder__c();
        parentFldr.name = 'Territories';
        insert parentFldr;
        
        // create test markets 
        list<market__c> markets = new List<market__c>();
        for (integer m = 0; m < 50; m++){
            Market__c tMrkt = new Market__c();
            tMrkt.Name = string.valueof(m) + ' Market';
            markets.add(tMrkt);
        }
        insert markets;
        
        list<maps__Folder__c> testMarketFolders = new list<maps__Folder__c>();
        for (integer mf = 0; mf < 50; mf++) {
            maps__Folder__c smaFldr = new maps__Folder__c();
            smaFldr.name = string.valueof(mf);
            smaFldr.maps__ParentFolder__c = parentFldr.id;
            smaFldr.market__c = markets[mf].id;
            testMarketFolders.add(smaFldr);
        }
        insert testMarketFolders;
            
        //UnitTestHelper helper = new UnitTestHelper();
        
        Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 6 ];
        List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(6, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        
        //INSERT salesCreditIDs;
        
        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;
            
        // insert some test tmts
        list<TMT__c> testTMTS = new list<TMT__c>();
        
        TMT__c m1 = new tmt__c();
        m1.MATest__c = true;
        m1.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIds[0].Sales_Credit_Number__c;
        m1.Zip_Postal_Code__c = string.valueof('TMC8');
        m1.Market__c = markets[0].id;
        m1.country__c = 'MEX';
        m1.country2__c = 'MEX';
        testTMTS.add(m1);
        
        /*tmt__c m2 = new tmt__c();
        m2.MATest__c = true;
        m2.Sales_Credit_Number__c = salesCreditIds[1].Sales_Credit_Number__c;
        m2.Zip_Postal_Code__c = string.valueof(28105);
        m2.Market__c = markets[1].id;
        m2.country__c = 'CAN';
        m2.country2__c = 'CAN';
        testTMTS.add(m2);
        
        tmt__c m3 = new tmt__c();
        m3.MATest__c = true;
        m3.Sales_Credit_Number__c = salesCreditIds[2].Sales_Credit_Number__c;
        m3.Zip_Postal_Code__c = string.valueof(76225);
        m3.Market__c = markets[2].id;
        m3.country__c = 'USA';
        m3.country2__c = 'USA';
        testTMTS.add(m3);   */
        
        insert testTMTS;
        
        test.startTest();
        //MACustomLogic.MACreateShapeLayersBatchable_Execute_V2(testMarketFolders);
        test.stopTest();
    }

}