@isTest
public class OpportunityHelper_Test {

    static Account acct01;
    static Opportunity opp01;
    static Id opportunityId;
    static BigMachines__Quote__c bmq01;
    static BigMachines__Quote_Product__c bmqp;
    static BigMachines__Quote_Product__c bmprod;
    static Product2 prod2;
    
    public static void opportunityBmqTestData(){
        acct01 = new Account();
        List<RecordType> recordTypes = [Select Name, Id from RecordType where SObjectType = 'Account' AND Name like 'Channel Partner%'];
        acct01.RecordTypeId = recordTypes.get(0).id;
        acct01.Active__c = true;
        acct01.Name = 'Test Acct';
        acct01.BillingCountryCode = 'US';
        acct01.BillingPostalCode = '68137';
        insert acct01;
        
        opp01 = new Opportunity();
        recordTypes = [Select Name, Id from RecordType where SObjectType = 'Opportunity' AND Name like 'Utility%'];
        opp01.RecordTypeId = recordTypes.get(0).id;
        opp01.Name='Test Opportunity';
        opp01.StageName = 'Needs Analysis';
        opp01.CloseDate = System.Date.today();
        Database.SaveResult oppResult = Database.insert(opp01);
        opportunityId = oppResult.getId();
        
        prod2 = new Product2();
        prod2.name = '8220BR0005-1211';
        prod2.IsActive = true;
        prod2.ProductCode = '8220BR0005-1211';
        insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry pbookentry = new PriceBookEntry();
        pbookentry.Pricebook2Id = pricebookId;
        pbookentry.Product2Id = prod2.id;
        pbookentry.UnitPrice = 100.0;
        pbookentry.IsActive = true;
        insert pbookentry;
        
        bmq01 = new BigMachines__Quote__c();
        bmq01.BigMachines__Site__c = 'a075000000A9iLJAAZ';
        recordTypes = [Select Name, Id from RecordType where SObjectType = 'BigMachines__Quote__c' AND Name like 'Standard%'];
        bmq01.RecordTypeId = recordTypes.get(0).id;
        bmq01.BigMachines__Account__c = acct01.id;
        bmq01.BigMachines__Is_Primary__c = false;   // But always, this is automatically changed to true
        bmq01.BigMachines__Opportunity__c = opp01.id;
        bmq01.BigMachines__Status__c = 'preparation';
        bmq01.Partial_Win_Product_Dollars__c =200.0;
        //bmq01.Transaction_Type__c = 'Test';
        bmq01.BigMachines__Pricebook_Id__c = pricebookId;
        Database.SaveResult resbmq01 = Database.insert(bmq01);
        
        bmprod = new BigMachines__Quote_Product__c();
        bmprod.BigMachines__Product__c = prod2.id;
        bmprod.BigMachines__Quote__c = bmq01.id;
        bmprod.BigMachines__Quantity__c = 1.0;
        bmprod.BigMachines__Sales_Price__c = 100.0;
        bmprod.Name = '8220BR0005-1211';
        bmprod.Part_Number__c = '8220BR0005-1211';
        Database.saveresult resbmprod = Database.insert(bmprod);
    }
    
    public static BigMachines__Quote_Product__c addProduct(Id bmq01id, id productId){
        BigMachines__Quote_Product__c bmprod01 = new BigMachines__Quote_Product__c();
        bmprod01.BigMachines__Product__c = productId;
        bmprod01.BigMachines__Quote__c = bmq01id;
        bmprod01.BigMachines__Quantity__c = 2.0;
        bmprod01.BigMachines__Sales_Price__c = 200.0;   //total should be 500.0
        bmprod01.Name = '8220BR0005-1211';
        bmprod01.Part_Number__c = '8220BR0005-1211';
        return bmprod01;
    }
    
    public static BigMachines__Quote_Product__c addZeroProduct(Id bmq01id, id productId){
        BigMachines__Quote_Product__c bmprod01 = new BigMachines__Quote_Product__c();
        bmprod01.BigMachines__Product__c = productId;
        bmprod01.BigMachines__Quote__c = bmq01id;
        bmprod01.BigMachines__Quantity__c = 1.0;
        bmprod01.BigMachines__Sales_Price__c = 0.0;
        bmprod01.Name = '8220BR0005-1211';
        bmprod01.Part_Number__c = '8220BR0005-1211';
        return bmprod01;
    }
    
    public static BigMachines__Quote_Product__c addWonProduct(Id bmq01id, id productId){
        BigMachines__Quote_Product__c bmprod01 = new BigMachines__Quote_Product__c();
        bmprod01.BigMachines__Product__c = productId;
        bmprod01.BigMachines__Quote__c = bmq01id;
        bmprod01.BigMachines__Quantity__c = 1.0;
        bmprod01.BigMachines__Sales_Price__c = 75.0;
        bmprod01.Name = '8220BR0005-1211';
        bmprod01.Part_Number__c = '8220BR0005-1211';
        bmprod01.Won__c = true;
        return bmprod01;
    }
    
    public static testmethod void testAmountThruAdditionalProduct(){
        opportunityBmqTestData();
        
        Test.startTest();
        BigMachines__Quote_Product__c bmprod01 = addProduct(bmq01.id,prod2.id);
        Database.saveresult resbmprod = Database.insert(bmprod01);
        Test.stopTest();
        
        List<BigMachines__Quote_Product__c> bmprodList = [Select id, Part_Number__c, BigMachines__Product__c, BigMachines__Quantity__c, 
                                                          BigMachines__Quote__c, BigMachines__Sales_Price__c, BigMachines__Total_Price__c
                                                          from BigMachines__Quote_Product__c where id=:resbmprod.getId()];
        
        // Validates total price of added product
        System.assert(resbmprod.isSuccess());
        System.assertEquals(400.0, bmprodlist.get(0).BigMachines__Total_Price__c);
        
        //Validates total Quote amount
        List<BigMachines__Quote__c> bmq01List = [Select id, BigMachines__Total_Amount__c, BigMachines__Opportunity__c, Partial_Win_Product_Dollars__c 
                                                 from BigMachines__Quote__c where id=:bmq01.id];
        System.assertEquals(1, bmq01List.size());
        System.assertEquals(500.0, bmq01List.get(0).BigMachines__Total_Amount__c);
        System.assertEquals(200.0, bmq01List.get(0).Partial_Win_Product_Dollars__c);
        
    }
    
