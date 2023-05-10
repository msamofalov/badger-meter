public class BeaconReportingAccountController {

    public Id 		accountId;
    private String customerNumber;
    public String 	reportType				{get; set;}
    public String	interval				{get; set;}
    public String	display					{get; set;}
    public String 	startDate				{get; set;}
    public String 	endDate					{get; set;}
    public String	assetSerialNumberFilter	{get; set;}
    public String   pageNumber              {get; set;}
    public String   pageSize                {get; set;}

    public Integer  pageCount               {get; set;}
    public List <SelectOption> pageNumberOptions {get; private set;}

    private String startYearAndMonth;
    private String endYearAndMonth;
    
    public Integer chartWidth {get; set;}
    public Integer chartHeight {get; set;}

    
    public String	reportURL	{get; set;}

    private Boolean isLoading;
    
    public BeaconReportingAccountController (ApexPages.StandardController controller) {
        accountId = controller.getRecord().Id;
        customerNumber = [Select Customer_Number__c From Account Where Id = :accountId Limit 1][0].Customer_Number__c;
        reportType = 'consumption';
        interval = 'month';
        display = 'chart';

        pageCount = 1;
        pageNumberOptions = new List <SelectOption> ();
        updatePageCount();


		Date currentDate 	= Date.today();        
        Date monthStart 	= Date.newInstance(2016, 4, 1);//Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()).toStartOfMonth(); // 2022-02-24 - Joe Bunda, Allium - Changed to hard-coded start date per Ken's request.
        Date monthEnd 		= Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()).addMonths(1).toStartOfMonth().addDays(-1);
        
        startDate 	= monthStart.year()+'-'+monthStart.month()+'-'+monthStart.day();
        endDate 	= monthEnd.year()+'-'+monthEnd.month()+'-'+monthEnd.day();
        
        System.debug('START DATE: '+startDate);
        
        assetSerialNumberFilter = '';

        isLoading = true;
        
        updateReportFrame();
    }


    public Boolean getIsLoading () {
        return isLoading;
    }

    public void stopLoading () {
        isLoading = false;
    }

    public Boolean getUserHasPermissionSet () {
        return BeaconHelper.hasPermissionSet();
    }
    
    
    public void updateReportFrame () {
        isLoading = true;
        reportURL = '/apex/BeaconReporting?accountID='+ accountId +'&reportType='+ reportType +'&interval='+ interval +'&display='+ display +'&startDate='+ startDate +'&endDate='+ endDate +(!String.isBlank(assetSerialNumberFilter) ? '&assetSerialNumberFilter='+assetSerialNumberFilter : '') +'&pageNumber='+ pageNumber +'&pageSize='+ pageSize +'&chartWidth='+chartWidth +'&chartHeight='+chartHeight;
        System.debug('REPORT URL: '+ reportURL);
    }


    public void updatePageCount () {
        //System.debug('UPDATING PAGE COUNT: '+ pageCount);
        pageNumberOptions.clear();
        for (Integer i = 0; i < pageCount; i++) pageNumberOptions.add(new SelectOption(String.valueOf(i), String.valueOf((i+1))));
    }


    public PageReference exportReport () {
        PageReference pr = new PageReference('/apex/BeaconReportExport');
        pr.getParameters().put('customerNumber', customerNumber);
        pr.getParameters().put('startYearAndMonth', startDate);
        pr.getParameters().put('endYearAndMonth', endDate);
        pr.getParameters().put('assetSerialNumberFilter', assetSerialNumberFilter);
        pr.getParameters().put('reportType', reportType);
        pr.getParameters().put('interval', interval);
        pr.setRedirect(true);
        return pr;
    }

    public void exportBigReport () {
        isLoading = true;
        reportType = 'consumptionDetailBig';
        updateReportFrame();
        reportType = 'consumptionDetail';
    }
    
}