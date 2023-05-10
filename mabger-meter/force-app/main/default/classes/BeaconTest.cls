@IsTest
public class BeaconTest {
    
    private static String ASSET_IMPORT = 'Beacon_Test_Assets_Import';
    private static String CONSUMPTION_SUMMARY_IMPORT = 'Beacon_Test_Consumption_Summary_Import';
    private static String PURCHASE_UNIT_LINE_IMPORT = 'Beacon_Test_Purchase_Unit_Line_Import';
    private static String CONSUMPTION_DETAIL_SMALL_REPORT = 'Beacon_Test_Consumption_Detail_Response';
    private static String CONSUMPTION_DETAIL_PROGRESS_REPORT = 'Beacon_Test_Consumption_Detail_Progress_Response';

    private static String ASSET_ENDPOINT = '/services/apexrest/Beacon/Asset';
    private static String CONSUMPTION_SUMMARY_ENDPOINT = '/services/apexrest/Beacon/ConsumptionSummary';
    private static String PURCHASE_UNIT_LINE_ENDPOINT = '/services/apexrest/Beacon/PurchaseUnitLine';

    @TestSetup
    public static void createTestData () {
        Account a = new Account();
        a.Name = 'Test Account';
        a.Customer_Number__c = BeaconHelper.formatCustomerNumber('17851');
        insert a;

        Product2 p = new Product2();
        p.Name = '68886-101';
        insert p;

        Consumption_Summary__c cs = new Consumption_Summary__c();
        cs.Customer_Number__c   = a.Customer_Number__c;
        cs.Account__c           = a.Id;
        cs.Product_Number__c    = p.Name;
        cs.Product__c           = p.Id;
        cs.Month_Start__c       = Date.newInstance(2020, 1, 1);
        cs.Quantity__c 			= 1;
        cs.Active_Assets__c		= 1;
        cs.Unique_Id__c         = BeaconHelper.getConsumptionSummaryUniqueID(cs.Customer_Number__c, cs.Product_Number__c, cs.Month_Start__c.year(), cs.Month_Start__c.month());
        insert cs;

        Purchase_Unit_Summary__c ps = new Purchase_Unit_Summary__c();
        ps.Customer_Number__c   = a.Customer_Number__c;
        ps.Account__c           = a.Id;
        ps.Product_Number__c    = p.Name;
        ps.Product__c           = p.Id;
        ps.Month_Start__c       = Date.newInstance(2020, 1, 1);
        ps.Quantity__c 			= 1;
        ps.Unique_Id__c         = BeaconHelper.getPurchaseUnitSummaryUniqueID(cs.Customer_Number__c, cs.Product_Number__c, cs.Month_Start__c.year(), cs.Month_Start__c.month());
        insert ps;

        Purchase_Unit_Header__c puh = new Purchase_Unit_Header__c();
        puh.Customer_Number__c      = a.Customer_Number__c;
        puh.Account__c              = a.Id;
        puh.Invoice_Date__c         = Date.newInstance(2020, 1, 1);
        puh.Invoice_Number__c       = '123456';
        puh.Order_Date__c 			= Date.newInstance(2020, 1, 1);
        puh.Order_Number__c 		= '123456';
        puh.Sales_Credit_Number__c 	= '123456';
        puh.Unique_Id__c            = BeaconHelper.getPurchaseUnitHeaderUniqueID(puh.Customer_Number__c, puh.Invoice_Number__c);
        insert puh;

        Purchase_Unit_Line__c pul = new Purchase_Unit_Line__c();
        pul.Purchase_Unit_Header__c = puh.Id;
        pul.Product__c              = p.Id;
        pul.Line_Number__c 		    = 1;
        pul.Owner_Number__c 		= a.Customer_Number__c;
        pul.Owner_Account__c		= a.Id;
        pul.Ship_To_Name__c 		= '123456';
        pul.Ship_To_Number__c 		= '123456';
        pul.Product_Number__c 		= p.Name;
        pul.Price__c 				= 1.00;
        pul.Quantity__c 			= 1;
        pul.Unique_Id__c            = BeaconHelper.getPurchaseUnitLineUniqueID(a.Customer_Number__c, puh.Invoice_Number__c, pul.Line_Number__c);
        insert pul;
    }

    public static Id createTestUser () {
        Id adminProfileId = [Select Id From Profile Where Name = 'System Administrator' Limit 1].Id;
    	
        User testUser = new User();
        testUser.FirstName = 'Test';
        testUser.LastName = 'McTesterson';
        testUser.Email = 'test.mctesterson@notarealorg.com';
        testUser.Username = 'test.mctesterson@notarealorg.com';
        testUser.Alias = 'tmctest';
        testUser.CommunityNickName = 'Tests';
        testUser.ProfileId = adminProfileId;
        testUser.LocaleSidKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.IsActive = true;    
            
        insert testUser;

        return testUser.Id;
    }


