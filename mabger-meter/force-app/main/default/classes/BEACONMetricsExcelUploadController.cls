/***
@Purpose: BEACON Metrics Upload 
@Date: 03/25/2017
@Description
 - Parse Excel - Blob file and parse column data, Add to collection
 - Load into BEACON_Account_Level_Metric__c
 - Account and Product matching update - If Account diff product - then insert
 - Insert any errored records but capture error message and set status
 - Display data in related lists
@TODO - shift to jquery to show the status, display processed but only few records, Display counts -  success as well as failed.
***/

public with sharing class BEACONMetricsExcelUploadController {
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    public String[] filelines {get;set;}
    public List<BEACON_Account_Level_Metric__c> BMetricstoupload {get; set;} //not required
    public List<BEACON_Account_Level_Metric__c> BMetricsLoadsToupload {get; set;}  
    
    Product2 prod = new Product2(); 
    list<String> accounts = new list<String>();       
    list<String> partnums = new list<String>();      
    list<String> BEACONMetrics = new list<String>(); 
    Map<String, Product2> maprod = new Map<String, Product2> ();
    Map<String, BEACON_Account_Level_Metric__c> mapBMetricA = new Map<String, BEACON_Account_Level_Metric__c> ();
    Map<String, BEACON_Account_Level_Metric__c> mapBMetricP = new Map<String, BEACON_Account_Level_Metric__c> ();
    Map<String, Account> mapaccnt = new Map<String, Account> ();
    Set<String> accNumWithProdIN = new Set<String>();
    Map<String,ID> exisitngMetrics = new Map<String,ID>();

    public Integer BMetricsFail {get; set;}
    public Integer BMetricsSuccess {get; set;} 
    public List<BEACON_Account_Level_Metric__c> BMetricsPartialList {get; set;}        
    
    public BEACONMetricsExcelUploadController() {
        BMetricsSuccess = 0;
        BMetricsFail = 0;
    }
    /***
        @Name ReadFile()
        @Purpose: This function reads the CSV file and map columns and perform quick validations 
    ***/
    public Pagereference ReadFile() {
        
        filelines = new String[]{};
        BMetricstoupload = new List<BEACON_Account_Level_Metric__c>(); // not required
        BMetricsPartialList = new List<BEACON_Account_Level_Metric__c>();
        BMetricsLoadsToupload = new List<BEACON_Account_Level_Metric__c>();         
        if (contentFile == null) {
            apexpages.message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please select a file before clicking upload');
            ApexPages.addMessage(errormsg);                             
        } else {
            if (contentFile.toString() == null) {
                apexpages.message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please select a file before clicking upload');
                ApexPages.addMessage(errormsg);        
            } else {
                //Convert the uploaded file which is in BLOB format into a string
                nameFile =blobToString( contentFile,'ISO-8859-1'); 
                //Now sepatate every row of the excel file               
                filelines = nameFile.split('\r\n'); 
               
                    partnums = new List<String>();
                    //Iterate through every line and create a record for each row
                    for (Integer i=1;i<filelines.size();i++) {  
                        system.debug('inside ** - ');
                        String[] inputvalues = new String[]{};
                        inputvalues = filelines[i].split(',');
                        system.debug('inputvalues - '+ inputvalues + ' i - ' + i);
                        
                        BEACON_Account_Level_Metric__c ba = new BEACON_Account_Level_Metric__c();
                            System.debug('inputvalues[0]' + inputvalues[0]);
                            System.debug('inputvalues[1]' + inputvalues[1]);
                            System.debug('inputvalues[2]' + inputvalues[2]);
                            System.debug('inputvalues[3]' + inputvalues[3]);
                            System.debug('inputvalues[4]' + inputvalues[4]);
                            ba.Account_Number__c = inputvalues[0].trim().leftPad(8).replaceAll(' ', '0'); 
                            ba.Product_Type__c = inputvalues[1].trim();     
                            ba.Total_Assets__c = integer.valueof(inputvalues[2].trim()); 
                            ba.Pre_Invoice__c = integer.valueof(inputvalues[3].trim()); 
                            ba.Total_Removed__c = integer.valueof(inputvalues[4].trim()); 
                            ba.Service_Units_Consumed__c = integer.valueof(inputvalues[5].trim());  
                            ba.Billing_Units_Remaining__c = integer.valueof(inputvalues[6].trim()); 
                            ba.Serial_Number__c = inputvalues[7].trim(); 
                            ba.Discontinued__c = Boolean.valueOf(inputvalues[8].trim());  
                            ba.Status__c = 'In Process'; 
                            ba.id=Null; 
                            
                            partnums.add(inputvalues[1].trim()); 
                            accounts.add(inputvalues[0].trim().leftPad(8).replaceAll(' ', '0') ); 
                            
                            BMetricsLoadsToupload.add(ba); 
                            //For Duplicate check
                            accNumWithProdIN.add(ba.Account_Number__c+'_'+ba.Product_Type__c);     
                    }
                    system.debug('== accNumWithProdIN===='+accNumWithProdIN);
                    try{
                        system.debug('BM Metric load');
                        loadBMetrics();     
                        system.debug('BM Metric load after loading bmetrics');
                    }
                    catch (Exception e)
                    {
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
                        ApexPages.addMessage(errormsg);
                        system.debug('BM Metric load after loading bmetrics'+e);
                    }
                    finally {
                        contentFile = null;
                    }     
            } // null                         
        }         
        return null;    
    }
    /***
        @Name: loadBMetrics()
        @Purpose: Check whther Account & Product combination exists then insert or update
    ***/
    public void loadBMetrics() {
        maprod = new Map<string, Product2>();
        mapBMetricA = new Map<string, BEACON_Account_Level_Metric__c>();
        mapBMetricP = new Map<string, BEACON_Account_Level_Metric__c>();
        mapaccnt = new Map<string, Account>();   
        set<string> BMetricExisting = new Set<String>();
        try{
            // Product Lookup
            list<Product2> Prodlst =[select id,Name, ProductCode from product2 where IsActive = true and Name in:partnums];
            for(Product2 p :Prodlst) {
                maprod.put(p.Name,p);
            } 
            system.debug('AAAAA maprod' + maprod);
                         
            list<Account> Acclst =[select id,Name, customer_number__c from Account where customer_number__c in:accounts];     
            for(Account a :Acclst) {
                mapaccnt.put(a.customer_number__c,a);
            }  
            system.debug('==accounts=='+accounts);
            system.debug('==partnums=='+partnums);
            // Duplicate -- i.e. found existing product/account hence update needs to be performed for this list
             list<BEACON_Account_Level_Metric__c> Bmlst =[select id, Account_ID__c,Account_Number__c,Product_Type__c, Item_Number__c from BEACON_Account_Level_Metric__c WHERE Account_Number__c  in:accounts AND  Product_Type__c in:partnums];       
             system.debug('===Bmlst=='+Bmlst);
            for(BEACON_Account_Level_Metric__c a :Bmlst) {
                //Checks whether already exist or not
                if(accNumWithProdIN.contains(a.Account_Number__c+'_'+a.Product_Type__c)){
                   exisitngMetrics.put(a.Account_Number__c+'_'+a.Product_Type__c,a.id) ;
                }
                mapBMetricA.put(a.Account_ID__c,a);
                mapBMetricP.put(a.Item_Number__c,a);
                BMetricExisting.add(a.id);
            }  
            system.debug('AAAAA mapaccnt' + mapaccnt);            
        } catch (Exception e) {
            //ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
            //ApexPages.addMessage(errormsg);
            system.debug('BEACON exception e -' + e);
        }  
        //Associate product id and account id 
        try {
            for (BEACON_Account_Level_Metric__c aload : BMetricsLoadsToupload) {
                //system.debug(' aload.Product_Type__c - ' + aload.Product_Type__c);
                aload.Upload_Error__c = '';
                aload.Status__c = '';
                aload.Processed__c=false;
                //Product
                if ((maprod.get(aload.Product_Type__c)) == null) {
                    aload.Upload_Error__c = 'Product does not exist - Product_Type__c= ' + aload.Product_Type__c;
                    aload.Status__c = 'Failed';
                    aload.Processed__c = false;
                    //Processed__c
                } else {
                    //system.debug(' maprod.get(aload.Product_Type__c).Id - ' + maprod.get(aload.Product_Type__c).Id);
                    aload.Item_Number__c = maprod.get(aload.Product_Type__c).Id;
                    aload.Status__c = 'Processed';
                    aload.Processed__c = true;
                }
                //Account
                if ((mapaccnt.get(aload.Account_Number__c)) == null) {
                    aload.Upload_Error__c =  aload.Upload_Error__c+'Account does not exist - Account_Number__c= ' + aload.Account_Number__c;
                    aload.Status__c = 'Failed';
                    aload.Processed__c = FALSE;
                    //Processed__c
                } else {
                    system.debug(' mapaccnt.get(aload.Account_Number__c).Id - ' + mapaccnt.get(aload.Account_Number__c).Id);
                    aload.Account_ID__c = mapaccnt.get(aload.Account_Number__c).Id;
                    aload.Status__c = 'Processed';
                    aload.Processed__c = true;
                } 
                //matching or duplicate
                 system.debug('===exisitngMetrics =='+exisitngMetrics);                
                if (exisitngMetrics.containsKey(aload.Account_Number__c+'_'+aload.Product_Type__c)) {
                    system.debug('===exisitng =='+aload.Account_Number__c+'_'+aload.Product_Type__c);
                    aload.Id = exisitngMetrics.get(aload.Account_Number__c+'_'+aload.Product_Type__c);
                    //aload.Upload_Error__c =  aload.Upload_Error__c+'Record exists ' + aload.Id;
                }            
            }
        } catch (Exception e) {
            //ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
            //ApexPages.addMessage(errormsg);
            system.debug('finding product exception e -' + e);
        } 
        //
        // Duplicate -- i.e. found existing product/account hence update needs to be performed for this list
        list<String> accounts2 = new list<String>();       
        list<String> partnums2 = new list<String>();         
        for (BEACON_Account_Level_Metric__c aload : BMetricsLoadsToupload) {
            accounts2.add(aload.Account_ID__c);
            partnums2.add(aload.Item_Number__c);
        }
        list<BEACON_Account_Level_Metric__c> Bmlst2 =[select id, Account_ID__c, Item_Number__c from BEACON_Account_Level_Metric__c where  Account_ID__c in:accounts2 and Item_Number__c in:partnums2];       
        for(BEACON_Account_Level_Metric__c a :Bmlst2) {
            system.debug('a.Account_ID__cAAAA-'+ a.Account_ID__c);
        }
        try{
 
        } catch (Exception e) {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
            ApexPages.addMessage(errormsg);
            system.debug('BMMetric load table Upload error exception e -' + e);
        }
        system.debug('BMetricsLoadsToupload2.size()-'+ BMetricsLoadsToupload.size()); 
        //this below if condition for testing only
        if (BMetricsLoadsToupload.size() >0) {
            for (integer i=0; i<BMetricsLoadsToupload.size(); i++) {
                if(i==100) { break;}
                BMetricsPartialList.add(BMetricsLoadsToupload.get(i));
            }
            //BMetricstoupload
            for(BEACON_Account_Level_Metric__c a :BMetricsLoadsToupload) {
                if (a.Processed__c == true) {
                   BMetricsSuccess = BMetricsSuccess+1;
                } else {
                   BMetricsFail = BMetricsFail+1;
                }
            }
        }
        
        //system.debug('BMetricstoupload.size()-'+ BMetricstoupload.size());
        try{
            system.debug(' - BMetricsLoadsToupload-');
            upsert BMetricsLoadsToupload;  
            system.debug(' - DONE-');                   
        }
        catch (Exception e) {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
            ApexPages.addMessage(errormsg);
            system.debug('BMMetric load table Upload error exception e -' + e);
        }                   
    }
    /**
        blobToString - Utility function - This function converts the input CSV file in BLOB format into a string
        @param input    Blob data representing correct string in @inCharset encoding
        @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
        @Todo - Move this to utility class
    */
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }    
}