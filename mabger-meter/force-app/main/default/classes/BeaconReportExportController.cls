public without sharing class BeaconReportExportController {

    public String fileName {get; set;}
    public String fileData {get; set;}
    
    public String closeCommand {get; set;}

    private String customerNumber;
    private String startYearAndMonth;
    private String endYearAndMonth;
    private String assetSerialNumberFilter;
    private String interval;
    

    public BeaconReportExportController () {
        Map <String, String> parameters = ApexPages.currentPage().getParameters();
        
        customerNumber              = parameters.get('customerNumber');
        startYearAndMonth           = parameters.get('startYearAndMonth');
        endYearAndMonth             = parameters.get('endYearAndMonth');
        assetSerialNumberFilter     = parameters.get('assetSerialNumberFilter');
        interval                    = parameters.get('interval');
        
        String reportType           = parameters.get('reportType');

        if      (reportType == 'consumption')                       createConsumptionExport();
        else if (reportType == 'consumptionDetail')                 createConsumptionDetailExport();
        else if (reportType == 'purchaseHistory')                   createPurchaseUnitExport();
        else if (reportType == 'purchaseHistoryDistributorUD,IR')   createPurchaseUnitWithDistributorExport();
    }


    private void createConsumptionExport () {
        Id accountId = BeaconHelper.getAccountIdFromCustomerNumber(customerNumber);
    
        BeaconReportingController reportController = new BeaconReportingController(accountId, startYearAndMonth, endYearAndMonth, interval);

        String consumptionData = '';
        Map <String, Map <String, BeaconReportingController.DataInterval>> dataset = reportController.dataset;
        Set <String> productSet = reportController.productsSet;
        BeaconReportingController.DataInterval dataInterval;

        // Build the header.
        consumptionData += 'Product';
        for (String interval : dataset.keySet()) consumptionData += (','+interval);
        consumptionData += '\n';

        for (String product : productSet) {
            consumptionData += (product + '\n');

            consumptionData += 'Assets';
            for (String interval : dataset.keySet()) {
                dataInterval = dataset.get(interval).get(product);
                consumptionData += (','+dataInterval.assetCount);
            }
            consumptionData += '\n';

            consumptionData += 'Purchased';
            for (String interval : dataset.keySet()) {
                dataInterval = dataset.get(interval).get(product);
                consumptionData += (','+dataInterval.purchased);
            }
            consumptionData += '\n';

            consumptionData += 'Consumed';
            for (String interval : dataset.keySet()) {
                dataInterval = dataset.get(interval).get(product);
                consumptionData += (','+dataInterval.consumption);
            }
            consumptionData += '\n';

            consumptionData += 'Remaining';
            for (String interval : dataset.keySet()) {
                dataInterval = dataset.get(interval).get(product);
                consumptionData += (','+dataInterval.remaining);
            }
            consumptionData += '\n';
        }


        fileName = 'Consumption - '+customerNumber+' '+startYearAndMonth+' to '+endYearAndMonth;
        fileData = consumptionData;
    }


    private void createConsumptionDetailExport () {
        Integer pageNumber = 0;
        Integer pageSize = 100000;

        fileName = 'Consumption Detail - '+customerNumber+' '+startYearAndMonth+' to '+endYearAndMonth+ (String.isBlank(assetSerialNumberFilter) ? '' : ' for '+assetSerialNumberFilter);
        fileData = BeaconHelper.getConsumptionDetailCSVExportData(customerNumber, startYearAndMonth, endYearAndMonth, (String.isBlank(assetSerialNumberFilter) ? '' : assetSerialNumberFilter), pageNumber, pageSize);
    }


    private void createPurchaseUnitExport () {
        Id      accountId   = BeaconHelper.getAccountIdFromCustomerNumber(customerNumber);
        Date    startDate   = BeaconHelper.getDateFromString(startYearAndMonth, true);
        Date    endDate     = BeaconHelper.getDateFromString(endYearAndMonth, false);

        fileName = 'Purchase Unit - '+customerNumber+' '+startYearAndMonth+' to '+endYearAndMonth;
        fileData = BeaconHelper.getPurchaseUnitExport(accountId, startDate, endDate);
    }


    private void createPurchaseUnitWithDistributorExport () {
        Id      accountId   = BeaconHelper.getAccountIdFromCustomerNumber(customerNumber);
        Date    startDate   = BeaconHelper.getDateFromString(startYearAndMonth, true);
        Date    endDate     = BeaconHelper.getDateFromString(endYearAndMonth, false);

        fileName = 'Purchase Unit With Distributor - '+customerNumber+' '+startYearAndMonth+' to '+endYearAndMonth;
        fileData = BeaconHelper.getPurchaseUnitWithDistributorExport(accountId, startDate, endDate);
    }
}