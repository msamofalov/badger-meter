@isTest
public class MACustomMassActionControllerTest {
    static testmethod void MassActionTest_create () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;

        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;
        
        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;

        Market__c tMrkt2 = new Market__c();
        tMrkt2.Name = 'Utility Direct';
        tMrkt2.Product__c = 'BEACON; Cox; E-Series; High Resolution Encoders; ModMAG M-Series; ORION; Recordall';
        tMrkt2.Sandbox_ID__c = '1234';
        insert tMrkt2;
        
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<mapanything_zip_centroid__c> mzcs = new list<mapanything_zip_centroid__c>();
        for (integer i = 0; i < 50; i++) {
            MapAnything_Zip_Centroid__c mzc = new MapAnything_Zip_Centroid__c();
            mzc.Name = string.valueof(i);
            mzc.country__c = 'USA';
            mzc.country2__c = 'USA';
            //mzc.market__c = tMrkt.id;
            mzcs.add(mzc);
        }
        insert mzcs;
        
        list<string> idStrs = new list<string>();
        for (mapanything_zip_Centroid__c o:mzcs) {
            idStrs.add(string.valueof(o.id));
        }

        // SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE Market__c = :CustomTMT.Market__c
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt2.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        tmt__c existingTMT = new tmt__c();
        existingTMT.Market__c = tMrkt2.id;
        existingTMT.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        existingTMT.Zip_Postal_Code__c = '28105';
        existingTMT.MATest__c = true;
        existingTMT.country__c = 'USA';
        existingTMT.country2__c = 'USA';
        existingTMT.Market_Sandbox_ID__c = '1234';
        insert existingTMT;
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.conflictResolution = 'exclude';
        mcmac.getActions();
        mcmac.getMarkets();
        mcmac.getConflictRes();
        mcmac.actionTaken = 'Create';
        mcmac.validateZips();
        mcmac.CustomTMT = t;
        mcmac.doSaveWithRedirect();
        
