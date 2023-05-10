@isTest
public class MA_TMTBatchTests {
    
    // test for TMTCreateBatchJob.cls
    static testmethod void CreateTMTTest() {
        UnitTestHelper helper = new UnitTestHelper();
        
        Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        
        List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        INSERT salesCreditIDs;
        
        // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Test Market';
        
        insert tMrkt;
        // insert some test tmts
        list<TMT__c> testTMTS = new list<TMT__c>();
        for (integer i=0; i < 50; i++) {
            TMT__c t = new tmt__c();
            t.Market__c = tMrkt.id;
            t.Sales_Credit_Number__c = salesCreditIDs[0].Sales_Credit_Number__c;
            t.Zip_Postal_Code__c = '28105';
            t.MATest__c = true;
            t.country__c = 'USA';
            t.country2__c = 'USA';
            testTMTS.add(t);
        }
        
        // with params
        test.startTest();
        
        TMTCreateBatchJob tmtcbj = new TMTCreateBatchJob(testTMTS);
        Database.executeBatch(tmtcbj);
        
        test.stopTest();
        
    }
    
    static testMethod void CreateTMTTest_nullParam() {
        test.startTest();
        // no params
        TMTCreateBatchJob tmtcbjNP = new TMTCreateBatchJob();
        Database.executeBatch(tmtcbjNP);
        test.stopTest();
    }
    
    static testmethod void DeleteTMTTest(){
        
        UnitTestHelper helper = new UnitTestHelper();
        
        Id profId = [SELECT id, name FROM Profile WHERE name = 'Badger Meter - Standard User' limit 1 ].Id;
        
        List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = : profId AND isactive = true Limit 5 ];
        
        List<Sales_Credit_ID__c> salesCreditIDs = helper.getSalesCreditIDs(5, users);
        
        INSERT salesCreditIDs;
         // create a test market
        Market__c tMrkt = new Market__c();
        tMrkt.Name = 'Test Market';
        
        insert tMrkt;
        // insert some test tmts
        list<TMT__c> testTMTS = new list<TMT__c>();
        for (integer i=0; i < 50; i++) {
            TMT__c t = new tmt__c();
            t.Market__c = tMrkt.id;
            t.Sales_Credit_Number__c = salesCreditIDs[0].Sales_Credit_Number__c;
            t.Zip_Postal_Code__c = '28105';
            t.MATest__c = true;
            t.country__c = 'USA';
            t.country2__c = 'USA';
            testTMTS.add(t);
        }
        insert testTMTS;
        
        test.startTest();
        TMTDeleteBatchJob tmtcbj = new TMTDeleteBatchJob(testTMTS);
        Database.executeBatch(tmtcbj);
        test.stopTest();
        
    }
    
    static testmethod void DeleteTMTTest_nullParam(){
        
        test.startTest();
        TMTDeleteBatchJob tmtcbj = new TMTDeleteBatchJob();
        Database.executeBatch(tmtcbj);
        test.stopTest();
        
    }

    static testmethod void ShapeLayerBatchPageTest () {
        sma__mafolder__c parentFldr = new sma__mafolder__c();
        parentFldr.name = 'Territories';
        insert parentFldr;        
        
        test.startTest();
        ShapeLayerBatchPage slbp = new ShapeLayerBatchPage();
        slbp.RunBatch();
        test.stopTest();
    }
    
    
}