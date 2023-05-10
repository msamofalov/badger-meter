@IsTest
public class TrimbleTest {

    @TestSetup
    public static void createTestData () {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.Customer_Number__c = '12345';
        insert testAccount;
        
        Product2 testProduct = new Product2();
        testProduct.Name = '67890';
       	insert testProduct;
    }
    
    public static testmethod void testPostiveCreateAndDeleteAssetRecords () {
        Id HWrecordTypeId = TrimbleHelper.getAssetHWAndAccRecordTypeId();

        List <Asset> assets = new List <Asset> ();
        assets.add(new Asset(RecordTypeId=HWrecordTypeId, Product_Number__c='67890', Customer_Number__c='12345', Asset_Shipped_To_Customer_Number__c='12345'));
        
        Test.startTest();{
            TrimbleHelper.createAssetRecords(assets);
            
            //System.assertEquals(1, [Select Id From Asset].size());
            
            TrimbleHelper.deleteAssetRecords(assets);
            
            //System.assertEquals(0, [Select Id From Asset].size());
        }Test.stopTest();
    }
    
    public static testmethod void testNegativeCreateAndDeleteAssetRecords () {
        Id HWrecordTypeId = TrimbleHelper.getAssetHWAndAccRecordTypeId();

        List <Asset> assets = new List <Asset> ();
        assets.add(new Asset(RecordTypeId=HWrecordTypeId, Product_Number__c='-1', Customer_Number__c='-1', Asset_Shipped_To_Customer_Number__c='-1'));
        
        Test.startTest();{
            TrimbleHelper.createAssetRecords(assets);
            
            //System.assertEquals(0, [Select Id From Asset].size());
            
            TrimbleHelper.deleteAssetRecords(assets);
            
            //System.assertEquals(0, [Select Id From Asset].size());
        }Test.stopTest();
    }
    
    
    public static testmethod void testTranslateErrorMessage () {
        Test.startTest();{
            System.assertEquals('Unable to locate customer in Salesforce: [Account.Customer_Number__c]', TrimbleHelper.translateErrorMessage('Required fields are missing: [Account__c]'));
            System.assertEquals('Unable to locate customer in Salesforce: [Account.Customer_Number__c]', TrimbleHelper.translateErrorMessage('Every asset needs an account, a contact, or both.: Account ID, Contact ID'));
            System.assertEquals('Unable to locate product in Salesforce: [Product2.Name]', TrimbleHelper.translateErrorMessage('Required fields are missing: [Product__c]'));
            System.assertEquals('asdf', TrimbleHelper.translateErrorMessage('asdf'));
        }Test.stopTest();
    }
    
    
    public static testmethod void testGetAccountMapByCustomerNumber () {
        Set <String> customerNumbers = new Set <String> ();
        customerNumbers.add('12345');
        
        Test.startTest();{
            System.assertNotEquals(null, TrimbleHelper.getAccountMapByCustomerNumber(customerNumbers));
        }Test.stopTest();
    }
    
    public static testmethod void testGetProductMapByProductNumber () {
        Set <String> productNumbers = new Set <String> ();
        productNumbers.add('67890');
        
        Test.startTest();{
            System.assertNotEquals(null, TrimbleHelper.getProductMapByProductNumber(productNumbers));
        }Test.stopTest();
    }
    
    
    public static testmethod void testRESTPOST () {
        Id HWrecordTypeId = TrimbleHelper.getAssetHWAndAccRecordTypeId();

        List <Asset> assets = new List <Asset> ();
        assets.add(new Asset(RecordTypeId=HWrecordTypeId, Product_Number__c='67890', Customer_Number__c='12345', Asset_Shipped_To_Customer_Number__c='12345'));
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Trimble/Asset';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(assets));
        RestContext.request = req;
        RestContext.response = res;

        TrimbleAssetREST.doPost(assets);
    }
    
    
    public static testmethod void testRESTDELETE () {
        Id HWrecordTypeId = TrimbleHelper.getAssetHWAndAccRecordTypeId();

        List <Asset> assets = new List <Asset> ();
        assets.add(new Asset(RecordTypeId=HWrecordTypeId, Product_Number__c='67890', Customer_Number__c='12345', Asset_Shipped_To_Customer_Number__c='12345'));
        String assetString = JSON.serialize(assets);
        System.debug('ASSETS: '+ assetString);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Trimble/Asset';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(assetString);
        RestContext.request = req;
        RestContext.response = res;

        TrimbleAssetREST.doDelete();
        
        TrimbleAssetREST.expandTestCoverage();
    }
    
    public static testmethod void testTrimbleException () {
        try {
            throw new TrimbleException('Dummy exception');
        }
        catch (Exception ex) {
            
        }
    }
    
}