        Test.stopTest();
    }
    
    static testmethod void MassActionTest_duplicatezips_none () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;
        
        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;

        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;

        Market__c tMrkt2 = new Market__c();
        tMrkt2.Name = 'Utility Direct';
        tMrkt2.Product__c = 'BEACON; Cox; E-Series; High Resolution Encoders; ModMAG M-Series; ORION; Recordall';
        tMrkt2.Sandbox_ID__c = '1234';
        insert tMrkt2;
        
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<mapanything_zip_centroid__c> mzcs = new list<mapanything_zip_centroid__c>();
        for (integer i = 0; i < 50; i++) {
            MapAnything_Zip_Centroid__c mzc = new MapAnything_Zip_Centroid__c();
            mzc.Name = string.valueof(28105);
            mzc.country__c = 'USA';
            mzc.country2__c = 'USA';
            //mzc.market__c = tMrkt.id;
            mzcs.add(mzc);
        }
        insert mzcs;
        
        list<string> idStrs = new list<string>();
        for (mapanything_zip_Centroid__c o:mzcs) {
            idStrs.add(string.valueof(o.id));
        }
        // SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE Market__c = :CustomTMT.Market__c
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt2.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        tmt__c existingTMT = new tmt__c();
        existingTMT.Market__c = tMrkt2.id;
        existingTMT.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        existingTMT.Zip_Postal_Code__c = '28105';
        existingTMT.MATest__c = true;
        existingTMT.country__c = 'USA';
        existingTMT.country2__c = 'USA';
        existingTMT.Market_Sandbox_ID__c = '1234';
        insert existingTMT;  
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.conflictResolution = 'none';
        mcmac.getActions();
        mcmac.getMarkets();
        mcmac.getConflictRes();
        mcmac.actionTaken = 'Create';
        mcmac.validateZips();
        mcmac.CustomTMT = t;
        mcmac.doSaveWithRedirect();
        
        Test.stopTest();
    }
    
    static testmethod void MassActionTest_duplicatezips_exclude () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;
        
        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;

        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;

        Market__c tMrkt2 = new Market__c();
        tMrkt2.Name = 'Utility Direct';
        tMrkt2.Product__c = 'BEACON; Cox; E-Series; High Resolution Encoders; ModMAG M-Series; ORION; Recordall';
        tMrkt2.Sandbox_ID__c = '1234';
        insert tMrkt2;
        
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<mapanything_zip_centroid__c> mzcs = new list<mapanything_zip_centroid__c>();
        for (integer i = 0; i < 50; i++) {
            MapAnything_Zip_Centroid__c mzc = new MapAnything_Zip_Centroid__c();
            mzc.Name = string.valueof(28105);
            mzc.country__c = 'USA';
            mzc.country2__c = 'USA';
            //mzc.market__c = tMrkt.id;
            mzcs.add(mzc);
        }
        insert mzcs;
        
        list<string> idStrs = new list<string>();
        for (mapanything_zip_Centroid__c o:mzcs) {
            idStrs.add(string.valueof(o.id));
        }
        // SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE Market__c = :CustomTMT.Market__c
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt2.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        tmt__c existingTMT = new tmt__c();
        existingTMT.Market__c = tMrkt2.id;
        existingTMT.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        existingTMT.Zip_Postal_Code__c = '28105';
        existingTMT.MATest__c = true;
        existingTMT.country__c = 'USA';
        existingTMT.country2__c = 'USA';
        existingTMT.Market_Sandbox_ID__c = '1234';
        insert existingTMT;  
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.conflictResolution = 'exclude';
        mcmac.getActions();
        mcmac.getMarkets();
        mcmac.getConflictRes();
        mcmac.actionTaken = 'Create';
        mcmac.validateZips();
        mcmac.CustomTMT = t;
        mcmac.doSaveWithRedirect();
        
        Test.stopTest();
    }
    
    static testmethod void MassActionTest_duplicatezips_update () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;
        
        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;

        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;

        Market__c tMrkt2 = new Market__c();
        tMrkt2.Name = 'Utility Direct';
        tMrkt2.Product__c = 'BEACON; Cox; E-Series; High Resolution Encoders; ModMAG M-Series; ORION; Recordall';
        tMrkt2.Sandbox_ID__c = '1234';
        insert tMrkt2;
        
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<mapanything_zip_centroid__c> mzcs = new list<mapanything_zip_centroid__c>();
        for (integer i = 0; i < 50; i++) {
            MapAnything_Zip_Centroid__c mzc = new MapAnything_Zip_Centroid__c();
            mzc.Name = string.valueof(28105);
            mzc.country__c = 'USA';
            mzc.country2__c = 'USA';
            //mzc.market__c = tMrkt.id;
            mzcs.add(mzc);
        }
        insert mzcs;
        
        list<string> idStrs = new list<string>();
        for (mapanything_zip_Centroid__c o:mzcs) {
            idStrs.add(string.valueof(o.id));
        }
        // SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE Market__c = :CustomTMT.Market__c
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        tmt__c t2 = new tmt__c();
        t2.Market__c = tMrkt.id;
        t2.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t2.Zip_Postal_Code__c = '28105';
        t2.MATest__c = true;
        t2.country__c = 'USA';
        t2.country2__c = 'USA';
        t2.Market_Sandbox_ID__c = '1234';
        insert t2;
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.conflictResolution = 'update';
        mcmac.getActions();
        mcmac.getMarkets();
        mcmac.getConflictRes();
        mcmac.actionTaken = 'Create';
        mcmac.validateZips();
        mcmac.CustomTMT = t;
        mcmac.doSaveWithRedirect();
        
        Test.stopTest();
    }
    
    static testmethod void MassActionTest_none () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;
        
        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;

        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;
        
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<mapanything_zip_centroid__c> mzcs = new list<mapanything_zip_centroid__c>();
        for (integer i = 0; i < 50; i++) {
            MapAnything_Zip_Centroid__c mzc = new MapAnything_Zip_Centroid__c();
            mzc.Name = string.valueof(i);
            mzc.country__c = 'USA';
            mzc.country2__c = 'USA';
            //mzc.market__c = tMrkt.id;
            mzcs.add(mzc);
        }
        insert mzcs;
        
        list<string> idStrs = new list<string>();
        for (mapanything_zip_Centroid__c o:mzcs) {
            idStrs.add(string.valueof(o.id));
        }
        // SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE Market__c = :CustomTMT.Market__c
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.getActions();
        mcmac.getMarkets();
        mcmac.getConflictRes();
        mcmac.actionTaken = 'None';
        mcmac.CustomTMT = t;
        mcmac.validateZips();
        mcmac.doSaveWithRedirect();
        
        Test.stopTest();
    }
    
    static testmethod void MassActionTest_delete () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;
        
        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;

        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;

        Market__c tMrkt2 = new Market__c();
        tMrkt2.Name = 'Utility Direct';
        tMrkt2.Product__c = 'BEACON; Cox; E-Series; High Resolution Encoders; ModMAG M-Series; ORION; Recordall';
        tMrkt2.Sandbox_ID__c = '1234';
        insert tMrkt2;
        
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<mapanything_zip_centroid__c> mzcs = new list<mapanything_zip_centroid__c>();
        for (integer i = 0; i < 50; i++) {
            MapAnything_Zip_Centroid__c mzc = new MapAnything_Zip_Centroid__c();
            mzc.Name = string.valueof(i);
            mzc.country__c = 'USA';
            mzc.country2__c = 'USA';
            //mzc.market__c = tMrkt.id;
            mzcs.add(mzc);
        }
        insert mzcs;
        
        list<string> idStrs = new list<string>();
        for (mapanything_zip_Centroid__c o:mzcs) {
            idStrs.add(string.valueof(o.id));
        }
        // SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE Market__c = :CustomTMT.Market__c
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt2.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.getActions();
        mcmac.getMarkets();
        mcmac.getConflictRes();
        mcmac.actionTaken = 'Delete';
        mcmac.CustomTMT = t;
        mcmac.validateZips();
        mcmac.doSaveWithRedirect();
        
        Test.stopTest();
    }
    
    static testmethod void MassActionTest_delete_NullTMT () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;

        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;

        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;
        
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<mapanything_zip_centroid__c> mzcs = new list<mapanything_zip_centroid__c>();
        for (integer i = 0; i < 50; i++) {
            MapAnything_Zip_Centroid__c mzc = new MapAnything_Zip_Centroid__c();
            mzc.Name = string.valueof(i);
            mzc.country__c = 'USA';
            mzc.country2__c = 'USA';
            //mzc.market__c = tMrkt.id;
            mzcs.add(mzc);
        }
        insert mzcs;
        
        list<string> idStrs = new list<string>();
        for (mapanything_zip_Centroid__c o:mzcs) {
            idStrs.add(string.valueof(o.id));
        }
        // SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE Market__c = :CustomTMT.Market__c
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.getActions();
        mcmac.getMarkets();
        mcmac.getConflictRes();
        mcmac.actionTaken = 'Delete';
        mcmac.CustomTMT = null;
        mcmac.validateZips();
        mcmac.doSaveWithRedirect();
        
        Test.stopTest();
    }
    
    static testmethod void MassActionTest_noTMT () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;

        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;
        
        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;
        
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<mapanything_zip_centroid__c> mzcs = new list<mapanything_zip_centroid__c>();
        for (integer i = 0; i < 50; i++) {
            MapAnything_Zip_Centroid__c mzc = new MapAnything_Zip_Centroid__c();
            mzc.Name = string.valueof(i);
            mzc.country__c = 'USA';
            mzc.country2__c = 'USA';
            //mzc.market__c = tMrkt.id;
            mzcs.add(mzc);
        }
        insert mzcs;
        
        list<string> idStrs = new list<string>();
        for (mapanything_zip_Centroid__c o:mzcs) {
            idStrs.add(string.valueof(o.id));
        }
        // SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE Market__c = :CustomTMT.Market__c
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.actionTaken = 'Create';
        //mcmac.CustomTMT = t;
        mcmac.doSaveWithRedirect();
        
        Test.stopTest();
    }

    static testmethod void MassActionTest_HighIDCount () {
       
        //SELECT Id, Name, country__c, country2__c FROM MapAnything_Zip_Centroid__c
        list<string> idStrs = new list<string>();
        for (integer i = 0; i < 10001; i++) {
           idStrs.add(string.valueof(i));
        }
        
        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('ids', string.join(idStrs, ','));
        MACustomMassActionController mcmac = new MACustomMassActionController();
        mcmac.checkMarketConflict();
        mcmac.validateZips();
        
        Test.stopTest();
    }
    
    static testmethod void MassActionTest_shapelayerpage () {
        //UnitTestHelper helper = new UnitTestHelper();
        
        //Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        //List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 1 ];
        
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        //List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(1, users);
        //INSERT salesCreditIDs;
        
        list<Sales_Credit_ID__c> scList = new list<Sales_Credit_ID__c>();
        Sales_Credit_ID__c sc = new Sales_Credit_ID__c();
        sc.Sales_Credit_Number__c = '151515';
        scList.add(sc);
        insert scList;
        
        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Oil & Gas';
        tMrkt.Product__c = 'ORION';
        insert tMrkt;
        
        tmt__c t = new tmt__c();
        t.Market__c = tMrkt.id;
        t.Sales_Credit_Number__c = scList[0].Sales_Credit_Number__c;//salesCreditIDs[0].Sales_Credit_Number__c;
        t.Zip_Postal_Code__c = '28105';
        t.MATest__c = true;
        t.country__c = 'USA';
        t.country2__c = 'USA';
        t.Market_Sandbox_ID__c = '1234';
        insert t;
        
        maps__Folder__c regionFolder = new maps__Folder__c();
        regionFolder.name = 'Regions';
        insert regionFolder;
        
        // insert territories
        maps__Folder__c parentFldr = new maps__Folder__c();
        parentFldr.name = 'Territories';
        insert parentFldr;
        
        maps__Folder__c marketFldr = new maps__Folder__c();
        marketFldr.name = 'Oil & Gas';
        marketFldr.maps__ParentFolder__c = parentFldr.Id;
        insert marketFldr;   

        maps__ShapeLayer__c terr  = new maps__ShapeLayer__c();
        terr.Name = 'Test';
        terr.Auto_Created__c = true;
        terr.maps__Folder__c = marketFldr.Id;
        insert terr;


        PageReference pRef = Page.MACustomMassAction;
        Test.setCurrentPage(pRef);
        Test.startTest();
        ShapeLayerBatchPage slbp = new ShapeLayerBatchPage();
        slbp.RunBatch();
        Test.stopTest();
        
    }
}