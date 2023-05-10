public class MACustomMassActionController 
{
    private map<string,string> PageParameters = ApexPages.currentPage().getParameters();
    
    private set<string> RecordIds = new set<string>();
    
    public boolean zipConflict {get;set;}
    
    public string conflictResolution {get;set;}
    
    public string actionTaken {get;set;}

    public TMT__c CustomTMT {get; set;}
    
    public string TMTBatchProcessId {get; set;}
    /*
     * ctor
     */
    public MACustomMassActionController()
    {   
        system.debug('Page Refresh');
        //this.zipConflict = false;
        if (PageParameters.containsKey('ids'))
        {
            RecordIds.addAll(PageParameters.get('ids').split(','));
            
            if (RecordIds.size() > 10000)
            {
                
                AddPageMessage(ApexPages.severity.ERROR, 'Max number of records is 10,000');
            }
            else
            {
                AddPageMessage(ApexPages.severity.Info, 'Number of Zips Selected: ' + string.valueOf(RecordIds.size()));
                CustomTMT = new TMT__c();
            }
        }
    }
    
    /*
     * validate sales credit number
     */
    public boolean isValidSalesCreditNumber() {
        string currentSCID = CustomTMT.sales_credit_number__c;
        system.debug('Checking SCID : ' + currentSCID);
        if (currentSCID == null || string.isBlank(currentSCID)) {
            return false;
        }
        
        for (Sales_credit_id__c scids : [select id from Sales_Credit_ID__c where sales_credit_number__c = :currentSCID]) {
            return true;
        }
        
        return false;

    }
    
    public PageReference checkMarketConflict() {
        
        //zipConflict = tids.size() > 0 ? true : false;
        
        return null;    
    }
    
    public void doSaveWithRedirect() {
        try {
            if (RecordIds.size() > 0 & RecordIds.size() <= 10000) {
                
                if (actionTaken == 'None') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an action.'));
                } else {
                    if (actionTaken == 'Create') {
                        boolean errorFlag = false;
                        
                        if ( CustomTMT.Market__c == null) {
                            errorFlag = true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Market.'));
                        }
                        
                        if (!isValidSalesCreditNumber()) {
                            string m = 'Blank';
                            if (customTMT.Sales_Credit_Number__c != null && !string.isblank(customtmt.sales_credit_number__c)) {
                                m = customTMT.sales_credit_number__c;
                            }
                            
                            errorFlag = true;
                            apexPages.addmessage(new apexpages.message(apexpages.severity.error, m + ' is not a valid Sales Credit Number'));
                        }
                        
                        if (!errorFlag) {
                            list<string> ZipList = new list<string>();
                            
                            map<string, string> ZipCountryMap = new map<string, string>();
                            map<string, string> ZipNameMap = new map<string, string>();
                            
                            for (MapAnything_Zip_Centroid__c zip : [SELECT Id, Name, country__c, country2__c, Substring__c FROM MapAnything_Zip_Centroid__c WHERE Id IN :RecordIds]) 
                            {
                                if (zip.Country2__c == 'MEX')
                                {
                                    ZipList.add(string.valueOf(zip.Substring__c));
                                    ZipCountryMap.put(string.valueOf(zip.Substring__c),zip.country2__c);
                                    ZipNameMap.put(string.valueOf(zip.Substring__c), zip.Name);
                                }
                                else
                                {
                                    ZipList.add(zip.Name);
                                    ZipCountryMap.put(zip.name,zip.country2__c);
                                    ZipNameMap.put(zip.Name, zip.Name);
                                }
                            }
                            
                            list<TMT__c> ExistingTMTs = new list<TMT__c>();
                             
                            map<string, TMT__c> ExistingTMTZipMap = new map<string, TMT__c>();
                            
                            for (TMT__c tmt : [ SELECT 
                                                    Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c, state__c
                                                FROM 
                                                    TMT__c 
                                                WHERE 
                                                    Market__c = :CustomTMT.Market__c 
                                ]) {
                                ExistingTMTZipMap.put(tmt.Zip_Postal_Code__c, tmt);
                            }
                            
                            list<TMT__c> NewTMTS = new list<TMT__c>();
                            
                            for (string zip : ZipList) {
                                boolean AlreadyExists = false;
                                system.debug('Conflict Resolution : ' + conflictResolution);
                                
                                if (ExistingTMTZipMap.containsKey(zip))
                                {
                                    if (conflictResolution == null || conflictResolution == 'none')
                                    {
                                        system.debug('Zips Already Exist, no conflict Resolution');
                                        AlreadyExists = true;
                                        zipConflict = true;
                                    } else if (conflictResolution == 'exclude') {
                                        system.debug('Zip Already Exist, do not include : ' + zip);
                                        AlreadyExists = true;
                                    } else if (conflictResolution == 'update') {
                                        system.debug('Zip already exist, updating existing tmt' + ExistingTMTZipMap.get(zip));
                                        AlreadyExists = true;
                                        ExistingTMTZipMap.get(zip).zip_postal_code__c = zip;
                                        ExistingTMTZipMap.get(zip).Sales_Credit_Number__c = CustomTMT.Sales_Credit_Number__c;
                                        NewTMTS.add(ExistingTMTZipMap.get(zip));
                                    }
                                }
                                //system.debug('Conflict Resolution ' + conflictResolution);
                                if (!AlreadyExists) {
                                    TMT__c NewTMT = new TMT__c();
                                    NewTMT.Market__c = CustomTMT.Market__c;
                                    NewTMT.Sales_Credit_Number__c = CustomTMT.Sales_Credit_Number__c;
                                    NewTMT.Zip_Postal_Code__c = zip;
                                    NewTMT.MATest__c = true;
                                    NewTMT.country__c = ZipCountryMap.get(zip);
                                    NewTMT.country2__c = ZipCountryMap.get(zip);
                                    if (ZipCountryMap.get(zip) == 'MEX') {
                                        NewTMT.state__c = ZipNameMap.get(zip);
                                    }
                                    
                                    NewTMTS.add(NewTMT);
                                }
                            }
                            
                            boolean OKToSave = true;
                            
                            if (newTMTS.size() == 0)
                            {
                                OKToSave = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No TMTs to create/update.'));
                            }

                            if (zipList.size() == 0)
                            {
                                OKToSave = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Zips were selected.'));
                            }
                            
                            if (OKToSave) {

                                TMTBatchProcessId = Database.executeBatch(new TMTCreateBatchJob(newTMTs), 200);
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Creating Records...'));
                            }
                        }
                    } else if (actionTaken == 'Delete') {
                        boolean errorFlag = false;
    
                        if (CustomTMT.Market__c == null) {
                            errorFlag = true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Market.'));
                        }
                        
                        if (!errorFlag) {
                            list<string> ZipList = new list<string>();
                            
                            for (MapAnything_Zip_Centroid__c zip : [SELECT Id, Name FROM MapAnything_Zip_Centroid__c WHERE Id IN :RecordIds])
                            {
                                ZipList.add(zip.Name);
                            }
                            
                            list<TMT__c> ExistingTMTs = new list<TMT__c>();
                            
                            for (TMT__c tmt : [SELECT Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c 
                                                FROM TMT__c WHERE Market__c = :CustomTMT.Market__c AND Sales_Credit_Number__c = :CustomTMT.Sales_Credit_Number__c AND Zip_Postal_Code__c IN :ZipList])
                            {
                                ExistingTMTs.add(tmt);
                            }

                            
                            TMTBatchProcessId = Database.executeBatch(new TMTDeleteBatchJob(ExistingTMTs), 200);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Deleting Records...'));
                        }                        
                    }
                }
            } else {
                AddPageMessage(ApexPages.severity.ERROR, 'Max number of records is 10,000, Please reduce the number of zip codes to process');
            }
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getTypeName()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getStackTraceString()));
        }
    }
    
    /*
     *
     */
    public PageReference validateZips (){
        
        //system.debug('ValidateZip PageParameters id size : ' + PageParameters.get('ids').split(',').size());
        
        if(actionTaken == 'Delete') {
            this.zipConflict = false;
            return null;
        }
        
        if (RecordIds.size() > 10000) {
            this.zipConflict = null;
            AddPageMessage(ApexPages.severity.ERROR, 'Max number of records is 10,000');
            return null;
        }

        list<string> ZipList = new list<string>();
        
        // get zips
        for (MapAnything_Zip_Centroid__c zip : [SELECT Id, Name FROM MapAnything_Zip_Centroid__c WHERE Id IN :RecordIds]) {
            ZipList.add(zip.Name);
        }
        
        // get existing tmt's for this market
        map<string, TMT__c> ExistingTMTZipMap = new map<string, TMT__c>();
        for (TMT__c tmt : [ SELECT 
                                Id, Name, Market__c, Channel_Partner__c, User__c, Sales_Credit_Number__c, Zip_Postal_Code__c, state__c
                            FROM 
                                TMT__c 
                            WHERE 
                                Market__c = :CustomTMT.Market__c 
            ]) {
            ExistingTMTZipMap.put(tmt.Zip_Postal_Code__c, tmt);
        }
        
        map<string, set<string>> scIdZips = new Map<string, set<string>>();
        for (string zip : ZipList) {
            //system.debug('Test ' + zip);
            //boolean AlreadyExists = false;
        
            if (ExistingTMTZipMap.containsKey(zip)) {
                string salescrnum = existingTMTZipMap.get(zip).Sales_Credit_Number__c;
                if (!scIdZips.containsKey(salescrnum)){
                    set<string> s2z = new set<string>{zip};
                    scidzips.put(salescrnum, s2z);
                } else {
                    set<string> s2z = scidzips.get(salescrnum);
                    s2z.add(zip);
                }
            }
        }
        
        this.zipConflict = false;
        //AlreadyExists = false;
        for (string scnum : scIdZips.keySet()){
            this.zipConflict = true;
            //AlreadyExists = true;
            string mStr = scnum + ' - <br>';
            for (string z : scidZips.get(scnum)){
                mStr += z + ', ';
            }
            mStr.removeEnd(',');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Zip Codes Already Exist for Sales Credit Number : ' + mStr));
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Zip Codes Valid'));
        return null;
    }
    
    public list<selectoption> getConflictRes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('none','---Select an Action---'));
        options.add(new SelectOption('update','Update existing records'));
        options.add(new SelectOption('exclude','Exclude conflicting records'));
        return options;
    }
    
    public List<SelectOption> getActions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','---Select an Action---'));
        options.add(new SelectOption('Create','Create'));
        options.add(new SelectOption('Delete','Delete'));
        return options;
    }

    public List<SelectOption> getMarkets() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('None','---Select a Market---'));
        
        for (Market__c mkt : [SELECT Id, Name FROM Market__c ORDER BY Name])
        {
            options.add(new SelectOption(mkt.Id, mkt.Name));
        }
        
        return options;
    }    
    
    /*
        Usage:
        AddPageMessage(ApexPages.severity.CONFIRM, 'MESSAGE_HERE');
        AddPageMessage(ApexPages.severity.ERROR, 'MESSAGE_HERE');
        AddPageMessage(ApexPages.severity.FATAL, 'MESSAGE_HERE');
        AddPageMessage(ApexPages.severity.INFO 'MESSAGE_HERE');
        AddPageMessage(ApexPages.severity.WARNING 'MESSAGE_HERE');
    */
    public void AddPageMessage(ApexPages.severity Severity, string Summary)
    {
        ApexPages.addmessage(new ApexPages.message(Severity,Summary));
    }    
}