    public static testmethod void testBigMachineDeletion(){
        opportunityBmqTestData();
        
        // assert before deletion
        List<Opportunity> oppList = [Select id, Original_Value__c, Amount from Opportunity where id=:opportunityId];
        System.assertEquals(1, oppList.size());
        
        Test.startTest();
        Database.DeleteResult resDeleteQuote = Database.delete(bmq01);
        Test.stopTest();
        
        // assert after deletion
        System.assert(resDeleteQuote.isSuccess());
    }
    
    public static testmethod void testMultipleQuotes(){
        opportunityBmqTestData();   //this already creates a quote with no product
        
        Test.startTest();
        // create a quote and connect it with existing opportunity
        BigMachines__Quote__c quote01 = new BigMachines__Quote__c();
        quote01.BigMachines__Site__c = 'a075000000A9iLJAAZ';
        List<RecordType> recTypes = [Select Name, Id from RecordType where SObjectType = 'BigMachines__Quote__c' AND Name like 'Standard%'];
        quote01.RecordTypeId = recTypes.get(0).id;
        quote01.BigMachines__Account__c = acct01.id;
        quote01.BigMachines__Is_Primary__c = false;
        quote01.BigMachines__Opportunity__c = opportunityId;
        quote01.BigMachines__Status__c = 'preparation';
        quote01.BigMachines__Pricebook_Id__c = Test.getStandardPricebookId();
        Database.SaveResult resQuote01 = Database.insert(quote01);
        
        BigMachines__Quote_Product__c bmprod01 = addWonProduct(quote01.id,prod2.id);
        Database.saveresult resbmprod01 = Database.insert(bmprod01);
        
        //Quote 02
        BigMachines__Quote__c quote02 = new BigMachines__Quote__c();
        quote02.BigMachines__Site__c = 'a075000000A9iLJAAZ';
        quote02.RecordTypeId = recTypes.get(0).id;
        quote02.BigMachines__Account__c = acct01.id;
        quote02.BigMachines__Is_Primary__c = false;
        quote02.BigMachines__Opportunity__c = opportunityId;
        quote02.BigMachines__Status__c = 'preparation';
        quote02.BigMachines__Pricebook_Id__c = Test.getStandardPricebookId();
        Database.SaveResult resQuote02 = Database.insert(quote02);
        
        BigMachines__Quote_Product__c bmprod02 = addWonProduct(quote02.id,prod2.id);
        Database.saveresult resbmprod02 = Database.insert(bmprod02);
        
        //Quote 03
        BigMachines__Quote__c quote03 = new BigMachines__Quote__c();
        quote03.BigMachines__Site__c = 'a075000000A9iLJAAZ';
        quote03.RecordTypeId = recTypes.get(0).id;
        quote03.BigMachines__Account__c = acct01.id;
        quote03.BigMachines__Is_Primary__c = false;
        quote03.BigMachines__Opportunity__c = opportunityId;
        quote03.BigMachines__Status__c = 'preparation';
        quote03.BigMachines__Pricebook_Id__c = Test.getStandardPricebookId();
        Database.SaveResult resQuote03 = Database.insert(quote03);
        
        BigMachines__Quote_Product__c bmprod03 = addProduct(quote03.id,prod2.id);
        Database.saveresult resbmprod03 = Database.insert(bmprod03);        
        Test.stopTest();
        
        // asserts here
        System.assert(resQuote01.isSuccess());
        System.assert(resQuote02.isSuccess());
        System.assert(resQuote03.isSuccess());
        System.assert(resbmprod01.isSuccess());
        System.assert(resbmprod02.isSuccess());
        System.assert(resbmprod03.isSuccess());
        
        List<BigMachines__Quote__c> quoteList = [Select id, BigMachines__Total_Amount__c,
                                                 BigMachines__Account__c,BigMachines__Amount__c,BigMachines__Is_Primary__c,BigMachines__Line_Items__c,
                                                 BigMachines__Opportunity__c,BigMachines__Pricebook_Id__c,BigMachines__Status__c,
                                                 BigMachines__Total__c,IsDeleted,Name,Partial_Win_dollar_Amount2__c,
                                                 Partial_Win_Product_Dollars__c,Quote_Type__c,RecordTypeId,Transaction_Type__c
                                                 from BigMachines__Quote__c where BigMachines__Opportunity__c=:opportunityId];
        System.assertEquals(4, quoteList.size(),'Size: '+quoteList.size());
        
        
        List<Opportunity> oppList = [Select id, Original_Value__c, Amount from Opportunity where id=:opportunityId];
        System.assertEquals(1, oppList.size(), 'oppList size: '+oppList.size());
        
    }
    
    public static testmethod void testZeroOpportunity(){
        opportunityBmqTestData();
        
        Test.startTest();
        BigMachines__Quote_Product__c bmprod01 = addZeroProduct(bmq01.id,prod2.id);
        Database.saveresult resbmprod = Database.insert(bmprod01);
        Test.stopTest();
        
        System.assert(resbmprod.isSuccess());
    }
    
}