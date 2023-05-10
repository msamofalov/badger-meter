/* 
  Created By  :  Raja Yeccherla(GearsCRM)
  Created Date: 09/16/2015
  Description :  Helper class for UAccount
 
  Modified By   :   
  Modified Date :   
  Description   :   
*/
global without sharing class UAccount
{

    global  class  UpdateAfterAccount implements gearsBase.gearsExecute.executeMethod
    {
        public void execute(List<SObject> records, Map<Id, sObject> oldMap, gearsBase.gearsExecute.triggerParameters tp)
        {
            System.debug('Start UpdateAccount()');
            updateProductDetails(records, (Map<Id, Account>) oldMap);
        }
    }

    global class UpdateAccountUserTMT implements gearsBase.gearsExecute.executeMethod
    {
        public void execute(List<SObject> records, Map<Id, sObject> oldMap, gearsBase.gearsExecute.triggerParameters tp)
        {
            System.debug('Start UpdateAccountUserTMT()');
            updateAccountOwnerandPSC(records, (Map<Id, Account>) oldMap , tp);
        }
    }
    
    /**
     * getTmTSearch Programmatically constructs the TMT search string
     * @param  acc Account record
     * @return     TMT search string, or 'ERROR' should required fields be missing
     */
    private static string getTmTSearch(Account acc) {
        String tmtSearch = 'ERROR';

        if(acc.BillingCountryCode != null && acc.BillingCountryCode.toUpperCase() == 'US')
        {
            String postalCode = (acc.BillingPostalCode != null && acc.BillingPostalCode.length() >= 5) ? acc.BillingPostalCode.LEFT(5) : 'ERROR';
            tmtSearch = 'USA-' + postalCode;
        }
        else if (acc.BillingCountryCode != null && acc.BillingCountryCode.toUpperCase() == 'CA' )
        {
            String postalCode = (acc.BillingPostalCode != null && acc.BillingPostalCode.length() >= 3) ? acc.BillingPostalCode.LEFT(3) : 'ERROR';
            tmtSearch = 'CAN-' + postalCode;
        }
        else if (acc.BillingState != null && acc.BillingCountryCode != null && acc.BillingCountryCode.toUpperCase() == 'MX' )
        {
            tmtSearch = 'MEX-' + acc.BillingState.toUpperCase();
        }

        return tmtSearch;
    }

    /**
     * updateAccountOwnerandPSC Sets Account fields OwnerId, Primary_Sales_Credit_Number__c, and Sales_Credit_Name__c based on Organization_Type__c mapping and TMT__c records
     * @param  records List of account records for processing
     * @param  oldMap  Trigger.oldMap
     * @param  tp      GearsBase.gearsExecute.triggerParameters
     */
    global static void updateAccountOwnerandPSC(List<Account> records, Map<Id, Account> oldMap, gearsBase.gearsExecute.triggerParameters tp) 
    {
        final String METHOD_TAG = UAccount.class.toString() + '.updateAccountOwnerandPSC';
        System.debug('Start ' + METHOD_TAG);

        Set<String> marketNames = new Set<String> ();
        Set<String> tmtSearch = new Set<String> ();
        Map<String, Account> marketSearch2Account = new Map<String, Account> ();

        //for updates on related Account Relationship records if organization type changes
        Set<Id> relationshipUpdateIds = new Set<Id>();

        //for updating manual_sc__c on Account Relationship records if national strategic account changes
        Map<Id, Account> relationshipUpdateMap = new Map<Id, Account>();

        for (Account acc : records) 
        {
            String tmtsr = getTmTSearch(acc);
            
            if (UUtil.inBatch
                || tp.isInsert == true
                || (acc.MATest__c != oldMap.get(acc.Id).MATest__c
                    || acc.TMT_Search__c != oldMap.get(acc.Id).TMT_Search__c 
                    || acc.Primary_Sales_Credit_Number__c != oldMap.get(acc.Id).Primary_Sales_Credit_Number__c 
                    || acc.Market__c != oldMap.get(acc.Id).Market__c
                    //added watch for changes in billing address fields and organization type
                    || acc.BillingCity != oldMap.get(acc.Id).BillingCity
                    || acc.BillingCountry != oldMap.get(acc.Id).BillingCountry
                    || acc.BillingCountryCode != oldMap.get(acc.Id).BillingCountryCode
                    || acc.BillingState != oldMap.get(acc.Id).BillingState
                    || acc.BillingPostalCode != oldMap.get(acc.Id).BillingPostalCode
                    || acc.BillingStreet != oldMap.get(acc.Id).BillingStreet
                    || acc.Organization_Type__c != oldMap.get(acc.Id).Organization_Type__c
                    || acc.National_Strategic_Account__c != oldMap.get(acc.Id).National_Strategic_Account__c))
            {
                Boolean stratChanged = (tp.isUpdate && acc.National_Strategic_Account__c != oldMap.get(acc.Id).National_Strategic_Account__c);

                //if organization type was updated, grab account id for account relationship updates later
                if (!UUtil.inBatch
                    && tp.isUpdate
                    && (acc.Organization_Type__c != oldMap.get(acc.Id).Organization_Type__c
                        || stratChanged))
                {
                    relationshipUpdateMap.put(acc.Id, (stratChanged) ? acc : null);
                }

                if (acc.National_Strategic_Account__c)
                {
                    continue;
                }

                if (acc.Organization_Type__c == 'UC-Utility Customer') 
                {
                    marketNames.add('Utility Direct');
                    tmtSearch.add(tmtsr);
                    marketSearch2Account.put(tmtsr + 'Utility Direct', acc);
                }
                else if (acc.Organization_Type__c == 'DC-Distributor Customer') 
                {
                    // PSC#
                    marketNames.add('Water Distribution');
                    tmtSearch.add(tmtsr);
                    marketSearch2Account.put(tmtsr + 'Water Distribution', acc);
                    // Acc Owner
                    marketNames.add('Utility Direct');
                    tmtSearch.add(tmtsr);
                    marketSearch2Account.put(tmtsr + 'Utility Direct', acc);
                } 
                else if (acc.Organization_Type__c == 'ED-Encompass Program Distributor' 
                    || acc.Organization_Type__c == 'FE-Flow End Customer' 
                    || acc.Organization_Type__c == 'FM-Skid Manufacturer/OEM' 
                    || acc.Organization_Type__c == 'TD-Turf Distributor')
                    // Allium - Moved these three lines to block below.
                    // || acc.Organization_Type__c == 'WD-Wyco Distributor' 
                    // || acc.Organization_Type__c == 'WE-Wyco End Customer/Contractor' 
                    // || acc.Organization_Type__c == 'WM-Wyco OEM')
                {
                    marketNames.add('Flow Direct');
                    tmtSearch.add(tmtsr);
                    marketSearch2Account.put(tmtsr + 'Flow Direct', acc);
                }
                
                // Allium - Created this block for 'Wyco Direct'
                else if (acc.Organization_Type__c == 'WD-Wyco Distributor' 
                    || acc.Organization_Type__c == 'WE-Wyco End Customer/Contractor' 
                    || acc.Organization_Type__c == 'WM-Wyco OEM')
                {
                    marketNames.add('Wyco Direct');
                    tmtSearch.add(tmtsr);
                    marketSearch2Account.put(tmtsr + 'Wyco Direct', acc);
                }
                // Allium - End Wyco block
                
                else if (acc.Organization_Type__c == 'HA-Flow House Account' 
                    || acc.Organization_Type__c == 'OD-Flow Open Distribution' 
                    || acc.Organization_Type__c == 'UO-Utility Other' 
                    || acc.Organization_Type__c == 'UD-Utility Distributor') 
                {
                    
                } 
                else if (acc.Organization_Type__c == 'IR-Flow Industrial/Commercial Rep') 
                {
                    
                }
            }
        }
        
        System.debug(METHOD_TAG + '- marketNames: ' + marketNames);
        System.debug(METHOD_TAG + '- tmtSearch: ' + tmtSearch);
        System.debug(METHOD_TAG + '- marketSearch2Account size: ' + marketSearch2Account.size());
        System.debug(METHOD_TAG + '- marketSearch2Account: ' + marketSearch2Account);
        
        List<TMT__c> tmts = [SELECT 
                                    Id, 
                                    CreatedDate, 
                                    Zip_Postal_Code__c,
                                    TMT_Search__c, 
                                    Market__c, 
                                    Market_Name__c, 
                                    User__c , 
                                    Sales_Credit_Name__c,
                                    Sales_Credit_Number__c
                             FROM 
                                    TMT__C 
                             WHERE 
                                    TMT_Search__c in : tmtSearch 
                             AND
                                    Market_Name__c in : marketNames 
                             ORDER BY 
                                    Market_Name__c];
    
        Map<string, tmt__c> market2tmtMap = new Map<string,tmt__c>();

        for(TMT__c tmt : tmts)
        {
            market2tmtMap.put(tmt.TMT_Search__c+tmt.Market_Name__c, tmt);
        }
        

        System.debug(METHOD_TAG + '- market2tmtMap: ' + market2tmtMap);

        if (!market2tmtMap.isEmpty())
        {
            for(Account a : records)
            {
                
                // Allium created this next block to get the Primary SC # of the Account
                // Used below for >= 30,000 logic
                integer Primary_SC_Num = 0;
                try{
                    Primary_SC_Num = integer.valueof(a.Primary_Sales_Credit_Number__c);
                }
                catch(exception e){
                    system.Debug('Could not convert SC# ' + a.Primary_Sales_Credit_Number__C + ' to Integer');
                }
                
                // Allium - Moved this block to the top to handle any Non-Us Bill-To, regardless of Org Type
                if (a.Organization_Type__c == 'HA-Flow House Account' 
                    || a.Organization_Type__c == 'OD-Flow Open Distribution' 
                    || a.Organization_Type__c == 'UO-Utility Other' 
                    || a.Organization_Type__c == 'UD-Utility Distributor'
                    || a.Organization_Type__c == 'IR-Flow Industrial/Commercial Rep'
                    // Allium removed the 30000 criteria per Ticket #50417 10.19.18 
                    //|| Primary_SC_Num >= 30000
                    // Next lines mean "Any Non-TMT Territory Bill-To"
                    || (    (a.BillingCountryCode != null   && (a.BillingCountryCode.toUpperCase() != 'US'          && a.BillingCountryCode.toUpperCase() != 'CA')) 
                        ||  (a.BillingCountry != null       && (a.BillingCountry.toUpperCase() != 'UNITED STATES'   && a.BillingCountry.toUpperCase() != 'CANADA'))
                       )
                   )
                {
                    // owner and PSC# are manually set  
                }
                else if (a.Organization_Type__c == 'UC-Utility Customer') 
                {
                    System.debug(METHOD_TAG + '- a.TMT_Search__c : ' + a.TMT_Search__c);

                    if(market2tmtMap.containsKey(a.TMT_Search__c + 'Utility Direct') == true)
                    {
                        System.debug(METHOD_TAG + '- in uc: ' + market2tmtMap.get(a.TMT_Search__c+'Utility Direct'));

                        a.Primary_Sales_Credit_Number__c = market2tmtMap.get(a.TMT_Search__c+'Utility Direct').Sales_Credit_Number__c;
                        a.Sales_Credit_Name__c =  market2tmtMap.get(a.TMT_Search__c+'Utility Direct').Sales_Credit_Name__c;

                        if (market2tmtMap.get(a.TMT_Search__c + 'Utility Direct').User__c != null)
                        {
                            a.OwnerId = market2tmtMap.get(a.TMT_Search__c + 'Utility Direct').User__c;
                        }
                    }
                }
                else if (a.Organization_Type__c == 'DC-Distributor Customer') 
                {
                    if(market2tmtMap.containsKey(a.TMT_Search__c+'Water Distribution') == true)
                    {
                        a.Primary_Sales_Credit_Number__c = market2tmtMap.get(a.TMT_Search__c+'Water Distribution').Sales_Credit_Number__c;
                        a.Sales_Credit_Name__c =  market2tmtMap.get(a.TMT_Search__c+'Water Distribution').Sales_Credit_Name__c;
                    }

                    if(market2tmtMap.containsKey(a.TMT_Search__c+'Utility Direct') == true)
                    {
                        //this value should come from water distro
                        //a.Sales_Credit_Name__c =  market2tmtMap.get(a.TMT_Search__c+'Utility Direct').Sales_Credit_Name__c;
                        if (market2tmtMap.get(a.TMT_Search__c + 'Utility Direct').User__c != null) 
                        {
                            a.OwnerId = market2tmtMap.get(a.TMT_Search__c + 'Utility Direct').User__c;
                        }
                    }
                }
                else if (a.Organization_Type__c == 'ED-Encompass Program Distributor' 
                    || a.Organization_Type__c == 'FE-Flow End Customer' 
                    || a.Organization_Type__c == 'FM-Skid Manufacturer/OEM' 
                    || a.Organization_Type__c == 'TD-Turf Distributor')
                    // Allium - Moved these three lines to block below.
                    //|| a.Organization_Type__c == 'WD-Wyco Distributor' 
                    //|| a.Organization_Type__c == 'WE-Wyco End Customer/Contractor' 
                    //|| a.Organization_Type__c == 'WM-Wyco OEM')
                {
                    if(market2tmtMap.containsKey(a.TMT_Search__c+'Flow Direct') == true)
                    {
                        a.Primary_Sales_Credit_Number__c = market2tmtMap.get(a.TMT_Search__c+'Flow Direct').Sales_Credit_Number__c;
                        a.Sales_Credit_Name__c =  market2tmtMap.get(a.TMT_Search__c+'Flow Direct').Sales_Credit_Name__c;

                        if (market2tmtMap.get(a.TMT_Search__c + 'Flow Direct').User__c != null) 
                        {
                            a.OwnerId = market2tmtMap.get(a.TMT_Search__c + 'Flow Direct').User__c;
                        }
                    }

                }

                // Allium - Created this block for 'Wyco Direct'                
                else if (a.Organization_Type__c == 'WD-Wyco Distributor' 
                    || a.Organization_Type__c == 'WE-Wyco End Customer/Contractor' 
                    || a.Organization_Type__c == 'WM-Wyco OEM')
                {
                    if(market2tmtMap.containsKey(a.TMT_Search__c+'Wyco Direct') == true)
                    {
                        a.Primary_Sales_Credit_Number__c = market2tmtMap.get(a.TMT_Search__c+'Wyco Direct').Sales_Credit_Number__c;
                        a.Sales_Credit_Name__c =  market2tmtMap.get(a.TMT_Search__c+'Wyco Direct').Sales_Credit_Name__c;

                        if (market2tmtMap.get(a.TMT_Search__c + 'Wyco Direct').User__c != null) 
                        {
                            a.OwnerId = market2tmtMap.get(a.TMT_Search__c + 'Wyco Direct').User__c;
                        }
                    }

                }

            }
        }

        if (!relationshipUpdateMap.isEmpty())
        {
            //update related account relationship records
            List<Account_Relationship__c> accountRelationships = new List<Account_Relationship__c>();

            for (Account_Relationship__c ar : [SELECT Id, Manual_SC__c, Partner_1__c FROM Account_Relationship__c WHERE Partner_1__c in : relationshipUpdateMap.keySet()])
            {
                if (relationshipUpdateMap.get(ar.Partner_1__c) != null)
                {
                    ar.Manual_SC__c = relationshipUpdateMap.get(ar.Partner_1__c).National_Strategic_Account__c;
                }

                accountRelationships.add(ar);
            }

            if (!accountRelationships.isEmpty())
            {
                System.enqueueJob(
                    new UQueueable(
                        new List<UUtil.ReturnObj>{
                            new UUtil.ReturnObj(accountRelationships, UEnum.DML.UPD)
                        }
                    )
                );
            }
        }

        // 2019-08-26	Allium IT, Joseph Bunda		Added this method call to ensure that all accounts get a sales credit name value based on the sales credit number.
        updateSalesCreditNames(records);
        
        System.debug('End ' + METHOD_TAG);
    }
    
    
    /**	Updates the value of the Sales Credit Name field according to the value of the
     * 	Primary Sales Credit Number field for each account.
     * 	
     * 	@author	Allium IT, Joseph Bunda
     * 	@date	2019-08-26
     * 
     * 	@param	accounts	The list of accounts to update.
     */
    
    
    public static void updateSalesCreditNames (List <Account> accounts) {
        
        System.debug('Entering UAccount.updateSalesCreditNames');
        
        // Compile the sales credit numbers in the set of accounts and blank out the current name.
        Set <String> salesCreditNumberSet = new Set <String> ();
        for (Account a : accounts) {
            if (!String.isBlank(a.Primary_Sales_Credit_Number__c)) salesCreditNumberSet.add(a.Primary_Sales_Credit_Number__c);
            else a.Sales_Credit_Name__c = '';
        }
        
        
        if (salesCreditNumberSet.size() == 0) {
            System.debug('No sales credit numbers to query against.');
        }
        else {
            System.debug('Querying for '+ salesCreditNumberSet.size() +' sales credit numbers');
            
            /* Allium - Remove searching for Sales Credit Name using the TMT table. - Causing Error due to a Non-selective query. Note: Sales_Credit_Number__c is not an indexed field.
            // Query the Territory Management Table using the sales credit numbers we compiled, then map the result set.
            Map <String, String> salesCreditNumberToName_TMT_Map = new Map <String, String> ();
            for (AggregateResult ar : [Select Sales_Credit_Number__c, Sales_Credit_Name__c From TMT__c Where Sales_Credit_Number__c in :salesCreditNumberSet Group By Sales_Credit_Number__c, Sales_Credit_Name__c]) salesCreditNumberToName_TMT_Map.put((String)ar.get('Sales_Credit_Number__c'), (String)ar.get('Sales_Credit_Name__c'));
            System.debug('Found '+ salesCreditNumberToName_TMT_Map.size() +' sales credit numbers in the TMT table.');
			*/

            // Also query the Sales Credit ID table.
            Map <String, Sales_Credit_ID__c> salesCreditNumberToName_SalesCredit_Map = new Map <String, Sales_Credit_ID__c> ();
            //for (Sales_Credit_ID__c sc : [Select Sales_Credit_Number__c, User__r.Name, Channel_Partner__r.Sales_Credit_Name__c From Sales_Credit_ID__c Where Active__c = true And Sales_Credit_Number__c in :salesCreditNumberSet]) salesCreditNumberToName_SalesCredit_Map.put(sc.Sales_Credit_Number__c, sc);
            //Removed where "Active" criteria and added Channel_Partner__r.name to the query.
            for (Sales_Credit_ID__c sc : [Select Sales_Credit_Number__c, User__r.Name, Channel_Partner__r.Sales_Credit_Name__c, Channel_Partner__r.name From Sales_Credit_ID__c Where Sales_Credit_Number__c in :salesCreditNumberSet]) salesCreditNumberToName_SalesCredit_Map.put(sc.Sales_Credit_Number__c, sc);
            //for (Sales_Credit_ID__c sc : [Select Sales_Credit_Number__c, User__r.Name, Channel_Partner__r.Sales_Credit_Name__c, Channel_Partner__r.name From Sales_Credit_ID__c]) salesCreditNumberToName_SalesCredit_Map.put(sc.Sales_Credit_Number__c, sc);
            System.debug('Found '+ salesCreditNumberToName_SalesCredit_Map.size() +' sales credit numbers in the Sales Credit ID table.');
            
            // Keep a counter of how many account relationships were updated for this action.
            Integer updatedAccounts = 0;
            
            // Iterate over the accounts and assign the sales credit name based on the number, if possible.        
            for (Account a : accounts) {
                
                if (!String.isBlank(a.Primary_Sales_Credit_Number__c)) {
                    
                    // Blank the current sales credit name.
                    a.Sales_Credit_Name__c = '';
                    
                    /* Allium - Remove searching for Sales Credit Name using the TMT table - Causing Error due to a Non-selective query
                    // Look in the TMT table first.
                    if (salesCreditNumberToName_TMT_Map.containsKey(a.Primary_Sales_Credit_Number__c)) {
                        a.Sales_Credit_Name__c = salesCreditNumberToName_TMT_Map.get(a.Primary_Sales_Credit_Number__c);
                        updatedAccounts++;
                        System.debug('Account "'+ a.Name +'" sales credit name updated from TMT object: '+ a.Sales_Credit_Name__c);
                    } */
					
                    
                    // If nothing was found in the TMT table, check the Sales Credit ID table.
                    if (String.isBlank(a.Sales_Credit_Name__c)) {
                        if (salesCreditNumberToName_SalesCredit_Map.containsKey(a.Primary_Sales_Credit_Number__c)) {
                            Sales_Credit_ID__c sc = salesCreditNumberToName_SalesCredit_Map.get(a.Primary_Sales_Credit_Number__c);     
                            
                            // The user field takes precendence over the channel partner field.
                            if (!String.isBlank(sc.User__r.Name)) {
                                a.Sales_Credit_Name__c = sc.User__r.Name;
                                updatedAccounts++;
                                System.debug('Account "'+ a.Name +'" sales credit name updated from Sales Credit ID object, User field: '+ a.Sales_Credit_Name__c);
                            }
                            else if (!String.isBlank(sc.Channel_Partner__r.Sales_Credit_Name__c)) {
                                //Changed to use the Acc name rather than the Sales Credit Name
                                a.Sales_Credit_Name__c = sc.Channel_Partner__r.name;
                                //a.Sales_Credit_Name__c = sc.Channel_Partner__r.Sales_Credit_Name__c;
                                updatedAccounts++;
                                System.debug('Account "'+ a.Name +'" sales credit name updated from Sales Credit ID object, Channel Partner field: '+ a.Sales_Credit_Name__c);
                            }
                        }
                    }
                    
                    // If we don't have a result by now, enter this message in the name field.
                    if (String.isBlank(a.Sales_Credit_Name__c)) a.Sales_Credit_Name__c = 'Sales Credit Name not in Sales Credit ID object';
                }
            }
            
            System.debug('Updated '+ updatedAccounts +' of '+ accounts.size() +' accounts with a sales credit name');
        }
        
    	System.debug('Exiting UAccount.updateSalesCreditNames');
    } 

    /**
     * updateProductDetails Sets various product fields on Contacts associated to Accounts
     * @param  records List of Account records
     * @param  oldMap  Trigger.oldMap
     */
    global static void updateProductDetails(List<Account> records, Map<Id, Account> oldMap)
    {
        final String METHOD_TAG = UAccount.class.toString() + '.updateProductDetails';
        System.debug('Start ' + METHOD_TAG);
        
        List<Contact> updContact = new List<Contact> ();

        for (Account acc : [SELECT 
                                    Id, 
                                    Products__c, 
                                    Active__c,
                                    (SELECT 
                                            Id, 
                                            Inactive__c, 
                                            Products_CSV_for_Extranet_1__c, 
                                            Products_CSV_for_Extranet_2__c,
                                            Products_CSV_for_Extranet_3__c,
                                            Products_CSV_for_Extranet_4__c 
                                    FROM 
                                            Account.Contacts 
                                    WHERE 
                                            Inactive__c = false 
                                    AND
                                            AccountId != null)
                            FROM 
                                    Account 
                            WHERE 
                                    Active__c = true 
                            AND
                                    Id in : records])
        {
            for (Contact cont : acc.Contacts)
            {
                String returnvalue = '';
                Contact con = new Contact();
                con.id = cont.id;

                if (acc.Active__c == true
                    && (acc.Products__c != oldMap.get(acc.id).Products__c))
                {

                    if (acc.products__c != null)
                    {
                        returnvalue = acc.products__c;
                        returnValue = returnValue.replaceAll(';', ',');
                        con.Products_for_Extranet__c = returnValue;

                        con.Products_CSV_for_Extranet_1__c = con.Products_for_Extranet__c.MID(0, 254);
                        con.Products_CSV_for_Extranet_2__c = con.Products_for_Extranet__c.MID(255, 255);
                        con.Products_CSV_for_Extranet_3__c = con.Products_for_Extranet__c.MID(510, 255);
                        con.Products_CSV_for_Extranet_4__c = con.Products_for_Extranet__c.MID(765, 255);
                    }
                    else if (acc.products__c == null)
                    {
                        con.Products_for_Extranet__c = '';
                        con.Products_CSV_for_Extranet_1__c = '';
                        con.Products_CSV_for_Extranet_2__c = '';
                        con.Products_CSV_for_Extranet_3__c = '';
                        con.Products_CSV_for_Extranet_4__c = '';
                    }

                    updContact.add(con);
                }
            }
        }

        if (updContact.size() > 0 && updContact != null)
        {
            update updContact;
        }

        System.debug('END ' + METHOD_TAG);
    }

}