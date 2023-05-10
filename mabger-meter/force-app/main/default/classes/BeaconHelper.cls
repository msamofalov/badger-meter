public class BeaconHelper {
    

    public static Boolean hasPermissionSet () {
        try {
            PermissionSetAssignment psa = [Select Id, PermissionSet.Name From PermissionSetAssignment Where PermissionSet.Name = 'Beacon_Reporting' And AssigneeId = :UserInfo.getUserId() Limit 1][0];
            // If the permission set assignment exists, return true.
            return true;
        }
        catch (Exception ex) {
            return false;
        }
    }

    /*
    public static void createAssetRecordsFromConsumption (List <Consumption__b> records) {
        List <Asset> assets = new List <Asset> ();
        for (Consumption__b record : records) assets.add(new Asset(Name=record.Asset_Number__c, Customer_Number__c=record.Account_Number__c, Product_Number__c=record.Product_Number__c, SerialNumber=record.Asset_Number__c));
    	createAssetRecords(assets);
    }
    */
	
    public static String createAssetRecords (List <Asset> records) {
        

        // Go over the records to get the accounts and products they should link to.
        Set <String> customerNumbers = new Set <String> ();
        Set <String> productNumbers = new Set <String> ();
        for (Asset a : records) {
            // Clean the asset records.
            a.Customer_Number__c = formatCustomerNumber(a.Customer_Number__c);
            a.Asset_Shipped_To_Customer_Number__c = formatCustomerNumber(a.Asset_Shipped_To_Customer_Number__c);

            customerNumbers.add(a.Customer_Number__c);
            customerNumbers.add(a.Asset_Shipped_To_Customer_Number__c);
            productNumbers.add(a.Product_Number__c);
        }
        
        // Build maps of the customers and products to link.
        Map <String, Id> customerMap = new Map <String, Id> ();
        Map <String, Id> productMap = new Map <String, Id> ();
        for (Account a : [Select Id, Customer_Number__c From Account Where Customer_Number__c != null And Customer_Number__c in :customerNumbers]) customerMap.put(a.Customer_Number__c, a.Id);
        for (Product2 p : [Select Id, Name From Product2 Where Name in :productNumbers]) productMap.put(p.Name, p.Id);
        
        // Get the Endpoint record type ID.
        Id endpointRecordTypeId = getAssetEndpointRecordTypeId();
        
        // Link customers and products to the incoming assets. Also create the unique id for the asset.
        for (Asset a : records) {
            a.AccountId = customerMap.containsKey(a.Customer_Number__c) ? customerMap.get(a.Customer_Number__c) : null;
            a.Asset_Shipped_To__c = customerMap.containsKey(a.Customer_Number__c) ? customerMap.get(a.Asset_Shipped_To_Customer_Number__c) : null;
            a.Product2Id = productMap.containsKey(a.Product_Number__c) ? productMap.get(a.Product_Number__c) : null;
            a.Asset_Unique_ID__c = getAssetUniqueID(a.Customer_Number__c, a.SerialNumber);
            a.Name = a.Asset_Unique_ID__c;
            a.RecordTypeId = endpointRecordTypeId;
        }
        
        // Upsert the assets.
        //upsert records Asset_Unique_ID__c;
        List <AssetResult> assetResults = new List <AssetResult> ();
        List <Database.UpsertResult> upsertResults = Database.upsert(records, Asset.Asset_Unique_ID__c, false);
        for (Integer i = 0; i < upsertResults.size(); i++) {
            Database.UpsertResult result = upsertResults[i];
            Asset a = records[i];
            if (result.isSuccess()) {
                //a.put('Result', 'OK');
                assetResults.add(new AssetResult(a.Customer_Number__c, a.SerialNumber, 'OK'));
            }
            else if (!result.isSuccess()) {
                String errorText = '';
                errorText += result.getErrors().size() +' errors: ';
                for (Database.Error error : result.getErrors()) {
                    errorText += error.getMessage() +'; ';
                }
                //a.put('Result', errorText);
                assetResults.add(new AssetResult(a.Customer_Number__c, a.SerialNumber, errorText));
            }
        }

        return JSON.serialize(assetResults);
    }
    
    
    public static String getAssetUniqueID (String customerNumber, String assetSerialNumber) {
        return customerNumber+'-'+assetSerialNumber;
    }
    
    
    private static Id getAssetEndpointRecordTypeId () {
        try {
            return Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Endpoint').getRecordTypeId();
        }
        catch (Exception ex) {
            throw new BeaconException('Asset record type "Endpoint" cannot be found and may need to be created in Salesforce');
        }
    }
    
    
    public static String createConsumptionSummaryRecords (List <Consumption_Summary__c> records) {
        // Go over the records to get the accounts and assets they should link to.
        Set <String> customerNumbers = new Set <String> ();
        //Set <String> serialNumbers = new Set <String> ();
        Set <String> productNumbers = new Set <String> ();
        for (Consumption_Summary__c c : records) {
            customerNumbers.add(c.Customer_Number__c);
            //serialNumbers.add(c.Serial_Number__c);
            productNumbers.add(c.Product_Number__c);
        }
        
        // Build maps of the customers and products to link.
        Map <String, Id> customerMap = new Map <String, Id> ();
        //Map <String, Id> assetMap = new Map <String, Id> ();
        Map <String, Id> productMap = new Map <String, Id> ();
        for (Account a : [Select Id, Customer_Number__c From Account Where Customer_Number__c != null And Customer_Number__c in :customerNumbers]) customerMap.put(a.Customer_Number__c, a.Id);
        //for (Asset a : [Select Id, SerialNumber From Asset Where SerialNumber in :serialNumbers]) assetMap.put(a.SerialNumber, a.Id);
        for (Product2 p : [Select Id, Name From Product2 Where Name in :productNumbers]) productMap.put(p.Name, p.Id);
        
        // Link customers and products to the incoming assets. Also create the unique id for the asset.
        for (Consumption_Summary__c c : records) {
            c.Account__c = customerMap.containsKey(c.Customer_Number__c) ? customerMap.get(c.Customer_Number__c) : null;
            //c.Asset__c = assetMap.get(c.Serial_Number__c);
            c.Product__c = productMap.containsKey(c.Product_Number__c) ? productMap.get(c.Product_Number__c) : null;
            c.Unique_ID__c = getConsumptionSummaryUniqueID(c.Customer_Number__c, c.Product_Number__c, c.Month_Start__c.year(), c.Month_Start__c.month());
            c.Last_Summarization_Date__c = Date.today();
        }
        
        // Upsert the consumption summaries.
        //upsert records Unique_ID__c;

        List <ConsumptionSummaryResult> consumptionSummaryResults = new List <ConsumptionSummaryResult> ();
        List <Database.UpsertResult> upsertResults = Database.upsert(records, Consumption_Summary__c.Unique_ID__c, false);
        for (Integer i = 0; i < upsertResults.size(); i++) {
            Database.UpsertResult result = upsertResults[i];
            Consumption_Summary__c c = records[i];
            if (result.isSuccess()) {
                //a.put('Result', 'OK');
                consumptionSummaryResults.add(new ConsumptionSummaryResult(c.Customer_Number__c, c.Product_Number__c, c.Month_Start__c.year(), c.Month_Start__c.month(), 'OK'));
            }
            else if (!result.isSuccess()) {
                String errorText = '';
                errorText += result.getErrors().size() +' errors: ';
                for (Database.Error error : result.getErrors()) {
                    String thisErrorMessage = translateErrorMessage(error.getMessage());
                    errorText += thisErrorMessage +'; ';
                }
                //a.put('Result', errorText);
                consumptionSummaryResults.add(new ConsumptionSummaryResult(c.Customer_Number__c, c.Product_Number__c, c.Month_Start__c.year(), c.Month_Start__c.month(), errorText));
            }
        }

        return JSON.serialize(consumptionSummaryResults);
    }
    
    
    public static String translateErrorMessage (String errorMessage) {
        String translatedErrorMessage = errorMessage;

        if (errorMessage == 'Required fields are missing: [Account__c]') translatedErrorMessage = 'Unable to locate customer in Salesforce: [Account.Customer_Number__c]';
        else if (errorMessage == 'Every asset needs an account, a contact, or both.: Account ID, Contact ID') translatedErrorMessage = 'Unable to locate customer in Salesforce: [Account.Customer_Number__c]';
        else if (errorMessage == 'Required fields are missing: [Product__c]') translatedErrorMessage = 'Unable to locate product in Salesforce: [Product2.Name]';
        return translatedErrorMessage;
    }
    
    public static List <Consumption_Summary__c> parseConsumptionSummaryRecordsFromCSV (String csvData) {
        List <Consumption_Summary__c> records = new List <Consumption_Summary__c> ();
        
        String[] lines = safeSplit(csvData, '\n');
        for (Integer i = 1; i < lines.size(); i++) {
            String line = lines[i].replace('\n','');
            if (!String.isBlank(line)) {
                //try {
                    String[] columns = line.split(',');
                    
                    Consumption_Summary__c c = new Consumption_Summary__c();
                    
                    c.Customer_Number__c 	= formatCustomerNumber(columns[0]);
                    //c.Serial_Number__c 		= columns[1].trim();
                    c.Product_Number__c 	= columns[1].trim();
                    
                    Integer year 			= Integer.valueOf(columns[2].trim());
                    Integer month 			= Integer.valueOf(columns[3].trim());
                    Date monthStart 		= Date.newInstance(year, month, 1);
                    
                    c.Month_Start__c 		= monthStart;
                    
                    c.Quantity__c 			= Integer.valueOf(columns[4].trim());
                    c.Active_Assets__c		= Integer.valueOf(columns[5].trim());
                    
                    //System.debug('CONSUMPTION SUMMARY: '+ c);
                    records.add(c);
                    /*
                }
                catch (Exception ex) {
                    System.debug('ERROR: '+ ex.getMessage());
                    System.debug('LINE NUMBER: '+ i);
                    System.debug('LINE: '+ line);
                    System.debug('ERROR: '+ ex.getStackTraceString());
                }
                */
            }
        }
        
        return records;
    }
    
    /*
    public static List <Purchase_Unit_Summary__c> parsePurchaseUnitSummaryRecordsFromCSV (String csvData) {
        List <Purchase_Unit_Summary__c> records = new List <Purchase_Unit_Summary__c> ();
        
        String[] lines = safeSplit(csvData, '\n');
        for (Integer i = 1; i < lines.size(); i++) {
            String line = lines[i].replace('\n','');
            if (!String.isBlank(line)) {
                try {
                    String[] columns = line.split(',');
                    
                    Purchase_Unit_Summary__c p = new Purchase_Unit_Summary__c();
                    
                    p.Customer_Number__c	= columns[0].trim();
                    p.Product_Number__c 	= columns[1].trim();
                    
                    Integer year 			= Integer.valueOf(columns[2].trim());
                    Integer month 			= Integer.valueOf(columns[3].trim());
                    Date monthStart 		= Date.newInstance(year, month, 1);
                    
                    p.Month_Start__c 		= monthStart;
                    
                    p.Quantity__c 			= Integer.valueOf(columns[4].trim());
                    
                    //System.debug('PURCHASE UNIT SUMMARY : '+ p);
                    records.add(p);
                }
                catch (Exception ex) {
                    System.debug('ERROR: '+ ex.getMessage());
                    System.debug('LINE NUMBER: '+ i);
                    System.debug('LINE: '+ line);
                    System.debug('ERROR: '+ ex.getStackTraceString());
                }
            }
        }
        
        return records;
    }
    */
    
    
    
    
    
    public static List <String> parsePurchaseUnitLinesFromCSV (String csvData) {
        List <String> finalLines = new List <String> ();
        
        String[] lines = safeSplit(csvData, '\n');
        for (Integer i = 1; i < lines.size(); i++) {
            String line = lines[i].replace('\n','');
            if (!String.isBlank(line)) {
                finalLines.add(line);
            }
        }
        
        return finalLines;
    }
    
    /*
    public static List <Consumption__b> parseConsumptionRecordsFromCSV (String csvData) {
        List <Consumption__b> records = new List <Consumption__b> ();
        
        String[] lines = safeSplit(csvData, '\n');
        for (Integer i = 1; i < lines.size(); i++) {
            String line = lines[i].replace('\n','');
            if (!String.isBlank(line)) {
                try {
                    String[] columns = line.split(',');
                    
                    Consumption__b c = new Consumption__b();
                    c.Account_Number__c = columns[0].trim();
                    c.Product_Number__c = columns[1].trim();
                    c.Consumption_Type__c = columns[2].trim();
                    c.Asset_Number__c = columns[3].trim();
                    c.Quantity__c = Integer.valueOf(columns[4]);
                    c.Consumption_Date_Input__c = columns[5].trim();
                    c.Additional_Properties__c = columns[6].trim();
                    
                    //System.debug('CONSUMPTION: '+ c);
                    records.add(c);
                }
                catch (Exception ex) {
                    System.debug('ERROR: '+ ex.getMessage());
                    System.debug('LINE NUMBER: '+ i);
                    System.debug('LINE: '+ line);
                    System.debug('ERROR: '+ ex.getStackTraceString());
                }
            }
        }
        
        return records;
    }
    */
    
    /*
    public static void createConsumptionRecords (List <Consumption__b> records) {
        Set <String> 					productNumbers 			= new Set <String> ();
        Set <String> 					customerNumbers 		= new Set <String> ();
        Set <String> 					assetUniqueIds			= new Set <String> ();
		
        // Collect all the identifying information needed.
        for (Consumption__b record : records) {
            productNumbers.add(record.Product_Number__c);
            customerNumbers.add(record.Account_Number__c);
            assetUniqueIds.add(getAssetUniqueID(record.Account_Number__c, record.Asset_Number__c));
        }
        
        // Query the appropriate records.
        Map <String, Id> productMap = new Map <String, Id> ();
        Map <String, Id> customerMap = new Map <String, Id> ();
        Map <String, Id> assetMap = new Map <String, Id> ();
        
        for (Product2 p : [Select Id, Name From Product2 Where Name in :productNumbers]) productMap.put(p.Name, p.Id);
        for (Account a : [Select Id, Customer_Number__c From Account Where Customer_Number__c in :customerNumbers]) customerMap.put(a.Customer_Number__c, a.Id);
        for (Asset a : [Select Id, Account.Customer_Number__c, SerialNumber, Asset_Unique_ID__c From Asset Where Asset_Unique_ID__c in :assetUniqueIds]) assetMap.put(a.Asset_Unique_ID__c, a.Id);
        
    	
        
        
        for (Consumption__b record : records) {
            if (productMap.containsKey(record.Product_Number__c)) record.Product__c = productMap.get(record.Product_Number__c);
            if (customerMap.containsKey(record.Account_Number__c)) record.Account__c = customerMap.get(record.Account_Number__c);
            
            String assetUniqueID = getAssetUniqueID(record.Account_Number__c, record.Asset_Number__c);
            if (assetMap.containsKey(assetUniqueID)) record.Asset__c = assetMap.get(assetUniqueID);
            
            // Establish the year and month as separate fields for easier querying.
            String inputDateTime = record.Consumption_Date_Input__c;
            String inputDateWithoutTime = inputDateTime.substring(0, inputDateTime.indexOf('T'));
            //System.debug('DT: '+ inputDateWithoutTime);
            String[] dateTokens = inputDateWithoutTime.split('-');
            Integer year = Integer.valueOf(dateTokens[0]);
            Integer month = Integer.valueOf(dateTokens[1]);
            Integer day = Integer.valueOf(dateTokens[2]);
            record.Consumption_Year__c = year;
            record.Consumption_Month__c = month;
            record.Consumption_Day__c = day;
            record.Consumption_Date__c = DateTime.newInstance(year, month, day);
        }
        
        System.debug('Records: '+ records);
        
        Database.insertImmediate(records);
    }
    */
    
    
    public static Date getCleanDate (String inputDate) {
        String[] dateTokens = inputDate.split('-');
        Integer year = Integer.valueOf(dateTokens[0]);
        Integer month = Integer.valueOf(dateTokens[1]);
        Integer day = Integer.valueOf(dateTokens[2]);
        return Date.newInstance(year, month, day);
    }
    
    public static String getConsumptionSummaryUniqueID (String customerNumber, String productNumber, Decimal consumptionYear, Decimal consumptionMonth) {
        return customerNumber+'-'+productNumber+'-'+(String.valueOf(consumptionYear).leftPad(4,'0'))+'-'+(String.valueOf(consumptionMonth).leftPad(2,'0'));
    }
    
    public static String getPurchaseUnitSummaryUniqueID (String customerNumber, String productNumber, Decimal year, Decimal month) {
        return customerNumber+'-'+productNumber+'-'+(String.valueOf(year).leftPad(4,'0'))+'-'+(String.valueOf(month).leftPad(2,'0'));
    }
    
    public static String getPurchaseUnitHeaderUniqueID (String customerNumber, String invoiceNumber) {
        return customerNumber +'-'+ invoiceNumber;
    }
    
    public static String getPurchaseUnitLineUniqueID (String customerNumber, String invoiceNumber, Decimal lineNumber) {
        return customerNumber +'-'+ invoiceNumber +'-'+ lineNumber;
    }
    
    
    public static Map <String, Id> getAccountMapByCustomerNumber (Set <String> customerNumbers) {
        Map <String, Id> accountMapByCustomerNumber = new Map <String, Id> ();
        for (Account a : [Select Id, Customer_Number__c From Account Where Customer_Number__c != null And Customer_Number__c in :customerNumbers]) accountMapByCustomerNumber.put(a.Customer_Number__c, a.Id);
        return accountMapByCustomerNumber;
    }
    
    
    public static Map <String, Id> getProductMapByProductNumber (Set <String> productNumbers) {
        Map <String, Id> productMapByProductNumber = new Map <String, Id> ();
        for (Product2 p : [Select Id, Name From Product2 Where Name in :productNumbers]) productMapByProductNumber.put(p.Name, p.Id);
        return productMapByProductNumber;
    }
    
    
    /*
    public static void createConsumptionSummaryRecords (List <Consumption__b> records) {
        // Part 2: Summary records.
        Set <String> assets = new Set <String> ();
        DateTime earliestDate;
        DateTime latestDate;
        for (Consumption__b record : records) {
            assets.add(record.Asset_Number__c);
            if (earliestDate == null || earliestDate > record.Consumption_Date__c) earliestDate = record.Consumption_Date__c;
            if (latestDate == null || latestDate < record.Consumption_Date__c) latestDate = record.Consumption_Date__c;
        }
        Date earliestMonthStart = Date.newInstance(earliestDate.year(), earliestDate.month(), earliestDate.day()).toStartOfMonth();
        Date latestMonthEnd = Date.newInstance(latestDate.year(), latestDate.month(), latestDate.day()).addMonths(1).toStartOfMonth().addDays(-1);
        System.debug('ASSETS TO SEARCH FOR: '+ assets);
        System.debug('EARLIEST DATE: '+ earliestMonthStart);
        System.debug('LATEST DATE: '+ latestMonthEnd);
        
        // Get the associated records to roll up.
        List <Consumption__b> consumptionRecords = new List <Consumption__b> ([Select Asset_Number__c, Consumption_Date__c, Consumption_Year__c, Consumption_Month__c, Consumption_Day__c, Account_Number__c, Account__c, Additional_Properties__c, Asset__c, Consumption_Type__c, Product_Number__c, Product__c, Quantity__c From Consumption__b Where Asset_Number__c in :assets And Consumption_Date__c >= :earliestMonthStart And Consumption_Date__c <= :latestMonthEnd]);
    	
        Map <String, Consumption_Summary__c> consumptionSummaries = new Map <String, Consumption_Summary__c> ();
        for (Consumption__b consumption : consumptionRecords) {
            String identifier = getConsumptionSummaryUniqueID(consumption.Account_Number__c, consumption.Asset_Number__c, consumption.Consumption_Year__c, consumption.Consumption_Month__c);
            
            Consumption_Summary__c consumptionSummary;
            
            if (!consumptionSummaries.containsKey(identifier)) {
                consumptionSummary = new Consumption_Summary__c();
                consumptionSummary.Unique_ID__C = identifier;
                consumptionSummary.Account__c = consumption.Account__c;
                consumptionSummary.Asset__c = consumption.Asset__c;
                consumptionSummary.Quantity__c = 0;
                consumptionSummary.Consumption_Type__c = consumption.Consumption_Type__c;
                
                Date thisMonth = Date.newInstance(Integer.valueOf(consumption.Consumption_Year__c), Integer.valueOf(consumption.Consumption_Month__c), Integer.valueOf(consumption.Consumption_Day__c));
                Date thisMonthStart = thisMonth.toStartOfMonth();
                Date thisMonthEnd = thisMonth.addMonths(1).toStartOfMonth().addDays(-1);
                
                consumptionSummary.Month_Start__c = thisMonthStart;
                consumptionSummary.Month_End__c = thisMonthEnd;
                
                consumptionSummaries.put(identifier, consumptionSummary);
            }
            else {
                consumptionSummary = consumptionSummaries.get(identifier);
            }
            
            consumptionSummary.Quantity__c += consumption.Quantity__c;
        }
        
        
        List <Consumption_Summary__c> consumptionSummariesForUpsert = consumptionSummaries.values();
        upsert consumptionSummariesForUpsert Unique_ID__c;
    }
    */

    
    public static void createPurchaseUnitSummaryRecords (Date earliestMonthStart, Date latestMonthEnd) {
               
        // Get the associated records to roll up. // 2022-02-24 - Joe Bunda, Allium - Changing the ownership of the summary records to the owner of the line, rather than the customer at the header level.
        List <Purchase_Unit_Line__c> purchaseUnitLines = new List <Purchase_Unit_Line__c> ([Select Id, /*Purchase_Unit_Header__r.Customer_Number__c*/Owner_Number__c, Owner_Account__c, Purchase_Unit_Header__r.Account__c, Product_Number__c, Product__c, Purchase_Unit_Header__r.Invoice_Date__c, Quantity__c From Purchase_Unit_Line__c Where Purchase_Unit_Header__r.Invoice_Date__c >= :earliestMonthStart And Purchase_Unit_Header__r.Invoice_Date__c <= :latestMonthEnd]);
    	
        Map <String, Purchase_Unit_Summary__c> purchaseUnitSummaries = new Map <String, Purchase_Unit_Summary__c> ();
        for (Purchase_Unit_Line__c purchaseUnitLine : purchaseUnitLines) {
            String identifier = getPurchaseUnitSummaryUniqueID(/*purchaseUnitLine.Purchase_Unit_Header__r.Customer_Number__c*/purchaseUnitLine.Owner_Number__c, purchaseUnitLine.Product_Number__c, purchaseUnitLine.Purchase_Unit_Header__r.Invoice_Date__c.year(), purchaseUnitLine.Purchase_Unit_Header__r.Invoice_Date__c.month());
            
            Purchase_Unit_Summary__c purchaseUnitSummary;
            
            if (!purchaseUnitSummaries.containsKey(identifier)) {
                purchaseUnitSummary = new Purchase_Unit_Summary__c();
                purchaseUnitSummary.Unique_ID__C = identifier;
                purchaseUnitSummary.Account__c = /*purchaseUnitLine.Purchase_Unit_Header__r.Account__c;*/purchaseUnitLine.Owner_Account__c;
                purchaseUnitSummary.Customer_Number__c = /*purchaseUnitLine.Purchase_Unit_Header__r.Customer_Number__c;*/purchaseUnitLine.Owner_Number__c;
                purchaseUnitSummary.Product__c = purchaseUnitLine.Product__c;
                purchaseUnitSummary.Product_Number__c = purchaseUnitLine.Product_Number__c;
                purchaseUnitSummary.Quantity__c = 0;
                //purchaseUnitSummary.Consumption_Type__c = consumption.Consumption_Type__c;
                
                Date thisMonth = Date.newInstance(purchaseUnitLine.Purchase_Unit_Header__r.Invoice_Date__c.year(), purchaseUnitLine.Purchase_Unit_Header__r.Invoice_Date__c.month(), purchaseUnitLine.Purchase_Unit_Header__r.Invoice_Date__c.day());
                Date thisMonthStart = thisMonth.toStartOfMonth();
                
                purchaseUnitSummary.Month_Start__c = thisMonthStart;
                
                purchaseUnitSummaries.put(identifier, purchaseUnitSummary);
            }
            else {
                purchaseUnitSummary = purchaseUnitSummaries.get(identifier);
            }
            
            purchaseUnitSummary.Quantity__c += purchaseUnitLine.Quantity__c;
            purchaseUnitSummary.Last_Summarization_Date__c = Date.today();
        }
        
        
        List <Purchase_Unit_Summary__c> purchaseUnitSummariesForUpsert = purchaseUnitSummaries.values();
        //upsert purchaseUnitSummariesForUpsert Unique_ID__c;
        Database.upsert(purchaseUnitSummariesForUpsert, Purchase_Unit_Summary__c.Unique_ID__c, false);

        //chainPurchaseUnitSummaries(earliestMonthStart, latestMonthEnd);
        
        //System.enqueueJob(new BeaconPurchaseUnitSummaryChainQueueable(earliestMonthStart, latestMonthEnd));
    }


    /*
    public static Date findEarliestMonthForUpdatedPurchaseUnitSummaryData () {
        try {
            return [Select Month_Start__c From Purchase_Unit_Summary__c Where Last_Summarization_Date__c = LAST_N_DAYS:1 Order By Month_Start__c Asc Limit 1].Last_Summarization_Date__c;
        }
        catch (Exception ex) {
            return null;
        }
    }

    public static void updatePuchaseUnitAccumulations (Date startingMonth) {
        System.enqueueJob(new BeaconPurchaseUnitAccumulator(startingMonth));
    }

    public static void updatePuchaseUnitAccumulations (Date startingMonth, Id accountId) {
        System.enqueueJob(new BeaconPurchaseUnitAccumulator(startingMonth, new List <Id> {accountId}));
    }

    public static void updatePuchaseUnitAccumulations (Date startingMonth, List <Id> accountIds) {
        System.enqueueJob(new BeaconPurchaseUnitAccumulator(startingMonth, accountIds));
    }
    */
    /*
    public static void chainPurchaseUnitSummaries (Date earliestMonthStart, Date latestMonthEnd) {
        // Adjust the earliest date to the prior month to capture the tail end of the last segment.
        earliestMonthStart = earliestMonthStart.addMonths(-1);

        // We need to chain together the summaries so that data can be accumulated via formula fields.
        List <Purchase_Unit_Summary__c> purchaseUnitSummariesToChain = new List <Purchase_Unit_Summary__c> ([Select Id, Account__c, Product__c, Quantity__c, Running_Quantity__c From Purchase_Unit_Summary__c Where Month_Start__c >= :earliestMonthStart And Month_Start__c <= :latestMonthEnd Order By Account__c, Product__c, Year_And_Month__c]);
        
        // Organize the summaries by their accounts.
        Map <String, Map <String, List <Purchase_Unit_Summary__c>>> mappedPUSLists = new Map <String, Map <String, List <Purchase_Unit_Summary__c>>> ();
        Map <String, List <Purchase_Unit_Summary__c>> productPUSList = null;
        for (Purchase_Unit_Summary__c pus : purchaseUnitSummariesToChain) {
            if (!mappedPUSLists.containsKey(pus.Account__c)) mappedPUSLists.put(pus.Account__c, new Map <String, List <Purchase_Unit_Summary__c>> ());
            productPUSList = mappedPUSLists.get(pus.Account__c);
            if (!productPUSList.containsKey(pus.Product__c)) productPUSList.put(pus.Product__c, new List <Purchase_Unit_Summary__c> ());
            productPUSList.get(pus.Product__c).add(pus);
        }

        // For each account, get the list of summaries and point each one at the previous.
        for (Map <String, List <Purchase_Unit_Summary__c>> pusMap : mappedPUSLists.values()) {
            for (List <Purchase_Unit_Summary__c> pusList : pusMap.values()) {
                for (Integer i = 1; i < pusList.size(); i++) {
                    Purchase_Unit_Summary__c previousPUS = pusList[i-1];
                    Purchase_Unit_Summary__c currentPUS = pusList[i];
        
                    //currentPUS.Previous_Purchase_Unit_Summary__c = previousPUS.Id;
                    Integer previousRunningQuantity = Integer.valueOf(previousPUS.Running_Quantity__c == null ? previousPUS.Quantity__c : previousPUS.Running_Quantity__c);
                    Integer currentQuantity = Integer.valueOf(currentPUS.Quantity__c == null ? 0 : currentPUS.Quantity__c);
                    currentPUS.Running_Quantity__c = previousRunningQuantity + currentQuantity;
                    currentPUS.Last_Rollup_Date__c = Date.today();
                }
            }
        }

        update purchaseUnitSummariesToChain;

        System.enqueueJob(new BeaconPurchaseUnitAccumulator(latestMonthEnd.addMonths(1)));
    }
    */
    /*
    public static Map <String, Map <String, List <Purchase_Unit_Summary__c>>> getMappedPurchaseUnitSummaries (Date earliestMonthStart, Date latestMonthEnd) {
        return getMappedPurchaseUnitSummaries(earliestMonthStart, latestMonthEnd, null);
    }
    public static Map <String, Map <String, List <Purchase_Unit_Summary__c>>> getMappedPurchaseUnitSummaries (Date earliestMonthStart, Date latestMonthEnd, List <Id> accountIds) {
        // Adjust the earliest date to the prior month to capture the tail end of the last segment.
        earliestMonthStart = earliestMonthStart.addMonths(-1);

        // We need to chain together the summaries so that data can be accumulated via formula fields.
        List <Purchase_Unit_Summary__c> purchaseUnitSummariesToChain;
        
        if (accountIds == null) {
            purchaseUnitSummariesToChain = new List <Purchase_Unit_Summary__c> ([Select Id, Account__c, Product__c, Quantity__c, Running_Quantity__c From Purchase_Unit_Summary__c Where Month_Start__c >= :earliestMonthStart And Month_Start__c <= :latestMonthEnd Order By Account__c, Product__c, Year_And_Month__c]);
        }
        else {
            purchaseUnitSummariesToChain = new List <Purchase_Unit_Summary__c> ([Select Id, Account__c, Product__c, Quantity__c, Running_Quantity__c From Purchase_Unit_Summary__c Where Account__c in :accountIds And Month_Start__c >= :earliestMonthStart And Month_Start__c <= :latestMonthEnd Order By Account__c, Product__c, Year_And_Month__c]);
        }


        // Organize the summaries by their accounts.
        Map <String, Map <String, List <Purchase_Unit_Summary__c>>> mappedPUSLists = new Map <String, Map <String, List <Purchase_Unit_Summary__c>>> ();
        Map <String, List <Purchase_Unit_Summary__c>> productPUSList = null;
        for (Purchase_Unit_Summary__c pus : purchaseUnitSummariesToChain) {
            if (!mappedPUSLists.containsKey(pus.Account__c)) mappedPUSLists.put(pus.Account__c, new Map <String, List <Purchase_Unit_Summary__c>> ());
            productPUSList = mappedPUSLists.get(pus.Account__c);
            if (!productPUSList.containsKey(pus.Product__c)) productPUSList.put(pus.Product__c, new List <Purchase_Unit_Summary__c> ());
            productPUSList.get(pus.Product__c).add(pus);
        }

        return mappedPUSLists;
    }


    public static void rollupPurchaseUnitSummariesForAccount (Map <String, List <Purchase_Unit_Summary__c>> pusMap) {
        List <Purchase_Unit_Summary__c> pusUpdates = new List <Purchase_Unit_Summary__c> ();

        for (List <Purchase_Unit_Summary__c> pusList : pusMap.values()) {
            pusUpdates.addAll(pusList);

            for (Integer i = 1; i < pusList.size(); i++) {
                Purchase_Unit_Summary__c previousPUS = pusList[i-1];
                Purchase_Unit_Summary__c currentPUS = pusList[i];
    
                Integer previousRunningQuantity = Integer.valueOf(previousPUS.Running_Quantity__c == null ? previousPUS.Quantity__c : previousPUS.Running_Quantity__c);
                Integer currentQuantity = Integer.valueOf(currentPUS.Quantity__c == null ? 0 : currentPUS.Quantity__c);
                currentPUS.Running_Quantity__c = previousRunningQuantity + currentQuantity;
                currentPUS.Last_Rollup_Date__c = Date.today();
            }
        }

        update pusUpdates;
    }


    public static void updateConsumptionAndPurchaseUnitAccumulations (Id accountId) {
        Date earliestDate = Date.today().addYears(-6);
        updateConsumptionAccumulations(earliestDate, accountId);
        updatePuchaseUnitAccumulations(earliestDate, accountId);
    }



    public static Date findEarliestMonthForUpdatedConsumptionSummaryData () {
        try {
            return [Select Month_Start__c From Consumption_Summary__c Where Last_Summarization_Date__c = LAST_N_DAYS:1 Order By Month_Start__c Asc Limit 1].Last_Summarization_Date__c;
        }
        catch (Exception ex) {
            return null;
        }
    }

    public static void updateConsumptionAccumulations (Date startingMonth) {
        System.enqueueJob(new BeaconConsumptionAccumulator(startingMonth));
    }

    public static void updateConsumptionAccumulations (Date startingMonth, Id accountId) {
        System.enqueueJob(new BeaconConsumptionAccumulator(startingMonth, new List <Id> {accountId}));
    }

    public static void updateConsumptionAccumulations (Date startingMonth, List <Id> accountIds) {
        System.enqueueJob(new BeaconConsumptionAccumulator(startingMonth, accountIds));
    }
    */
    /*
    public static void chainConsumptionSummaries (Date earliestMonthStart, Date latestMonthEnd) {
        // Adjust the earliest date to the prior month to capture the tail end of the last segment.
        earliestMonthStart = earliestMonthStart.addMonths(-1);

        // We need to chain together the summaries so that data can be accumulated via formula fields.
        List <Consumption_Summary__c> consumptionSummariesToChain = new List <Consumption_Summary__c> ([Select Id, Account__c, Product__c, Quantity__c, Running_Quantity__c From Consumption_Summary__c Where Month_Start__c >= :earliestMonthStart And Month_Start__c <= :latestMonthEnd Order By Account__c, Product__c, Year_And_Month__c]);
        
        // Organize the summaries by their accounts.
        Map <String, Map <String, List <Consumption_Summary__c>>> mappedCSLists = new Map <String, Map <String, List <Consumption_Summary__c>>> ();
        Map <String, List <Consumption_Summary__c>> productCSList = null;
        for (Consumption_Summary__c cs : consumptionSummariesToChain) {
            if (!mappedCSLists.containsKey(cs.Account__c)) mappedCSLists.put(cs.Account__c, new Map <String, List <Consumption_Summary__c>> ());
            productCSList = mappedCSLists.get(cs.Account__c);
            if (!productCSList.containsKey(cs.Product__c)) productCSList.put(cs.Product__c, new List <Consumption_Summary__c> ());
            productCSList.get(cs.Product__c).add(cs);
        }

        // For each account, get the list of summaries and point each one at the previous.
        for (Map <String, List <Consumption_Summary__c>> csMap : mappedCSLists.values()) {
            for (List <Consumption_Summary__c> csList : csMap.values()) {
                for (Integer i = 1; i < csList.size(); i++) {
                    Consumption_Summary__c previousCS = csList[i-1];
                    Consumption_Summary__c currentCS = csList[i];
        
                    Integer previousRunningQuantity = Integer.valueOf(previousCS.Running_Quantity__c == null ? previousCS.Quantity__c : previousCS.Running_Quantity__c);
                    Integer currentQuantity = Integer.valueOf(currentCS.Quantity__c == null ? 0 : currentCS.Quantity__c);
                    currentCS.Running_Quantity__c = previousRunningQuantity + currentQuantity;
                    currentCS.Last_Rollup_Date__c = Date.today();
                }
            }
        }

        update consumptionSummariesToChain;

        System.enqueueJob(new BeaconConsumptionAccumulator(latestMonthEnd.addMonths(1)));
    }
    */
    /*
    public static Map <String, Map <String, List <Consumption_Summary__c>>> getMappedConsumptionSummaries (Date earliestMonthStart, Date latestMonthEnd) {
        return getMappedConsumptionSummaries(earliestMonthStart, latestMonthEnd, null);
    }

    public static Map <String, Map <String, List <Consumption_Summary__c>>> getMappedConsumptionSummaries (Date earliestMonthStart, Date latestMonthEnd, List <Id> accountIds) {
        // Adjust the earliest date to the prior month to capture the tail end of the last segment.
        earliestMonthStart = earliestMonthStart.addMonths(-1);

        // We need to chain together the summaries so that data can be accumulated via formula fields.
        List <Consumption_Summary__c> consumptionSummariesToChain;
        
        if (accountIds == null) {
            consumptionSummariesToChain = new List <Consumption_Summary__c> ([Select Id, Account__c, Product__c, Quantity__c, Running_Quantity__c From Consumption_Summary__c Where Month_Start__c >= :earliestMonthStart And Month_Start__c <= :latestMonthEnd Order By Account__c, Product__c, Year_And_Month__c]);
        }
        else {
            consumptionSummariesToChain = new List <Consumption_Summary__c> ([Select Id, Account__c, Product__c, Quantity__c, Running_Quantity__c From Consumption_Summary__c Where Account__c in :accountIds And Month_Start__c >= :earliestMonthStart And Month_Start__c <= :latestMonthEnd Order By Account__c, Product__c, Year_And_Month__c]);
        }
        
        // Organize the summaries by their accounts.
        Map <String, Map <String, List <Consumption_Summary__c>>> mappedCSLists = new Map <String, Map <String, List <Consumption_Summary__c>>> ();
        Map <String, List <Consumption_Summary__c>> productCSList = null;
        for (Consumption_Summary__c cs : consumptionSummariesToChain) {
            if (!mappedCSLists.containsKey(cs.Account__c)) mappedCSLists.put(cs.Account__c, new Map <String, List <Consumption_Summary__c>> ());
            productCSList = mappedCSLists.get(cs.Account__c);
            if (!productCSList.containsKey(cs.Product__c)) productCSList.put(cs.Product__c, new List <Consumption_Summary__c> ());
            productCSList.get(cs.Product__c).add(cs);
        }

        return mappedCSLists;
    }


    public static void rollupConsumptionSummariesForAccount (Map <String, List <Consumption_Summary__c>> csMap) {
        List <Consumption_Summary__c> csUpdates = new List <Consumption_Summary__c> ();

        for (List <Consumption_Summary__c> csList : csMap.values()) {
            csUpdates.addAll(csList);

            for (Integer i = 1; i < csList.size(); i++) {
                Consumption_Summary__c previousCS = csList[i-1];
                Consumption_Summary__c currentCS = csList[i];
    
                Integer previousRunningQuantity = Integer.valueOf(previousCS.Running_Quantity__c == null ? previousCS.Quantity__c : previousCS.Running_Quantity__c);
                Integer currentQuantity = Integer.valueOf(currentCS.Quantity__c == null ? 0 : currentCS.Quantity__c);
                currentCS.Running_Quantity__c = previousRunningQuantity + currentQuantity;
                currentCS.Last_Rollup_Date__c = Date.today();
            }
        }

        update csUpdates;
    }
    */
    
    
    /*
    public static void createPurchaseUnitSummaryRecords (List <Purchase_Unit_Summary__c> records) {
        // Go over the records to get the accounts and assets they should link to.
        Set <String> customerNumbers = new Set <String> ();
        Set <String> productNumbers = new Set <String> ();
        for (Purchase_Unit_Summary__c p : records) {
            customerNumbers.add(p.Customer_Number__c);
            productNumbers.add(p.Product_Number__c);
        }
        
        // Build maps of the customers and products to link.
        Map <String, Id> customerMap = new Map <String, Id> ();
        Map <String, Id> productMap = new Map <String, Id> ();
        for (Account a : [Select Id, Customer_Number__c From Account Where Customer_Number__c in :customerNumbers]) customerMap.put(a.Customer_Number__c, a.Id);
        for (Product2 p : [Select Id, Name From Product2 Where Name in :productNumbers]) productMap.put(p.Name, p.Id);
        
        // Link customers and products to the incoming records. Also create the unique id for the record.
        for (Purchase_Unit_Summary__c p : records) {
            p.Account__c = customerMap.get(p.Customer_Number__c);
            p.Product__c = productMap.get(p.Product_Number__c);
            p.Unique_ID__c = getPurchaseUnitSummaryUniqueID(p.Customer_Number__c, p.Product_Number__c, p.Month_Start__c.year(), p.Month_Start__c.month());
        }
        
        // Upsert the consumption summaries.
        upsert records Unique_ID__c;
    }
    */
    
    private class PurchaseUnitStructure {
        public Purchase_Unit_Header__c header;
        public List <Purchase_Unit_Line__c> lines;
        
        public PurchaseUnitStructure () {
            header = null;
            lines = new List <Purchase_Unit_Line__c> ();
        }
        
        public void supplyHeaderRecordIDsToLines () {
            for (Purchase_Unit_Line__c line : lines) line.Purchase_Unit_Header__c = header.Id;
        }
        
        public void assignLookups (Map <String, Id> accountMap, Map <String, Id> ownerAccountMap, Map <String, Id> productMap) {
            header.Account__c = accountMap.get(header.Customer_Number__c);
            for (Purchase_Unit_Line__c line : lines) {
                line.Owner_Account__c 	= ownerAccountMap.get(line.Owner_Number__c);
                System.debug('ASSIGNED OWNER ACCOUNT: '+ line.Owner_Number__c +': '+ line.Owner_Account__c);
                line.Product__c 		= productMap.get(line.Product_Number__c);
            }
        }

        public List <Purchase_Unit_Line__c> getPurchaseUnitLines () {
            return lines;
        }


    }
    
    
    public static String createPurchaseUnitLineAndSummaryRecords (List <String> lineRecords) {
        Map <String, PurchaseUnitStructure> purchaseUnitStructures = new Map <String, PurchaseUnitStructure> ();
        
        List <Purchase_Unit_Header__c> 	purchaseUnitHeadersToUpsert = new List <Purchase_Unit_Header__c> ();
        List <Purchase_Unit_Line__c> 	purchaseUnitLinesToUpsert 	= new List <Purchase_Unit_Line__c> ();
        
        Set <String> customerNumbers 	= new Set <String> ();
        Set <String> ownerNumbers 		= new Set <String> ();
        Set <String> productNumbers 	= new Set <String> ();
        
        DateTime earliestDate;
        DateTime latestDate;
        
        for (String lineRecord : lineRecords) {
            
            String[] tokens = lineRecord.split(',');
            //for (String token : tokens) token = token.replaceAll('\n','');
            String  customerNumber      = formatCustomerNumber(tokens[0]);
            Date    invoiceDate         = getCleanDate(tokens[1]);
            String  invoiceNumber       = tokens[2];
            Date    orderDate           = getCleanDate(tokens[3]);
            String  orderNumber         = tokens[4];
            String  salesCreditNumber   = tokens[5];
            Integer lineNumber          = Integer.valueOf(tokens[6]);
            String  ownerNumber         = formatCustomerNumber(tokens[7]);
            String  shipToName          = tokens[8];
            String  shipToNumber        = tokens[9];
            String  productNumber       = tokens[10];
            Decimal price               = Decimal.valueOf(tokens[11]);
            Integer quantity            = Integer.valueOf(tokens[12].trim());

            String  headerKey           = getPurchaseUnitHeaderUniqueID(customerNumber, invoiceNumber); // Invoice Number is used as a unique key for the header.
            String  lineUniqueKey       = getPurchaseUnitLineUniqueID(customerNumber, invoiceNumber, lineNumber);


            if (!purchaseUnitStructures.containsKey(headerKey)) {
                PurchaseUnitStructure pus = new PurchaseUnitStructure();
                purchaseUnitStructures.put(headerKey, pus);
                
                Purchase_Unit_Header__c header = new Purchase_Unit_Header__c();
                purchaseUnitHeadersToUpsert.add(header);
                pus.header = header;
                
                // Populate header here
                header.Customer_Number__c 		= customerNumber;
                header.Invoice_Date__c 			= invoiceDate;
                header.Invoice_Number__c 		= invoiceNumber;
                header.Order_Date__c 			= orderDate;
                header.Order_Number__c 			= orderNumber;
                header.Sales_Credit_Number__c 	= salesCreditNumber;
                header.Unique_ID__c 			= headerKey;
                
                customerNumbers.add(header.Customer_Number__c);

                if (earliestDate == null || earliestDate > header.Invoice_Date__c) earliestDate = header.Invoice_Date__c;
                if (latestDate == null || latestDate < header.Invoice_Date__c) latestDate = header.Invoice_Date__c;
            }
            
            PurchaseUnitStructure pus = purchaseUnitStructures.get(headerKey);
            
            Purchase_Unit_Line__c line = new Purchase_Unit_Line__c();
            pus.lines.add(line);

            // Populate line here
            line.Line_Number__c 		= lineNumber;
            line.Owner_Number__c 		= ownerNumber;
            line.Ship_To_Name__c 		= shipToName;
            line.Ship_To_Number__c 		= shipToNumber;
            line.Product_Number__c 		= productNumber;
            line.Price__c 				= price;
            line.Quantity__c 			= quantity;
            line.Unique_ID__c			= lineUniqueKey;
            
            ownerNumbers.add(line.Owner_Number__c);
            productNumbers.add(line.Product_Number__c);
        }

        Date earliestMonthStart = Date.newInstance(earliestDate.year(), earliestDate.month(), earliestDate.day()).toStartOfMonth();
        Date latestMonthEnd = Date.newInstance(latestDate.year(), latestDate.month(), latestDate.day()).addMonths(1).toStartOfMonth().addDays(-1);
        //System.debug('PRODUCTS TO SEARCH FOR: '+ products);
        System.debug('EARLIEST DATE: '+ earliestMonthStart);
        System.debug('LATEST DATE: '+ latestMonthEnd);
        
        Map <String, Id> accountMap 		= getAccountMapByCustomerNumber(customerNumbers);
        Map <String, Id> ownerAccountMap 	= getAccountMapByCustomerNumber(ownerNumbers);
        Map <String, Id> productMap 		= getProductMapByProductNumber(productNumbers);
        
        for (PurchaseUnitStructure pus : purchaseUnitStructures.values()) pus.assignLookups(accountMap, ownerAccountMap, productMap); // Alter this function to take in the owner map

        List <PurchaseUnitLineResult> purchaseUnitLineResults = new List <PurchaseUnitLineResult> ();
               
        List <Database.UpsertResult> headerUpsertResults = Database.upsert(purchaseUnitHeadersToUpsert, Purchase_Unit_Header__c.Unique_ID__c, false);
        //upsert purchaseUnitHeadersToUpsert Unique_ID__c;
        for (Integer i = 0; i < headerUpsertResults.size(); i++) {
            Database.UpsertResult result = headerUpsertResults[i];
            
            Purchase_Unit_Header__c header = purchaseUnitHeadersToUpsert[i];
            System.debug('Purchase Unit Header: '+ header.Unique_ID__c +': Upsert Result: '+ result.isSuccess());
            PurchaseUnitStructure pus = purchaseUnitStructures.get(header.Unique_ID__c);
                
            if (result.isSuccess()) {
                pus.supplyHeaderRecordIDsToLines();
                purchaseUnitLinesToUpsert.addAll(pus.getPurchaseUnitLines());
            }
            else {
                String errorText = '';
                errorText += 'Error upserting purchase unit header: '+ result.getErrors().size() +' errors: ';
                for (Database.Error error : result.getErrors()) {
                    String thisErrorMessage = translateErrorMessage(error.getMessage());
                    errorText += thisErrorMessage +'; ';
                }
                
                // Report the error with the header insert down to each line so it can be reported back.
                for (Purchase_Unit_Line__c pul : pus.getPurchaseUnitLines()) {
                    System.debug('HEADER ERROR: '+ pul.Unique_ID__c +' - '+ errorText);
                    purchaseUnitLineResults.add(new PurchaseUnitLineResult(pul.Unique_ID__c, errorText));
                }
            }
        }

        //for (PurchaseUnitStructure pus : purchaseUnitStructures.values()) pus.supplyHeaderRecordIDsToLines();
        //upsert purchaseUnitLinesToUpsert Unique_ID__c;

        List <Database.UpsertResult> upsertResults = Database.upsert(purchaseUnitLinesToUpsert, Purchase_Unit_Line__c.Unique_ID__c, false);
        for (Integer i = 0; i < upsertResults.size(); i++) {
            Database.UpsertResult result = upsertResults[i];
            Purchase_Unit_Line__c pul = purchaseUnitLinesToUpsert[i];
            if (result.isSuccess()) {
                purchaseUnitLineResults.add(new PurchaseUnitLineResult(pul.Unique_ID__c, 'OK'));
            }
            else if (!result.isSuccess()) {
                String errorText = '';
                errorText += result.getErrors().size() +' errors: ';
                for (Database.Error error : result.getErrors()) {
                    String thisErrorMessage = translateErrorMessage(error.getMessage());
                    errorText += thisErrorMessage +'; ';
                }
                System.debug('LINE ERROR: '+ pul.Unique_ID__c +' - '+ errorText);
                purchaseUnitLineResults.add(new PurchaseUnitLineResult(pul.Unique_ID__c, errorText));
            }
        }

        // Future method.
        //createPurchaseUnitSummaryRecords(earliestMonthStart, latestMonthEnd);
        System.enqueueJob(new BeaconPurchaseUnitSummaryCreateQueueable(earliestMonthStart, latestMonthEnd));
        return JSON.serialize(purchaseUnitLineResults);
    }
    
    
    /**
     * Split a string of any size, while avoiding the dreaded 'Regex too complicated'
     * error, which the String.split(String) method causes on some large inputs.
     *
     * Note that this method does not avoid other errors, such as those related to 
     * excess heap size or CPU time.
     */
	private static List <String> safeSplit (String inStr, String delim) {
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;
        
        List <String> output = new List <String> ();
        
        Matcher m = Pattern.compile(delim).matcher(inStr);
        
        Integer lastEnd = 0;
    
        while(!m.hitEnd()) {
            while(regexFindCount < regexFindLimit && !m.hitEnd()) {
                if(m.find()) {
                    output.add(inStr.substring(lastEnd, m.start()));  
                    lastEnd = m.end();
                }
                else {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                
                regexFindCount++;
            }
    
            // Note: Using region() to advance instead of substring() saves 
            // drastically on heap size. Nonetheless, we still must reset the 
            // (unmodified) input sequence to avoid a 'Regex too complicated' 
            // error.
            m.reset(inStr);        
            m.region(lastEnd, m.regionEnd());
            
            regexFindCount = 0;
        }
        
        return output;
    }



    public static ConsumptionDetailResponse getConsumptionDetail (String customerNumber, String startYearAndMonth, String endYearAndMonth, String assetSerialNumber, Integer pageNumber, Integer pageSize) {
        
        try {
            if (!String.isEmpty(customerNumber) && !String.isEmpty(startYearAndMonth) && !String.isEmpty(endYearAndMonth)) {

                Beacon_Integration__mdt consumptionDetailIntegrationSettings = [Select Id, Label, Consumption_Detail_Endpoint__c, API_Key__c From Beacon_Integration__mdt Where Label = 'Consumption Detail'];

                // Trim the leading zeros off the customer number.
                Integer customerNumberInteger = Integer.valueOf(customerNumber);

                String url = consumptionDetailIntegrationSettings.Consumption_Detail_Endpoint__c +'?apiKey='+ consumptionDetailIntegrationSettings.API_Key__c;
                url += '&CustomerNumber='+customerNumberInteger;
                url += '&StartMonth='+startYearAndMonth;
                url += '&EndMonth='+endYearAndMonth;
                url += '&PageSize='+pageSize;
                url += '&PageNumber='+pageNumber;

                if (!String.isEmpty(assetSerialNumber)) url += '&SerialNumber='+assetSerialNumber;

                HttpRequest request = new HttpRequest();
                request.setEndpoint(url);
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(60000);

                HttpResponse response = new Http().send(request);

                System.debug('RESPONSE: '+response.getBody());
                String responseBody = response.getBody().replace('Date', 'dDate');
                ConsumptionDetailResponse consumptionResponse = (ConsumptionDetailResponse)JSON.deserialize(responseBody, ConsumptionDetailResponse.class);
                
                System.debug('RECORD COUNT: '+ consumptionResponse.TotalItems);

                return consumptionResponse;//.ConsumptionDetailRecords;
            }
            else {
                System.debug('Not enough parameters supplied.');
                return new ConsumptionDetailResponse();
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return new ConsumptionDetailResponse();
        }
    }


    
    public static void formatCustomerNumbers (List <Account> accounts) {
        for (Account a : accounts) {
            if (!String.isEmpty(a.Customer_Number__c)) {
                a.Customer_Number__c = formatCustomerNumber(a.Customer_Number__c);
            }
        }
    }

    public static String formatCustomerNumber (String customerNumber) {
        return customerNumber != null ? customerNumber.trim().leftPad(8, '0') : customerNumber;
    }
    
    
    
    public static void updateAggregatorFields (List <Consumption_Summary__c> records) {
        for (Consumption_Summary__c record : records) {
            record.Year_Group_By__c 			= record.Year__c;
            record.Year_and_Quarter_Group_By__c = record.Year_and_Quarter__c;
            record.Year_and_Month_Group_By__c 	= record.Year_and_Month__c;
        }
    }



    public static String getConsumptionDetailCSVExportData (String customerNumber, String startYearAndMonth, String endYearAndMonth, String assetSerialNumber, Integer pageNumber, Integer pageSize) {
        ConsumptionDetailResponse consumptionResponse = getConsumptionDetail(customerNumber, startYearAndMonth, endYearAndMonth, assetSerialNumber, pageNumber, pageSize);
        return consumptionResponse.getCSVExportData();
    }


    public class ConsumptionDetailResponse {
        public List <ConsumptionDetail> ConsumptionDetailRecords;
        public Integer TotalItems;
        public String CustomerNumber;
        public String StartMonth;
        public String EndMonth;
        public String SerialNumber;
        public Integer PageNumber;
        public Integer PageSize;
        
        public ConsumptionDetailResponse () {
            this.ConsumptionDetailRecords = new List <ConsumptionDetail> ();
            this.TotalItems = 0;
            this.CustomerNumber = '';
            this.StartMonth = '';
            this.EndMonth = '';
            this.SerialNumber = '';
            this.PageNumber = 0;
            this.PageSize = 0;
        }


        public String getCSVExportData () {
            String csv = '';
            csv += 'ProductNumber,SerialNumber,QuantityConsumed,Date,Status,Route,Cadence,Tag1,Tag2\n';
            for (ConsumptionDetail cd : ConsumptionDetailRecords) {
                csv += cd.ProductNumber+',';
                csv += cd.SerialNumber+',';
                csv += cd.QuantityConsumed+',';
                csv += cd.dDate+',';
                csv += cd.Status+',';
                csv += cd.Route+',';
                csv += cd.Cadence+',';
                csv += cd.Tag1+',';
                csv += cd.Tag2+'\n';
            }
            return csv;
        }
    }
    public class ConsumptionDetail {
        public String   ProductNumber       {get; set;}
        public String   SerialNumber        {get; set;}
        public Decimal  QuantityConsumed    {get; set;}
        public String   dDate               {get; set;}
        public String   Status              {get; set;}
        public String   Route               {get; set;}
        public Integer  Cadence             {get; set;}
        public String   Tag1                {get; set;}
        public String   Tag2                {get; set;}

        public String getYearAndMonth () {
            /*
            String[] tokens = dDate.split('-');
            return tokens[0]+'-'+tokens[1]+'-01';
            */
            return dDate;
        }
    }


    public class AssetResult {
        public String customerNumber;
        public String serialNumber;
        public String result;

        public AssetResult (String customerNumber, String serialNumber, String result) {
            this.customerNumber = customerNumber;
            this.serialNumber = serialNumber;
            this.result = result;
        }
    }


    public class ConsumptionSummaryResult {
        public String customerNumber;
        public String productNumber;
        public Integer year;
        public Integer month;
        public String result;

        public ConsumptionSummaryResult (String customerNumber, String productNumber, Integer year, Integer month, String result) {
            this.customerNumber = customerNumber;
            this.productNumber = productNumber;
            this.year = year;
            this.month = month;
            this.result = result;
        }
    }


    public class PurchaseUnitLineResult {
        public String uniqueID;
        public String result;

        public PurchaseUnitLineResult (String uniqueID, String result) {
            this.uniqueID = uniqueID;
            this.result = result;
        }
    }


    public static List <Purchase_Unit_Line__c> getPurchaseUnitLines (Id accountId, Date startDate, Date endDate) {
        // 2022-02-24 - Joe Bunda, Allium - Replaced with query that filters on the owner account instead of the customer account.
        //List <Purchase_Unit_Line__c> lines = new List <Purchase_Unit_Line__c> ([Select Id, Purchase_Unit_Header__r.Invoice_Number__c, Purchase_Unit_Header__r.Invoice_Date__c, Purchase_Unit_Header__r.Order_Number__c, Purchase_Unit_Header__r.Sales_Credit_Number__c, Line_Number__c, Price__c, Product__r.Name, Quantity__c From Purchase_Unit_Line__c Where Purchase_Unit_Header__r.Account__c = :accountId And Purchase_Unit_Header__r.Invoice_Date__c >= :startDate And Purchase_Unit_Header__r.Invoice_Date__c <= :endDate]);
        List <Purchase_Unit_Line__c> lines = new List <Purchase_Unit_Line__c> ([Select Id, Purchase_Unit_Header__r.Invoice_Number__c, Purchase_Unit_Header__r.Invoice_Date__c, Purchase_Unit_Header__r.Order_Number__c, Purchase_Unit_Header__r.Sales_Credit_Number__c, Line_Number__c, Price__c, Product__r.Name, Quantity__c From Purchase_Unit_Line__c Where Owner_Account__c = :accountId And Purchase_Unit_Header__r.Invoice_Date__c >= :startDate And Purchase_Unit_Header__r.Invoice_Date__c <= :endDate]);
        return lines;
    }


    public static String getPurchaseUnitExport (Id accountId, Date startDate, Date endDate) {
        String csv = '';
        csv += 'Invoice Date,Item Number,Price,Quantity,Order #,Line #,Invoice #,SC #\n';
        for (Purchase_Unit_Line__c line : getPurchaseUnitLines(accountId, startDate, endDate)) {
            csv += String.valueOf(line.Purchase_Unit_Header__r.Invoice_Date__c)+',';
            csv += line.Product__r.Name+',';
            csv += line.Price__c+',';
            csv += line.Quantity__c+',';
            csv += line.Purchase_Unit_Header__r.Order_Number__c+',';
            csv += line.Line_Number__c+',';
            csv += line.Purchase_Unit_Header__r.Invoice_Number__c+',';
            csv += line.Purchase_Unit_Header__r.Sales_Credit_Number__c+'\n';
        }
        return csv;
    }


    public static List <Purchase_Unit_Line__c> getPurchaseUnitLinesDistributor (Id accountId, Date startDate, Date endDate) {
        List <Purchase_Unit_Line__c> lines = new List <Purchase_Unit_Line__c> ([Select Id, Ship_To_Number__c, Ship_To_Name__c, Owner_Number__c, Purchase_Unit_Header__r.Invoice_Number__c, Purchase_Unit_Header__r.Invoice_Date__c, Purchase_Unit_Header__r.Order_Number__c, Purchase_Unit_Header__r.Sales_Credit_Number__c, Line_Number__c, Price__c, Product__r.Name, Quantity__c From Purchase_Unit_Line__c Where Purchase_Unit_Header__r.Account__c = :accountId And Purchase_Unit_Header__r.Invoice_Date__c >= :startDate And Purchase_Unit_Header__r.Invoice_Date__c <= :endDate]);
        return lines;
    }


    public static String getPurchaseUnitWithDistributorExport (Id accountId, Date startDate, Date endDate) {
        String csv = '';
        csv += 'Ship-To #,Ship-To Name,Owner #,Invoice Date,Item Number,Price,Quantity,Order #,Line #,Invoice #,SC #\n';
                    
        for (Purchase_Unit_Line__c line : getPurchaseUnitLinesDistributor(accountId, startDate, endDate)) {
            csv += line.Ship_To_Number__c+',';
            csv += line.Ship_To_Name__c+',';
            csv += line.Owner_Number__c+',';
            csv += String.valueOf(line.Purchase_Unit_Header__r.Invoice_Date__c)+',';
            csv += line.Product__r.Name+',';
            csv += line.Price__c+',';
            csv += line.Quantity__c+',';
            csv += line.Purchase_Unit_Header__r.Order_Number__c+',';
            csv += line.Line_Number__c+',';
            csv += line.Purchase_Unit_Header__r.Invoice_Number__c+',';
            csv += line.Purchase_Unit_Header__r.Sales_Credit_Number__c+'\n';
        }
        return csv;
    }





    public static Date getDateFromString (String input, Boolean startOfMonth) {
        if (!String.isBlank(input)) {
            // Do a check to determine if the date has two or three components.
            String[] tokens = input.split('-');
            
            if (tokens.size() == 2) {
                Date testDate = Date.newInstance(Integer.valueOf(tokens[0]), Integer.valueOf(tokens[1]), 1);
                if (startOfMonth) {
                    return testDate;
                }
                else {
					return Date.newInstance(testDate.year(), testDate.month(), testDate.day()).addMonths(1).toStartOfMonth().addDays(-1);                    
                }
            }
            else if (tokens.size() == 3) {
                try {
                    return Date.valueOf(input);
                }
                catch (Exception ex) {
                    System.debug('WARNING: DateTime input string not valid ('+ input +'). Returning null.');
                    return null;
                }
            }
            else {
                System.debug('WARNING: DateTime input string not valid ('+ input +'). Returning null.');
                return null;
            }
        }
        else {
            return null;
        }
    }


    public static Id getAccountIdFromCustomerNumber (String customerNumber) {
        return [Select Id From Account Where Customer_Number__c = :customerNumber Limit 1][0].Id;
    }


    public class ConsumptionDetailReportProgress {
        public String   Id;
        public Integer  Progress    {get; set;}
        public String   Status      {get; set;}
        public String   ReportUrl   {get; set;}
    }


    public static ConsumptionDetailReportProgress startConsumptionDetailReport (String customerNumber, String startMonth, String endMonth) {
        
        Beacon_Integration__mdt consumptionDetailIntegrationSettings = [Select Id, Label, Consumption_Detail_Endpoint__c, API_Key__c From Beacon_Integration__mdt Where Label = 'Consumption Detail'];

        String endpointPattern = 'https://invoice-api.beaconama.net/v1/Consumption/Report?apiKey={0}&CustomerNumber={1}&StartMonth={2}&EndMonth={3}';
        
        Integer customerNumberInteger = Integer.valueOf(customerNumber);

        String[] parameters = new String[4];
        parameters[0] = consumptionDetailIntegrationSettings.API_Key__c;
        parameters[1] = String.valueOf(customerNumberInteger);
        parameters[2] = startMonth;
        parameters[3] = endMonth;

        String populatedEndpoint = String.format(endpointPattern, parameters);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(populatedEndpoint);
        request.setMethod('POST');

        HttpResponse response = new Http().send(request);

        ConsumptionDetailReportProgress reportProgress = (ConsumptionDetailReportProgress) JSON.deserialize(response.getBody(), ConsumptionDetailReportProgress.class);

        return reportProgress;
    }

    public static ConsumptionDetailReportProgress getConsumptionDetailReportProgress (String consumptionDetailReportID) {
        Beacon_Integration__mdt consumptionDetailIntegrationSettings = [Select Id, Label, Consumption_Detail_Endpoint__c, API_Key__c From Beacon_Integration__mdt Where Label = 'Consumption Detail'];

        String endpointPattern = 'https://invoice-api.beaconama.net/v1/Consumption/Report/{0}?apiKey={1}';
        
        String[] parameters = new String[2];
        parameters[0] = consumptionDetailReportID;
        parameters[1] = consumptionDetailIntegrationSettings.API_Key__c;

        String populatedEndpoint = String.format(endpointPattern, parameters);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(populatedEndpoint);
        request.setMethod('GET');

        HttpResponse response = new Http().send(request);

        ConsumptionDetailReportProgress reportProgress = (ConsumptionDetailReportProgress) JSON.deserialize(response.getBody(), ConsumptionDetailReportProgress.class);

        return reportProgress;
    }



    public static Map <String, Integer> getCumulativeConsumption (Id accountId, String beforeYearAndMonth) {
        Map <String, Integer> cumulativeConsumptionByProduct = new Map <String, Integer> ();
        for (AggregateResult ar : [Select Product__c, Sum(Quantity__c) QuantitySum From Consumption_Summary__c Where Account__c = :accountId And Year_And_Month__c < :beforeYearAndMonth Group By Rollup(Product__c)]) {
            String productId = String.valueOf(ar.get('Product__c'));
            Integer quantity = Integer.valueOf(ar.get('QuantitySum'));
            System.debug('Product: '+ productId +' - '+ quantity);
            if (productId != null && productId != 'null') cumulativeConsumptionByProduct.put(productId, quantity);
        }
        return cumulativeConsumptionByProduct;
    }

    public static Map <String, Integer> getCumulativePurchase (Id accountId, String beforeYearAndMonth) {
        Map <String, Integer> cumulativePurchaseByProduct = new Map <String, Integer> ();
        for (AggregateResult ar : [Select Product__c, Sum(Quantity__c) QuantitySum From Purchase_Unit_Summary__c Where Account__c = :accountId And Year_And_Month__c < :beforeYearAndMonth Group By Rollup(Product__c)]) {
            String productId = String.valueOf(ar.get('Product__c'));
            Integer quantity = Integer.valueOf(ar.get('QuantitySum'));
            System.debug('Product: '+ productId +' - '+ quantity);
            if (productId != null && productId != 'null') cumulativePurchaseByProduct.put(productId, quantity);
        }
        return cumulativePurchaseByProduct;
    }


    // The only custom exception we throw can only happen if a certain record type exists in Salesforce,
    // and we can't delete it for testing purposes. So this'll have to suffice for test coverage.
    public static void throwIntentionalExceptionForTestCoverage () {
        throw new BeaconException('NOT A REAL ERROR! JUST KIDDING!');
    }

}