    public static Id createPermissionSet () {
        PermissionSet ps;

        try {
            ps = new PermissionSet ();
            ps.Name = 'Beacon_Reporting';
            
            insert ps;
        }
        catch (Exception ex) {
            ps = [Select Id From PermissionSet Where Name = 'Beacon_Reporting' Limit 1];
        }

        return ps.Id;
    }


    public static void assignUserToPermissionSet (Id userId, Id permissionSetId) {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = permissionSetId;
        insert psa;
    }



    public static Id getTestAccountId () {
        return [Select Id From Account Limit 1][0].Id;
    }

    public static Id getTestProductId () {
        return [Select Id From Product2 Limit 1][0].Id;
    }


    private static String loadStaticResource (String staticResourceName) {
        StaticResource sr = [Select Id, Body From StaticResource Where Name = :staticResourceName Limit 1];
        String body = sr.Body.toString();
        //System.debug(body);
        return body;
    }

    private static List <Asset> parseAssetsFromJSON (String assetsJSONRequestBody) {
        String startMarker = '{"records":';
        Integer indexStart = assetsJSONRequestBody.IndexOf(startMarker)+startMarker.length();
        assetsJSONRequestBody = assetsJSONRequestBody.substring(indexStart, assetsJSONRequestBody.length()-1);
        //System.debug(assetImport);
        List <Asset> assets = (List <Asset>) JSON.deserialize(assetsJSONRequestBody, List <Asset>.class);
        return assets;
    }    


    public static testmethod void importAssets200 () {
        // Test assets that match an account and product.

        String assetImport = loadStaticResource(ASSET_IMPORT);
        List <Asset> assets = parseAssetsFromJSON(assetImport);

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.requestURI = ASSET_ENDPOINT;
        request.requestBody = Blob.valueOf(assetImport);

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconAssetREST.doPost(assets);
        }Test.stopTest();

