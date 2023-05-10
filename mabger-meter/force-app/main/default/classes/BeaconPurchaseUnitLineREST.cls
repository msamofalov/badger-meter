@RestResource(urlMapping='/Beacon/PurchaseUnitLine')
global class BeaconPurchaseUnitLineREST {

    @HttpPost
    global static void doPost () {
        
        
        
        //BeaconPurchaseUnitLineBatch batchJob = new BeaconPurchaseUnitLineBatch(lineRecords);
        //Database.executeBatch(batchJob);
        //BeaconHelper.createPurchaseUnitLineAndSummaryRecords(lineRecords);

        //return 'OK';

        Integer statusCode = 200;
        String results = '';

        try {
            RestRequest request = RestContext.request;
            String csvData = request.requestBody.toString();
            
            List <String> lineRecords = BeaconHelper.parsePurchaseUnitLinesFromCSV(csvData);
            //System.debug('LINES: '+ lineRecords);
            results = BeaconHelper.createPurchaseUnitLineAndSummaryRecords(lineRecords);
            

            // Deserialize and examine the results to determine whether we have full or partial success.
            List <BeaconHelper.PurchaseUnitLineResult> purchaseUnitLineResults = (List <BeaconHelper.PurchaseUnitLineResult>) JSON.deserialize(results, List <BeaconHelper.PurchaseUnitLineResult>.class);

            for (BeaconHelper.PurchaseUnitLineResult purchaseUnitLineResult : purchaseUnitLineResults) {
                if (purchaseUnitLineResult.result != 'OK') {
                    statusCode = 206;
                    break;
                }
            }
        }
        catch (Exception ex) {
            statusCode = 400;
            results = ex.getMessage();
            System.debug('ERROR IN BeaconPurchaseUnitLineREST: '+ ex.getMessage());
            System.debug('STACK TRACE: '+ ex.getStackTraceString());
        }

        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(results);

        //BeaconPurchaseUnitLineBatch batchJob = new BeaconPurchaseUnitLineBatch(lineRecords);
        //Database.executeBatch(batchJob);
    }
}