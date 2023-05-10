public class BeaconReportingController {

    private String accountID;
    
    public Account account 		{get; set;}
    public String reportType	{get; set;}
    public String interval		{get; set;}
    public String display		{get; set;}
    public Integer pageNumber   {get; set;}
    public Integer pageSize     {get; set;}


    public Integer totalDetailItems   {get; set;}
    public Integer totalDetailPages   {get; set;}

    
    public Date startDate	{get; set;}
    public Date endDate		{get; set;}
    
    public String assetSerialNumberFilter {get; set;}
    
    public List <String> intervalList {get; set;}
    
    private String queryFilter;
    
    public Map <String, Map <String, DataInterval>> dataset {get; set;}
    
    public Set <String> 	productsSet 	{get; set;}
    public String 			products 		{get; set;}
    
    public Integer increment {get; set;}

    public Integer chartWidth {get; set;}
    public Integer chartHeight {get; set;}

    public BeaconHelper.ConsumptionDetailReportProgress consumptionDetailReportProgress {get; set;}

    public BeaconReportingController () {

        //totalDetailPages = 1;

    	getParameters();
        getAccount();
        
        loadReportData();
    }


    public BeaconReportingController (String accountID, String startDate, String endDate, String interval) {
        setParameters(accountID, startDate, endDate, interval);
        getAccount();
        loadReportData();
    }

    public Boolean getUserHasPermissionSet () {
        return BeaconHelper.hasPermissionSet();
    }
    
    
    @TestVisible
    private void loadReportData () {   
        if (reportType == 'consumption') {
        	increment = 0;
            getIntervalRange();
            getIntervalRangeQueryFilter();
            compileProducts();
            primeDataMaps();
            compileAssets();
            summarizeConsumptionData();
        	summarizePurchaseUnitData();
            calculateRunningRemainingPurchaseUnits();
        }
        else if (reportType == 'consumptionDetailBig') {
            startConsumptionDetailsReport();
        }
    }
    
    public String getReportTypeTitleLabel () {
        if 		(reportType == 'consumption') 		return 'Consumption';
        else return '';
    }
    
    public String getIntervalTitleLabel () {
        if 		(interval == 'month') 		return 'Monthly';
        else if (interval == 'quarter') 	return 'Quarterly';
        else if (interval == 'annual') 		return 'Annually';
        else return '';
    }
    
    public String getIntervalLabel () {
        if 		(interval == 'month') 		return 'Month';
        else if (interval == 'quarter') 	return 'Quarter';
        else if (interval == 'annual') 		return 'Year';
        else return '';
    }
    
    @TestVisible
    private String getIntervalField () {
        if 		(interval == 'month') 		return 'Year_and_Month_Group_By__c';
        else if (interval == 'quarter') 	return 'Year_and_Quarter_Group_By__c ';
        else if (interval == 'annual') 		return 'Year_Group_By__c';
        else return '';
    }
    
    
    
    private void summarizeConsumptionData () {
        //Map <String, Integer> cumulativeConsumptionByProduct = BeaconHelper.getCumulativeConsumption(accountId, getYearAndMonth(startDate));
        //Set <String> initializedProducts = new Set <String> ();

        for (Consumption_Summary__c consumptionSummaryRecord : getConsumptionSummaryData()) {
            
            String intervalKey = getIntervalKey(consumptionSummaryRecord.Year__c+'', consumptionSummaryRecord.Year_and_Quarter__c, consumptionSummaryRecord.Year_and_Month__c);
			
			Map <String, DataInterval> productConsumption = dataset.get(intervalKey);
            DataInterval dataInterval = productConsumption.get(consumptionSummaryRecord.Product_Name__c);
               
            Integer consumed = Integer.valueOf(consumptionSummaryRecord.Quantity__c);
            //Integer consumedCumulative = Integer.valueOf((consumptionSummaryRecord.Running_Quantity__c == null ? consumed : consumptionSummaryRecord.Running_Quantity__c));

            dataInterval.consumption += consumed;

            /*
            if (initializedProducts.contains(consumptionSummaryRecord.Product__c)) dataInterval.consumptionCumulative += consumed;
            else {
                Integer cumulative = 0;
                if (cumulativeConsumptionByProduct.containsKey(consumptionSummaryRecord.Product__c)) cumulative = cumulativeConsumptionByProduct.get(consumptionSummaryRecord.Product__c);
                dataInterval.consumptionCumulative = cumulative;
                initializedProducts.add(consumptionSummaryRecord.Product__c);
            }
            */
        }
    }
    
  	private void summarizePurchaseUnitData () {
        //Map <String, Integer> cumulativePurchaseByProduct = BeaconHelper.getCumulativePurchase(accountId, getYearAndMonth(startDate));
        //Set <String> initializedProducts = new Set <String> ();

        for (Purchase_Unit_Summary__c purchaseUnitSummaryRecord : getPurchaseUnitSummaryData()) {
            
            String intervalKey = getIntervalKey(purchaseUnitSummaryRecord.Year__c+'', purchaseUnitSummaryRecord.Year_and_Quarter__c, purchaseUnitSummaryRecord.Year_and_Month__c);
            
            Map <String, DataInterval> productPurchaseUnit = dataset.get(intervalKey);
            DataInterval dataInterval = productPurchaseUnit.get(purchaseUnitSummaryRecord.Product_Name__c);
               
            Integer purchased = Integer.valueOf(purchaseUnitSummaryRecord.Quantity__c);
            //Integer purchasedCumulative = Integer.valueOf((purchaseUnitSummaryRecord.Running_Quantity__c == null ? purchased : purchaseUnitSummaryRecord.Running_Quantity__c));

            dataInterval.purchased += purchased;
            //dataInterval.purchasedCumulative += purchasedCumulative;
            //dataInterval.remaining = dataInterval.purchasedCumulative - dataInterval.consumption;
            /*
            if (initializedProducts.contains(purchaseUnitSummaryRecord.Product__c)) dataInterval.purchasedCumulative += purchased;
            else {
                Integer cumulative = 0;
                if (cumulativePurchaseByProduct.containsKey(purchaseUnitSummaryRecord.Product__c)) cumulative = cumulativePurchaseByProduct.get(purchaseUnitSummaryRecord.Product__c);
                dataInterval.purchasedCumulative = cumulative;
                initializedProducts.add(purchaseUnitSummaryRecord.Product__c);
            }
            */
        }
    }
    
    @TestVisible
    private String getIntervalKey (String year, String yearAndQuarter, String yearAndMonth) {
        if 		(interval == 'month') 		return yearAndMonth;
        else if (interval == 'quarter') 	return yearAndQuarter;
        else if (interval == 'annual')		return year;
        else 								return 'invalid';
    }
    
    
    private void compileProducts () {
        
        if (productsSet == null) productsSet = new Set <String> ();
        productsSet.clear();
        
        
        
        String consumptionSummaryQuery = 'Select Product__r.Name ProductName, Count(Product__c) From Consumption_Summary__c Where Product__c != null And Account__c = \''+ accountId +'\' '+ queryFilter +' Group By Product__r.Name';
        for (AggregateResult row : Database.query(consumptionSummaryQuery)) {
            String productName = (String) row.get('ProductName');
            productsSet.add(productName);
        }
                                          
        String purchaseUnitSummaryQuery = 'Select Product__r.Name ProductName, Count(Product__c) From Purchase_Unit_Summary__c Where Product__c != null And Account__c = \''+ accountId +'\' '+ queryFilter +' Group By Product__r.Name';
        for (AggregateResult row : Database.query(purchaseUnitSummaryQuery)) {
            String productName = (String) row.get('ProductName');
            productsSet.add(productName);
        }
        
        products = '';
        Integer i = 0;
        for (String productName : productsSet) {
            if (i > 0) products += ',';
            products += productName;
            i++;
        }
    }
    
    
    private void compileAssets () {
        // NEED TO FIND A NEW WAY TO COUNT ASSETS
        String query = 'Select '+ getIntervalField() +' Interval, Product__r.Name Product, Max(Active_Assets__c) AssetCount From Consumption_Summary__c Where Account__c = \''+ accountId +'\' '+ queryFilter +' Group By '+ getIntervalField() +', Product__r.Name';
        for (AggregateResult row : Database.query(query)) {
            String interval 	= (String) row.get('Interval');
            String product		= (String) row.get('Product');
            Integer assetCount 	= Integer.valueOf(row.get('AssetCount'));
            
            dataset.get(interval).get(product).assetCount = assetCount;
        }
    }
    
    
    public List <Consumption_Summary__c> getConsumptionSummaryData () {        
        String query = 'Select Account__c, Year__c, Year_and_Quarter__c, Year_and_Month__c, Quarter__c, Month__c, Product__c, Product_Name__c, Quantity__c, Running_Quantity__c From Consumption_Summary__c Where Account__c = \''+ accountId +'\' '+ queryFilter;
        return Database.query(query);
    }
    
    
    public List <Purchase_Unit_Summary__c> getPurchaseUnitSummaryData () {   
        String query = 'Select Account__c, Year__c, Year_and_Quarter__c, Year_and_Month__c, Quarter__c, Month__c, Product__c, Product_Name__c, Quantity__c, Running_Quantity__c From Purchase_Unit_Summary__c Where Account__c = \''+ accountId +'\' '+ queryFilter;
        return Database.query(query);
    }
    
    
    
    private void primeDataMaps () {
        
        if (dataset == null) dataset = new Map <String, Map <String, DataInterval>> ();
        dataset.clear();
        
        for (String interval : intervalList) {
            Map <String, Integer> consumptionProductMap = new Map <String, Integer> ();
            Map <String, Integer> purchaseUnitProductMap = new Map <String, Integer> ();
            Map <String, DataInterval> dataProductMap = new Map <String, DataInterval> ();
            
            for (String product : productsSet) {
                consumptionProductMap.put(product, 0);
                purchaseUnitProductMap.put(product, 0);
                dataProductMap.put(product, new DataInterval());
            }
            
            dataset.put(interval, dataProductMap);
        }
    }
    

    private void calculateRunningRemainingPurchaseUnits () {
        String yearAndMonth = getYearAndMonth(startDate);
        //System.debug('START: '+ yearAndMonth);
        Map <String, Integer> cumulativeConsumptionByProduct = BeaconHelper.getCumulativeConsumption(accountId, yearAndMonth);
        Map <String, Integer> cumulativePurchaseByProduct = BeaconHelper.getCumulativePurchase(accountId, yearAndMonth);

        Set <String> productIds = new Set <String> ();
        productIds.addAll(cumulativeConsumptionByProduct.keySet());
        productIds.addAll(cumulativePurchaseByProduct.keySet());

        Map <String, Id> productIdsByName = new Map <String, Id> ();
        for (Product2 product : [Select Id, Name From Product2 Where Name in :productsSet]) productIdsByName.put(product.Name, product.Id);

        Map <String, Integer> remainingByProduct = new Map <String, Integer> ();
        
        for (String productId : productIds) {
            Integer consumed    = cumulativeConsumptionByProduct.containsKey(productId) ? cumulativeConsumptionByProduct.get(productId) : 0;
            Integer purchased   = cumulativePurchaseByProduct.containsKey(productId) ? cumulativePurchaseByProduct.get(productId) : 0;

            Integer total = purchased - consumed;
            remainingByProduct.put(productId, total);
            //System.debug('REMAINING BASE: '+ productId +' : '+ total);
        }

        //Map <String, Integer> remainingByProduct = new Map <String, Integer> ();
        for (String interval : dataset.keySet()) {
            Map <String, DataInterval> intervalMap = dataset.get(interval);
            for (String productName : intervalMap.keySet()) {
                
                Id productId = productIdsByName.get(productName);

                DataInterval dataInterval = intervalMap.get(productName);

                if (!remainingByProduct.containsKey(productId)) remainingByProduct.put(productId, 0);
                
                Integer runningTotal = remainingByProduct.get(productId);
                
                Integer difference = dataInterval.purchased - dataInterval.consumption;
                dataInterval.remaining = runningTotal + difference;

                //System.debug(interval+':'+ productId +':'+productName+': R['+ runningTotal +'] + (P['+dataInterval.purchased+'] - C['+dataInterval.consumption+'] = '+difference+'), '+dataInterval.remaining);
                
                runningTotal = dataInterval.remaining;
                
                remainingByProduct.put(productId, runningTotal);
            }
        }
    }
    
    
    private void getIntervalRange () {
        if (interval == 'month') {
            intervalList = getMonthRange(startDate, endDate);
        }
        else if (interval == 'quarter') {
            intervalList = getQuarterRange(startDate, endDate);
        }
        else if (interval == 'annual') {
            intervalList = getYearRange(startDate, endDate);
        }
    }
    
    
    private void getIntervalRangeQueryFilter () {
        if (interval == 'month') {
            queryFilter = 'And Year_and_Month__c in ('+ writeIntervalRange() +') ';
        }
        else if (interval == 'quarter') {
            queryFilter = 'And Year_and_Quarter__c in ('+ writeIntervalRange() +') ';
        }
        else if (interval == 'annual') {
            queryFilter = 'And Year__c in ('+ writeIntervalRange() +') ';
        }
        else {
            queryFilter = '';
        }
    }
    
    
    private String writeIntervalRange () {
        String range = '';
        for (Integer i = 0; i < intervalList.size(); i++) {
            if (i != 0) range += ',';
            range += '\''+intervalList[i]+'\'';
        }
        return range;
    }
    
	    
    
    private static List <String> getYearRange (Date startDate, Date endDate) {
        List <String> yearsCovered = new List <String> ();
        Integer startYear = startDate.year();
        Integer endYear = endDate.year();
        Integer yearCount = endYear - startYear;
        for (Integer i = 0; i <= yearCount; i++) yearsCovered.add(String.valueOf(startYear+i));
        return yearsCovered;
    }
    
    public static List <String> getMonthRange (Date startDate, Date endDate) {
        Set <String> monthsCovered = new Set <String> ();
        Integer startYear = startDate.year();
        Integer endYear = endDate.year();
        Integer yearCount = endYear - startYear;
        for (Integer i = 0; i <= yearCount; i++) {
            Integer year = startYear+i;
            for (Integer j = 1; j <= 12; j++) {
                Date testDate = Date.newInstance(year, j, 1);
                if (testDate >= startDate && testDate <= endDate) monthsCovered.add(testDate.year()+'-'+((testDate.month()+'').leftPad(2, '0')));
            }
        }
        return new List <String> (monthsCovered);
    }
    
    public static List <String> getQuarterRange (Date startDate, Date endDate) {
        Set <String> quartersCovered = new Set <String> ();
        Integer startYear = startDate.year();
        Integer endYear = endDate.year();
        Integer yearCount = endYear - startYear;
        for (Integer i = 0; i <= yearCount; i++) {
            Integer year = startYear+i;
            for (Integer j = 1; j <= 12; j++) {
                Date testDate = Date.newInstance(year, j, 1);
                if (testDate >= startDate && testDate <= endDate) quartersCovered.add(testDate.year()+'-'+getQuarter(testDate.month()));
            }
        }
        return new List <String> (quartersCovered);
    }
    
    
    public Integer consumptionDataLength {get; set;}
    
    
    
    
    private void getParameters () {
        Map <String, String> parameters = ApexPages.currentPage().getParameters();
        accountID = parameters.get('accountID');
        getStartAndEndDates(parameters.get('startDate'), parameters.get('endDate'));
        reportType = parameters.get('reportType');
        interval = parameters.get('interval');
        display = parameters.get('display');
        assetSerialNumberFilter = parameters.get('assetSerialNumberFilter');
        pageNumber = tryParse(parameters.get('pageNumber'), 0);
        pageSize = tryParse(parameters.get('pageSize'), 100);
        chartWidth = tryParse(parameters.get('chartWidth'), 800);
        chartHeight = tryParse(parameters.get('chartHeight'), 550);
    }

    private void setParameters (String accountID, String startDate, String endDate, String interval) {
        this.accountID = accountID;
        getStartAndEndDates(startDate, endDate);
        this.reportType = 'consumption';
        this.interval = interval;
        this.display = 'table';
        this.pageNumber = 0;
        this.pageSize = 100;
    }


    private Integer tryParse (String value, Integer defaultValue) {
        if (!String.isBlank(value)) {
            try {
                return Integer.valueOf(value);
            }
            catch (Exception ex) {
                return defaultValue;
            }
        }
        else {
            return defaultValue;
        }
    }
    
    
    private void getAccount () {
        account = [Select Id, Name, Customer_Number__c From Account Where Id = :accountID];
    }
    
    
    private void getStartAndEndDates (String inputStartDate, String inputEndDate) {
        String cleanStartDateString = getCleanDateString(inputStartDate);
        Date trialStartDate = BeaconHelper.getDateFromString(cleanStartDateString, true);
       	
        String cleanEndDateString = getCleanDateString(inputEndDate);
        Date trialEndDate = BeaconHelper.getDateFromString(cleanEndDateString, false);
        
        if (trialStartDate != null && trialEndDate != null && trialStartDate <= trialEndDate) {
            startDate = trialStartDate;
            endDate = trialEndDate;
            System.debug('INFO: Start and End Dates are valid: '+ startDate +' to '+endDate);
        }
        else {            
            Date currentDate = Date.today();
            startDate = Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()).toStartOfMonth();
        	endDate = Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()).addMonths(1).toStartOfMonth().addDays(-1);
            System.debug('WARNING: Start and End Dates are not valid. Using current month start and end: '+ startDate +' to '+ endDate);
        }
    }
    
    
    private String getCleanDateString (String input) {
        if (!String.isBlank(input)) {
            //return input.replaceAll('-', '/');
            return input;
        }
        else {
            return '';
        }
    }
    
    
    
    
    
    private static String getQuarter (Decimal month) {
        if (month >= 1 && month <= 3) return 'Q1';
        else if (month >=4 && month <= 6) return 'Q2';
        else if (month >= 7 && month <= 9) return 'Q3';
        else if (month >= 10 && month <= 12) return 'Q4';
        else return '';
    }
    
    
    public class DataInterval {
        public Integer assetCount 	{get; set;}
        public Integer consumption 	{get; set;}
        //public Integer consumptionCumulative {get; set;}
        public Integer purchased 	{get; set;}
        //public Integer purchasedCumulative {get; set;}
        public Integer remaining	{get; set;}
        
        public DataInterval () {
            this.assetCount 		= 0;
            this.consumption 		= 0;
            //this.consumptionCumulative = 0;
            this.purchased	 		= 0;
            //this.purchasedCumulative = 0;
            this.remaining	 		= 0;
        }
    }
    
    
	/*
    public List <Consumption_Summary__c> getConsumptionDetails () {
        // TO BE REPLACE BY REST CALL, POPULATED WITH RETURNED DATA!
        //And Month_Start__c >= '+ startDate +' And Month_Start__c <= '+ endDate
        String query = 'Select Id, Product_Number__c, Consumption_Type__c, Serial_Number__c, Quantity__c, Month_Start__c, Asset__r.Status, Asset__r.Cadence__c, Asset__r.Tag_1__c, Asset__r.Tag_2__c, Asset__r.Route__c From Consumption_Summary__c Where Account__c = \''+ accountId +'\' ' + (!String.isBlank(assetSerialNumberFilter) ? ' And Serial_Number__c = \''+ assetSerialNumberFilter +'\' ' : '') +' Order By Month_Start__c, Product_Number__c';
        return Database.query(query);
    }
    
    
    public List <AssetDetail> getConsumptionDetails2 () {
        ConsumptionDetailRequest requestBody = new ConsumptionDetailRequest();
        requestBody.CustomerNumber = Integer.valueOf(account.Customer_Number__c);
        requestBody.StartMonth = getYearAndMonth(startDate);
        requestBody.EndMonth = getYearAndMonth(EndDate);
        requestBody.SerialNumber = String.isBlank(assetSerialNumberFilter) ? null : assetSerialNumberFilter;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('UNKNOWN');
        request.setBody(JSON.serialize(requestBody));
        
        //HttpResponse response = new Http().send(request);
        //String responseBody = response.getBody;
        String responseBody = '{"CustomerNumber":1234,"StartMonth":"2019-09","EndMonth":"2019-09","SerialNumber":null,"ConsumptionDetailRecords":[{"ProductNumber":"68886-101","SerialNumber":"100373251","QuantityConsumed":20,"Year":2019,"Month":9,"Status":"Purchased","Cadence":"","Tag1":"","Tag2":"","Route":""},{"ProductNumber":"68886-101","SerialNumber":"100035977","QuantityConsumed":20,"Year":2019,"Month":9,"Status":"Purchased","Cadence":"","Tag1":"","Tag2":"","Route":""},{"ProductNumber":"68886-101","SerialNumber":"100374131","QuantityConsumed":20,"Year":2019,"Month":9,"Status":"Purchased","Cadence":"","Tag1":"","Tag2":"","Route":""}]}';
        
        ConsumptionDetailResponse consumptionResponse = (ConsumptionDetailResponse)JSON.deserialize(responseBody, ConsumptionDetailResponse.class);
        return consumptionResponse.ConsumptionDetailRecords;
    }
    */
    

    

    public void startConsumptionDetailsReport () {
        consumptionDetailReportProgress = BeaconHelper.startConsumptionDetailReport(account.Customer_Number__c, getYearAndMonth(startDate), getYearAndMonth(endDate));
    }

    public void updateConsumptionDetailsReportProgress () {
        consumptionDetailReportProgress = BeaconHelper.getConsumptionDetailReportProgress(consumptionDetailReportProgress.Id);
    }


    public List <BeaconHelper.ConsumptionDetail> getConsumptionDetails () {
        /*
        System.debug('PN: '+ pageNumber +' / '+ totalDetailPages);
        Integer actualPageNumber = pageNumber;
        if (actualPageNumber < 1) actualPageNumber = 1;
        if (actualPageNumber > totalDetailPages) actualPageNumber = totalDetailPages;

        pageNumber = actualPageNumber;
        */

        BeaconHelper.ConsumptionDetailResponse consumptionDetailResponse = BeaconHelper.getConsumptionDetail(account.Customer_Number__c, getYearAndMonth(startDate), getYearAndMonth(endDate), (String.isBlank(assetSerialNumberFilter) ? '' : assetSerialNumberFilter), pageNumber-1, pageSize);       
        
        totalDetailItems = consumptionDetailResponse.TotalItems;
        if (totalDetailItems == null) totalDetailItems = 0;
        
        Decimal pagesDecimal = ((Decimal)totalDetailItems / (Decimal)pageSize);
        // Come back to this later, find a "middle of the road" approach to showing how many pages there are without breaking the bank.
        totalDetailPages = Integer.valueOf(pagesDecimal.round(RoundingMode.CEILING));
        //totalDetailPages = 1;

        List <BeaconHelper.ConsumptionDetail> consumptionDetails = consumptionDetailResponse.ConsumptionDetailRecords;
        /*
        List <BeaconHelper.ConsumptionDetail> returnedDetails = new List <BeaconHelper.ConsumptionDetail> ();
        if (consumptionDetails.size() > 1000) {
            for (Integer i = 0; i < 1000; i++) returnedDetails.add(consumptionDetails[i]);
        }
        else {
            returnedDetails.addAll(consumptionDetails);
        }
        */
        return consumptionDetails;
    }

    public String getConsumptionDetailExport () {
        return BeaconHelper.getConsumptionDetailCSVExportData(account.Customer_Number__c, getYearAndMonth(startDate), getYearAndMonth(endDate), (String.isBlank(assetSerialNumberFilter) ? '' : assetSerialNumberFilter), pageNumber, pageSize);
    }
    
    
    private String getYearAndMonth (Date inputDate) {
        return inputDate.year() +'-'+ String.valueOf(inputDate.month()).leftPad(2, '0');
    }
    
    /*
    public class ConsumptionDetailRequest {
        public Integer CustomerNumber;
        public String StartMonth;
        public String EndMonth;
        public String SerialNumber;
    }
    public class ConsumptionDetailResponse {
        public Integer CustomerNumber;
        public String StartMonth;
        public String EndMonth;
        public String SerialNumber;
       	public List <AssetDetail> ConsumptionDetailRecords;
    }
    public class AssetDetail {
        public String ProductNumber {get; set;}
        public String SerialNumber {get; set;}
        public Integer QuantityConsumed {get; set;}
        public Integer Year {get; set;}
        public Integer Month {get; set;}
        public String Status {get; set;}
        public String Cadence {get; set;}
        public String Tag1 {get; set;}
        public String Tag2 {get; set;}
        public String Route {get; set;}
        
        public String getYearAndMonth () {
            return Year+'-'+Month+'-01';
        }
    }
    */
    
    public List <Purchase_Unit_Line__c> getPurchaseUnitLines () {
        return BeaconHelper.getPurchaseUnitLines(accountId, startDate, endDate);
    }


    public List <Purchase_Unit_Line__c> getPurchaseUnitLinesDistributor () {
        return BeaconHelper.getPurchaseUnitLinesDistributor(accountId, startDate, endDate);
    }
}