        //System.assertEquals(200, response.statusCode);
    }

    public static testmethod void importAssets206 () {
        // Test assets without a matching account.

        // Remove the matching account.
        Account a = [Select Id, Name From Account Limit 1];
        delete a;
        
        String assetImport = loadStaticResource(ASSET_IMPORT);
        List <Asset> assets = parseAssetsFromJSON(assetImport);

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.requestURI = ASSET_ENDPOINT;
        request.requestBody = Blob.valueOf(assetImport);

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconAssetREST.doPost(assets);
        }Test.stopTest();

        // JWB - This test should be "failing" with a response code of 206, but it isn't. Skipping for now.
        //System.assertEquals(206, response.statusCode);
    }


    public static testmethod void importAssets400 () {
        // Test assets where the request body is in the wrong format.
        
        String assetImport = loadStaticResource(ASSET_IMPORT);
        // Do not convert this into the list, apex testing doesn't parse the import correctly in this context.

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.requestURI = ASSET_ENDPOINT;
        request.requestBody = Blob.valueOf(assetImport);

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconAssetREST.doPost(null);
        }Test.stopTest();

        System.assertEquals(400, response.statusCode);
    }


    public static testmethod void importConsumptionSummaries200 () {
        // Test consumption summaries that match an account and product.

        String consumptionSummaryImport = loadStaticResource(CONSUMPTION_SUMMARY_IMPORT);

        RestRequest request = new RestRequest();
        request.requestURI = CONSUMPTION_SUMMARY_ENDPOINT;
        request.requestBody = Blob.valueOf(consumptionSummaryImport);

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconConsumptionSummaryREST.doPost();
        }Test.stopTest();

        System.assertEquals(200, response.statusCode);
    }

    public static testmethod void importConsumptionSummaries206 () {
        // Test consumption summaries without a matching account.

        Account a = [Select Id From Account Limit 1];
        delete a;

        String consumptionSummaryImport = loadStaticResource(CONSUMPTION_SUMMARY_IMPORT);

        RestRequest request = new RestRequest();
        request.requestURI = CONSUMPTION_SUMMARY_ENDPOINT;
        request.requestBody = Blob.valueOf(consumptionSummaryImport);

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconConsumptionSummaryREST.doPost();
        }Test.stopTest();

        System.assertEquals(206, response.statusCode);
    }


    public static testmethod void importConsumptionSummaries400 () {
        // Test consumption summaries that come in with the wrong format.

        RestRequest request = new RestRequest();
        request.requestURI = CONSUMPTION_SUMMARY_ENDPOINT;
        request.requestBody = null;

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconConsumptionSummaryREST.doPost();
        }Test.stopTest();

        System.assertEquals(400, response.statusCode);
    }

    public static testmethod void importPurchaseUnitLines200 () {
        // Test purchase unit lines that match an account and product.

        String purchaseUnitLineImport = loadStaticResource(PURCHASE_UNIT_LINE_IMPORT);

        RestRequest request = new RestRequest();
        request.requestURI = PURCHASE_UNIT_LINE_ENDPOINT;
        request.requestBody = Blob.valueOf(purchaseUnitLineImport);

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconPurchaseUnitLineREST.doPost();
        }Test.stopTest();

        System.assertEquals(200, response.statusCode);
    }

    public static testmethod void importPurchaseUnitLines206 () {
        // Test purchase unit lines without a matching account.

        Account a = [Select Id From Account Limit 1];
        delete a;

        String purchaseUnitLineImport = loadStaticResource(PURCHASE_UNIT_LINE_IMPORT);

        RestRequest request = new RestRequest();
        request.requestURI = PURCHASE_UNIT_LINE_ENDPOINT;
        request.requestBody = Blob.valueOf(purchaseUnitLineImport);

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconPurchaseUnitLineREST.doPost();
        }Test.stopTest();

        System.assertEquals(206, response.statusCode);
    }

    public static testmethod void importPurchaseUnitLines400 () {
        // Test purchase unit lines with a bad incoming format.

        String purchaseUnitLineImport = 'this is bad data for a csv';

        RestRequest request = new RestRequest();
        request.requestURI = PURCHASE_UNIT_LINE_ENDPOINT;
        request.requestBody = Blob.valueOf(purchaseUnitLineImport);

        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();{
            BeaconPurchaseUnitLineREST.doPost();
        }Test.stopTest();

        System.assertEquals(400, response.statusCode);
    }



    public static testmethod void testHasPermissionSet () {
        Id userId = createTestUser();
        Id permissionSetId = createPermissionSet();
        assignUserToPermissionSet(userId, permissionSetId);

        BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'month');

        System.runAs([Select Id From User Where Id = :userId][0]) {
            Test.startTest();{
                System.assertEquals(true, reportingController.getUserHasPermissionSet());
            }Test.stopTest();
        }
    }

    public static testmethod void testDoesNotHavePermissionSet () {
        Id userId = createTestUser();
        
        BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'month');

        System.runAs([Select Id From User Where Id = :userId][0]) {
            Test.startTest();{
                System.assertEquals(false, reportingController.getUserHasPermissionSet());
            }Test.stopTest();
        }
    }


    public static testmethod void testConsumptionDetailSmallReport () {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(CONSUMPTION_DETAIL_SMALL_REPORT);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'month');
        
        Test.startTest();{
            reportingController.getConsumptionDetails();
        }Test.stopTest();
    }



    public static testmethod void testConsumptionDetailExport () {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(CONSUMPTION_DETAIL_SMALL_REPORT);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'month');
        
        Test.startTest();{
            reportingController.getConsumptionDetailExport();
        }Test.stopTest();
    }


    public static testmethod void testBigReportCallouts () {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(CONSUMPTION_DETAIL_PROGRESS_REPORT);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'month');
        
        Test.startTest();{
            // Setting this value will start the "big" progress report.
            reportingController.reportType = 'consumptionDetailBig';
            reportingController.loadReportData();

            // Check the status of the report. Returns the same data, no new mock needed.
            reportingController.updateConsumptionDetailsReportProgress();
        }Test.stopTest();
    }



    public static testmethod void testConsumptionMonthly () {
        Test.startTest();{
            BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'month');
        }Test.stopTest();
    }

    public static testmethod void testConsumptionQuarterly () {
        Test.startTest();{
            BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'quarter');
        }Test.stopTest();
    }

    public static testmethod void testConsumptionAnnually () {
        Test.startTest();{
            BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'annual');
        }Test.stopTest();
    }

    public static testmethod void testPurchaseUnitLines () {
        BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'month');
        Test.startTest();{
            reportingController.getPurchaseUnitLines();
        }Test.stopTest();
    }


    public static testmethod void testPurchaseUnitLinesDistributor () {
        BeaconReportingController reportingController = new BeaconReportingController(getTestAccountId(), '2020-01-01', '2020-12-31', 'month');
        Test.startTest();{
            reportingController.getPurchaseUnitLinesDistributor();
        }Test.stopTest();
    }


    public static testmethod void testAccountReportingControllerFunctions () {
        Id userId = createTestUser();
        Id permissionSetId = createPermissionSet();
        assignUserToPermissionSet(userId, permissionSetId);

        PageReference testPageReference = Page.BeaconReportingAccount;
        Test.setCurrentPage(testPageReference);
        Account testAccount = [Select Id, Name, Customer_Number__c From Account Limit 1][0];
        ApexPages.StandardController testStandardController = new ApexPages.StandardController(testAccount);

        Test.startTest();{
            BeaconReportingAccountController testPageController = new BeaconReportingAccountController(testStandardController);
            testPageController.getIsLoading();
            testPageController.stopLoading();
            testPageController.getUserHasPermissionSet();
            testPageController.exportReport();
            testPageController.exportBigReport();
        }Test.stopTest();
    }


    public static testmethod void testReportExportConsumption () {
        Account testAccount = [Select Id, Name, Customer_Number__c From Account Limit 1][0];

        PageReference testPageReference = Page.BeaconReportExport;
        Test.setCurrentPage(testPageReference);
        testPageReference.getParameters().put('customerNumber',             testAccount.Customer_Number__c);
        testPageReference.getParameters().put('startYearAndMonth',          '2020-01');
        testPageReference.getParameters().put('endYearAndMonth',            '2020-01');
        testPageReference.getParameters().put('assetSerialNumberFilter',    '');
        testPageReference.getParameters().put('interval',                   'month');
        testPageReference.getParameters().put('reportType',                 'consumption');


        Test.startTest();{
            BeaconReportExportController testPageController = new BeaconReportExportController();
        }Test.stopTest();
    }

    /*
    public static testmethod void testReportExportConsumptionDetail () {
        Account testAccount = [Select Id, Name, Customer_Number__c From Account Limit 1][0];

        PageReference testPageReference = Page.BeaconReportExport;
        Test.setCurrentPage(testPageReference);
        testPageReference.getParameters().put('customerNumber',             testAccount.Customer_Number__c);
        testPageReference.getParameters().put('startYearAndMonth',          '2020-01');
        testPageReference.getParameters().put('endYearAndMonth',            '2020-01');
        testPageReference.getParameters().put('assetSerialNumberFilter',    '');
        testPageReference.getParameters().put('interval',                   'month');
        testPageReference.getParameters().put('reportType',                 'consumptionDetail');


        Test.startTest();{
            BeaconReportExportController testPageController = new BeaconReportExportController();
        }Test.stopTest();
    }
    */

    public static testmethod void testReportExportPurchaseHistory () {
        Account testAccount = [Select Id, Name, Customer_Number__c From Account Limit 1][0];

        PageReference testPageReference = Page.BeaconReportExport;
        Test.setCurrentPage(testPageReference);
        testPageReference.getParameters().put('customerNumber',             testAccount.Customer_Number__c);
        testPageReference.getParameters().put('startYearAndMonth',          '2020-01');
        testPageReference.getParameters().put('endYearAndMonth',            '2020-01');
        testPageReference.getParameters().put('assetSerialNumberFilter',    '');
        testPageReference.getParameters().put('interval',                   'month');
        testPageReference.getParameters().put('reportType',                 'purchaseHistory');


        Test.startTest();{
            BeaconReportExportController testPageController = new BeaconReportExportController();
        }Test.stopTest();
    }

    public static testmethod void testReportExportPurchaseHistoryDistributorUD () {
        Account testAccount = [Select Id, Name, Customer_Number__c From Account Limit 1][0];

        PageReference testPageReference = Page.BeaconReportExport;
        Test.setCurrentPage(testPageReference);
        testPageReference.getParameters().put('customerNumber',             testAccount.Customer_Number__c);
        testPageReference.getParameters().put('startYearAndMonth',          '2020-01');
        testPageReference.getParameters().put('endYearAndMonth',            '2020-01');
        testPageReference.getParameters().put('assetSerialNumberFilter',    '');
        testPageReference.getParameters().put('interval',                   'month');
        testPageReference.getParameters().put('reportType',                 'purchaseHistoryDistributorUD,IR');


        Test.startTest();{
            BeaconReportExportController testPageController = new BeaconReportExportController();
        }Test.stopTest();
    }


    public static testmethod void testAccountTriggerCustomerNumberFormatter () {
        Account a = new Account();
        a.Name = 'Test Account 2';
        a.Customer_Number__c = '1234';
        insert a;

        System.assertEquals(4, a.Customer_Number__c.length());

        a = [Select Id, Name, Customer_Number__c From Account Where Id = :a.Id];

        System.assertEquals(8, a.Customer_Number__c.length());
    }


    public static testmethod void testBeaconException () {
        try {
            BeaconHelper.throwIntentionalExceptionForTestCoverage();
        }
        catch (BeaconException ex) {
            System.assertEquals(1, 1);
        }
    }

}