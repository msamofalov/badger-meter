@RestResource(urlMapping='/Beacon/Asset')
global class BeaconAssetREST {

    
    @HttpPost
    global static void doPost (List <Asset> records) {
        
        //BeaconAssetBatch batchJob = new BeaconAssetBatch(records);
        //Database.executeBatch(batchJob);
        //BeaconHelper.createAssetRecords(records);
        
        //return 'OK';
        String results = '';
        Integer statusCode = 200;

        try {
            results = BeaconHelper.createAssetRecords(records);

            // Deserialize and examine the results to determine whether we have full or partial success.
            List <BeaconHelper.AssetResult> assetResults = (List <BeaconHelper.AssetResult>) JSON.deserialize(results, List <BeaconHelper.AssetResult>.class);

            for (BeaconHelper.AssetResult assetResult : assetResults) {
                if (assetResult.result != 'OK') {
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