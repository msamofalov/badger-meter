@RestResource(urlMapping='/Beacon/ConsumptionSummary')
global class BeaconConsumptionSummaryREST {

    @HttpPost
    global static void doPost () {
        
        
        
        //BeaconConsumptionSummaryBatch batchJob = new BeaconConsumptionSummaryBatch(records);
        //Database.executeBatch(batchJob);
        //BeaconHelper.createConsumptionSummaryRecords(records);
        
        //return 'OK';

        String results = '';
        Integer statusCode = 200;

        try {
            RestRequest request = RestContext.request;
            String csvData = request.requestBody.toString();
            
            List <Consumption_Summary__c> records = BeaconHelper.parseConsumptionSummaryRecordsFromCSV(csvData);

            results = BeaconHelper.createConsumptionSummaryRecords(records);

            // Deserialize and examine the results to determine whether we have full or partial success.
            List <BeaconHelper.ConsumptionSummaryResult> consumptionSummaryResults = (List <BeaconHelper.ConsumptionSummaryResult>) JSON.deserialize(results, List <BeaconHelper.ConsumptionSummaryResult>.class);

            for (BeaconHelper.ConsumptionSummaryResult consumptionSummaryResult : consumptionSummaryResults) {
                if (consumptionSummaryResult.result != 'OK') {
                    statusCode = 206;
                    break;
                }
            }
        }
        catch (Exception ex) {
            statusCode = 400;
            results = ex.getMessage();
        }

        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(results);
    }
}