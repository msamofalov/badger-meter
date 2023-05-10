public class TrimbleHelper {


    public static String deleteAssetRecords (List <Asset> records) {
        Set <String> assetUniqueIDs = new Set <String> (); 
        for (Asset a : records) {
            a.Customer_Number__c = formatCustomerNumber(a.Customer_Number__c);
            assetUniqueIDs.add(getAssetUniqueID(a.Customer_Number__c, a.SerialNumber));
        }

        // Query for the assets indicated by the incoming data.
        List <Asset> assetsToDelete = new List <Asset> ([Select Id, Customer_Number__c, SerialNumber From Asset Where Asset_Unique_ID__c in :assetUniqueIDs]);
        
        // Delete the assets.
        List <AssetResult> assetResults = new List <AssetResult> ();
        List <Database.DeleteResult> deleteResults = Database.delete(assetsToDelete, false);
        for (Integer i = 0; i < deleteResults.size(); i++) {
            Database.DeleteResult result = deleteResults[i];
            Asset a = assetsToDelete[i];
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
        
        // Get the record type ID.
        //Id recordTypeId = getAssetHWAndAccRecordTypeId(); // 2021-01-14 - JWB, Allium - Removed the lookup to the hardware record type ID. Badger is going to start passing the record type ID directly.
        
        // Link customers and products to the incoming assets. Also create the unique id for the asset.
        for (Asset a : records) {
            a.AccountId = customerMap.containsKey(a.Customer_Number__c) ? customerMap.get(a.Customer_Number__c) : null;
            a.Asset_Shipped_To__c = customerMap.containsKey(a.Customer_Number__c) ? customerMap.get(a.Asset_Shipped_To_Customer_Number__c) : null;
            a.Product2Id = productMap.containsKey(a.Product_Number__c) ? productMap.get(a.Product_Number__c) : null;
            a.Asset_Unique_ID__c = getAssetUniqueID(a.Customer_Number__c, a.SerialNumber);
            a.Name = a.Asset_Unique_ID__c;
            //a.RecordTypeId = recordTypeId;    // 2021-01-14 - JWB, Allium - Removed the setting of the hardware record type ID. Badger is going to start passing the record type ID directly.
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
    
    
    public static Id getAssetHWAndAccRecordTypeId () {
        try {
            return Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Hardware & Accessories').getRecordTypeId();
        }
        catch (Exception ex) {
            throw new TrimbleException('Asset record type "Hardware & Accessories" cannot be found and may need to be created in Salesforce');
        }
    }


    public static String translateErrorMessage (String errorMessage) {
        String translatedErrorMessage = errorMessage;

        if (errorMessage == 'Required fields are missing: [Account__c]') translatedErrorMessage = 'Unable to locate customer in Salesforce: [Account.Customer_Number__c]';
        else if (errorMessage == 'Every asset needs an account, a contact, or both.: Account ID, Contact ID') translatedErrorMessage = 'Unable to locate customer in Salesforce: [Account.Customer_Number__c]';
        else if (errorMessage == 'Required fields are missing: [Product__c]') translatedErrorMessage = 'Unable to locate product in Salesforce: [Product2.Name]';
        return translatedErrorMessage;
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
}