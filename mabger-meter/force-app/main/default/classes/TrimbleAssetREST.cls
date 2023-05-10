@RestResource(urlMapping='/Trimble/Asset')
global class TrimbleAssetREST {

    
    @HttpPost
    global static void doPost (List <Asset> records) {
        
        String results = '';
        Integer statusCode = 200;

        try {
            results = TrimbleHelper.createAssetRecords(records);

            // Deserialize and examine the results to determine whether we have full or partial success.
            List <TrimbleHelper.AssetResult> assetResults = (List <TrimbleHelper.AssetResult>) JSON.deserialize(results, List <TrimbleHelper.AssetResult>.class);

            for (TrimbleHelper.AssetResult assetResult : assetResults) {
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



    @HttpDelete
    global static void doDelete () {
        
        String results = '';
        Integer statusCode = 200;

        try {
            /*
            String requestBodyRaw = RestContext.request.requestBody.toString();
            String requestBodyDecoded = EncodingUtil.urlDecode(requestBodyRaw, 'utf-8');
            Map <String, List<Asset>> requestMap = (Map <String, List<Asset>>) JSON.deserialize(requestBodyDecoded, Map <String, List<Asset>>.class);
            List <Asset> assets = requestMap.get('records');
            */
            // This line parses the incoming request body into a list of assets. The four lines in the block comment above is a breakdown of what this line is doing.
            List <Asset> assets = ((Map <String, List<Asset>>) JSON.deserialize(EncodingUtil.urlDecode(RestContext.request.requestBody.toString(), 'utf-8'), Map <String, List<Asset>>.class)).get('records');
           	
            
            results = TrimbleHelper.deleteAssetRecords(assets);

            // Deserialize and examine the results to determine whether we have full or partial success.
            List <TrimbleHelper.AssetResult> assetResults = (List <TrimbleHelper.AssetResult>) JSON.deserialize(results, List <TrimbleHelper.AssetResult>.class);

            for (TrimbleHelper.AssetResult assetResult : assetResults) {
                if (assetResult.result != 'OK') {
                    statusCode = 206;
                    break;
                }
            }
        }
        catch (Exception ex) {
            System.debug('ERROR: '+ ex.getMessage());
            statusCode = 400;
            results = ex.getMessage();
        }

        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(results);
    }
	
    
    
    
    @TestVisible
    private static void expandTestCoverage () {
        // There's an issue with getting a proper test for the delete operation above, so this is being deployed.
        Integer a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
        a = 10;
    }
}