global class UAccountRelationship 
{

	global class UpdateAccountRelationship implements gearsBase.gearsExecute.executeMethod
	{
		public void execute(List<SObject> records, Map<Id, sObject> oldMap, gearsBase.gearsExecute.triggerParameters tp)
		{
			System.debug(UAccountRelationship.class.toString());
			update_ShipToSalesCreditNumber(records, (Map<Id, Account_Relationship__c>) oldMap, tp);
		}
	}

	global class UpdateTMTSearch implements gearsBase.gearsExecute.executeMethod
	{
		public void execute(List<SObject> records, Map<Id, sObject> oldMap, gearsBase.gearsExecute.triggerParameters tp)
		{
			update_TMTSearch(records, (Map<Id, Account_Relationship__c>) oldMap, tp);
		}
	}

	/**
	 * update_TMTSearch Sets TMT_Search__c field on Account_Relationship__c object
	 * @param  records List of Accpunt_Relationship__c records
	 * @param  oldMap  Trigger.oldMap
	 * @param  tp      GearsBase.gearsExecute.triggerParameters
	 */
	public static void update_TMTSearch(List<Account_Relationship__c> records, Map<Id, Account_Relationship__c> oldMap, gearsBase.gearsExecute.triggerParameters tp) 
	{
		final String TAG_NAME = UAccountRelationship.class.toString() + '.update_TMTSearch';
		System.debug('Start ' + TAG_NAME);

		for (Account_Relationship__c ar : records) 
		{
			/* is this check needed?
			if (ar.Manual_SC__c)
			{
				System.debug(TAG_NAME + '- ar.Manual_SC__c: ' + ar.Manual_SC__c + ' - skipping');
				continue;
			}
			*/

			ar.Partner_2_Shipping_Street__c = (ar.Partner_2_Shipping_Street__c != null) ? ar.Partner_2_Shipping_Street__c.toUpperCase() : '';
			ar.Shipping_Street_2__c = (ar.Shipping_Street_2__c != null) ? ar.Shipping_Street_2__c.toUpperCase() : '';
			ar.Partner_2_Shipping_City__c = (ar.Partner_2_Shipping_City__c != null) ? ar.Partner_2_Shipping_City__c.toUpperCase() : '';
			ar.Partner_2_Shipping_Postal_Code__c = (ar.Partner_2_Shipping_Postal_Code__c != null) ? ar.Partner_2_Shipping_Postal_Code__c.toUpperCase() : '';

			String tmtSearch = 'ERROR';

			System.debug('Ar Id: ' + ar.Id);

			if (ar.Partner_2_Shipping_Country__c != null && ar.Partner_2_Shipping_Country__c.toUpperCase() == 'UNITED STATES') 
			{
				String postalCode = (ar.Partner_2_Shipping_Postal_Code__c != null 
					&& ar.Partner_2_Shipping_Postal_Code__c.length() >= 5) ? ar.Partner_2_Shipping_Postal_Code__c.LEFT(5) : 'ERROR';
				tmtSearch = 'USA-' + postalCode;
			} 
			else if (ar.Partner_2_Shipping_Country__c != null && ar.Partner_2_Shipping_Country__c.toUpperCase() == 'CANADA') 
			{
				String postalCode = (ar.Partner_2_Shipping_Postal_Code__c != null 
					&& ar.Partner_2_Shipping_Postal_Code__c.length() >= 3) ? ar.Partner_2_Shipping_Postal_Code__c.LEFT(3) : 'ERROR';
				tmtSearch = 'CAN-' + ar.Partner_2_Shipping_Postal_Code__c.LEFT(3);
			} 
			else if (ar.Partner_2_Shipping_Country__c != null && ar.Partner_2_Shipping_Country__c.toUpperCase() == 'MEXICO') 
			{
				String postalCode = (ar.Partner_2_Shipping_State__c != null
					&& ar.Partner_2_Shipping_State__c.length() >= 6) ? ar.Partner_2_Shipping_State__c.right(ar.Partner_2_Shipping_State__c.length() - 6) : 'ERROR';
				tmtSearch = 'MEX-' + postalCode.toUpperCase();
			}

			ar.TMT_Search__c = tmtSearch;
			System.debug(TAG_NAME + '- ar.TMT_Search__c ' + ar.TMT_Search__c);
		}

		System.debug('End ' + TAG_NAME);
	}

	/**
	 * update_ShipToSalesCreditNumber Sets Account_Relationship__c fields Partner_2_Sales_Cred_Num__c and Sales_Credit_Name__c
	 * @param  records List of Accpunt_Relationship__c records
	 * @param  oldMap  Trigger.oldMap
	 * @param  tp      GearsBase.gearsExecute.triggerParameters
	 */
	public static void update_ShipToSalesCreditNumber(List<Account_Relationship__c> records, Map<Id, Account_Relationship__c> oldMap, gearsBase.gearsExecute.triggerParameters tp) 
	{
		final String TAG_NAME = UAccountRelationship.class.toString() + '.update_ShipToSalesCreditNumber';
		System.debug('Start ' + TAG_NAME);

		Set<String> tmtSearch = new Set<String>();
		Set<String> marketNames = new Set<String>{'Utility Direct', 'Flow Direct'};
		Set<Id> accountIds = new Set<Id> ();

        // Added by Allium - List of Account Relationship records with Account Info
        list <account_relationship__c> AR_with_Account_Info = new list <account_relationship__c>(
        	[SELECT ID,
             		Partner_1__r.BillingCountry,
             		Partner_1__r.Primary_Sales_Credit_Number__c
             FROM account_relationship__c
             WHERE ID in : records]);
        
        // Added by Allium - Map of Account Relationship IDs and their Account Billing Country
        map <ID, string> Billing_Country_Map = new map <ID, string>();
        for (account_relationship__c ar : AR_with_Account_Info){
            try {
                Billing_Country_Map.put(ar.ID, ar.Partner_1__r.BillingCountry.toUpperCase());
            }
            catch (exception e){
                // error condition, set to blank and catch in the condition below
                Billing_Country_Map.put(ar.ID, ''); 
            }
        }

        // Added by Allium - Map of Account Relationship IDs and their Account Primary SC #
        map <ID, string> Billing_Primary_SC_Map = new map <ID, string>();
        for (account_relationship__c ar : AR_with_Account_Info){
            try {
                Billing_Primary_SC_Map.put(ar.ID, ar.Partner_1__r.Primary_Sales_Credit_Number__c);
            }
            catch (exception e){
                // error condition, set to blank and catch in the condition below
                Billing_Primary_SC_Map.put(ar.ID, ''); 
            }
        }        
        
		for (Account_Relationship__c rec : records) 
		{
			if (rec.Manual_SC__c)
			{
				continue;
			}

            // Allium created this next block to get the Primary SC # of the Account
            // Used below for >= 30,000 logic
            integer Primary_SC_Num = 0;
            try{
                Primary_SC_Num = integer.valueof(Billing_Primary_SC_Map.get(rec.ID));
            }
            catch(exception e){
                system.Debug('Could not convert string to integer SC#');
            }            
            
			if (rec.Market__c != null 
				&& (rec.Partner_2_Shipping_Country__c == 'UNITED STATES' 
					|| rec.Partner_2_Shipping_Country__c == 'CANADA' 
					|| rec.Partner_2_Shipping_Country__c == 'MEXICO')
                	// Added by Allium to continue processing for non-US Bill-To Accounts and Account Primary SC# >= 30,000
                    || (!string.IsBlank(Billing_Country_Map.get(rec.ID)) && Billing_Country_Map.get(rec.ID) != 'UNITED STATES')
               		|| Primary_SC_Num >= 30000)
			{
				if (UUtil.inBatch
					|| tp.isInsert == true 
					|| (rec.MATEST__c != oldMap.get(rec.Id).MATEST__c
						||rec.TMT_Search__c != oldMap.get(rec.Id).TMT_Search__c 
						|| (!rec.Manual_SC__c && rec.Manual_SC__c != oldMap.get(rec.Id).Manual_SC__c)
						|| rec.Market__c != oldMap.get(rec.Id).Market__c
						//adding checks for changes to Partner_2 address fields and sales_cred_num__c
						|| rec.Partner_2_Shipping_Country__c != oldMap.get(rec.Id).Partner_2_Shipping_Country__c
						|| rec.Partner_2_Shipping_Postal_Code__c != oldMap.get(rec.Id).Partner_2_Shipping_Postal_Code__c
						|| rec.Partner_2_Shipping_State__c != oldMap.get(rec.Id).Partner_2_Shipping_State__c))
				{
					tmtSearch.add(rec.TMT_Search__c);
					marketNames.add(rec.Market__c);
					accountIds.add(rec.Partner_1__c);
				}
			}
		}

        
        
        // 2019-08-26	Allium IT, Joseph Bunda		Added this method call to ensure that all account relationships get a sales credit name value based on the sales credit number.
        updateSalesCreditNames(records);
        
        
		if (accountIds.isEmpty())
		{
			System.debug(TAG_NAME + '- nothing to process, exiting');
			System.debug('End ' + TAG_NAME);
			return;
		}
		
		System.debug(TAG_NAME + '- marketNames: ' + marketNames);

		Map<Id, Account> accountMap = new Map<Id, Account> ();
		Set<String> tmtAccOwners = new Set<String> ();

		for (Account a :[SELECT 
								Id, 
								TMT_Account_Owner__c, 
								Organization_Type__c, 
								Primary_Sales_Credit_Number__c, 
								Sales_Credit_Name__c,
                         		BillingCountry
						FROM 
								Account 
						WHERE
								Id in : accountIds])
		{
			accountMap.put(a.Id, a);
			tmtAccOwners.add(a.TMT_Account_Owner__c);
		}

		System.debug(TAG_NAME + '- tmtSearch is size: ' + tmtSearch.size());
		System.debug(TAG_NAME + '- tmtSearch is : ' + tmtSearch);
		System.debug(TAG_NAME + '- tmtSearch is isEmpty: ' + tmtSearch.isEmpty());
		System.debug(TAG_NAME + '- marketNames: ' + marketNames);
		System.debug(TAG_NAME + '- tmtAccOwnersId: ' + tmtAccOwners);

		List<TMT__c> tmts = [SELECT 
									Id, 
									User__c, 
									Channel_Partner__c, 
									Zip_Postal_Code__c, 
									TMT_Search__c, 
									Market__c, 
									Market_Text__c, 
									Sales_Credit_Number__c, 
									Sales_Credit_Name__c
								FROM 
									TMT__C
								WHERE
									(TMT_Search__c in : tmtSearch AND Market_Text__c in : marketNames) 
								OR
									(TMT_Search__c in : tmtSearch and Market_Text__c in : tmtAccOwners)];

		Map<String, TMT__c> zipMarket2TmTMap = new Map<String, TMT__c> ();

		for (TMT__c tmt : tmts) 
		{
			System.debug(TAG_NAME + '- zip+market: ' + tmt.TMT_Search__c + tmt.Market_Text__c);
			zipMarket2TmTMap.put(tmt.TMT_Search__c + tmt.Market_Text__c, tmt);
		}

		List<Account_Relationship__c> arUpdate = new List<Account_Relationship__c> ();

		for (Account_Relationship__c ar : records)
		{
			Account a = accountMap.get(ar.Partner_1__c);
			
			System.debug(TAG_NAME + '- acc-map: ' + a);
			System.debug(TAG_NAME + '- Organization_Type__c: ' + a.Organization_Type__c);

            // Allium created this next block to get the Primary SC # of the Account
            // Used below for >= 30,000 logic
            integer Primary_SC_Num = 0;
            try{
                Primary_SC_Num = integer.valueof(a.Primary_Sales_Credit_Number__c);
            }
            catch(exception e){
                system.Debug('Could not convert SC# ' + a.Primary_Sales_Credit_Number__C + ' to Integer');
            }
            
            // Allium - Moved this block to the first If condition, so Non-US will be caught regardless of Org Type
            if (a.Organization_Type__c == 'HA-Flow House Account' 
				|| a.Organization_Type__c == 'OD-Flow Open Distribution' 
				|| a.Organization_Type__c == 'UO-Utility Other' 
				|| a.Organization_Type__c == 'UD-Utility Distributor'
                // Allium - Next Line moved from block below
                || a.Organization_Type__c == 'WM-Wyco OEM'
                // Allium - Non-US Account Bill-To || Account Primary SC# >= 30,000
                || a.BillingCountry.toUpperCase() != 'UNITED STATES'
                //|| Primary_SC_Num >= 30000
                )
			{
                // Assign primary Sales Credit # of the Account
				ar.Partner_2_Sales_Cred_Num__c = a.Primary_Sales_Credit_Number__c;
				ar.Sales_Credit_Name__c = a.Sales_Credit_Name__c;
				arUpdate.add(ar);
			}
			else if (a.Organization_Type__c == 'UC-Utility Customer') 
			{
				if (zipMarket2TmTMap.containsKey(ar.TMT_Search__c + 'Utility Direct')) 
				{
					ar.Partner_2_Sales_Cred_Num__c = zipMarket2TmTMap.get(ar.TMT_Search__c + 'Utility Direct').Sales_Credit_Number__c;
					ar.Sales_Credit_Name__c = zipMarket2TmTMap.get(ar.TMT_Search__c + 'Utility Direct').Sales_Credit_Name__c;
				}
				
				arUpdate.add(ar);
			} 
			else if (a.Organization_Type__c == 'DC-Distributor Customer') 
			{
				if (zipMarket2TmTMap.containsKey(ar.TMT_Search__c + ar.Market__c)) 
				{
					ar.Partner_2_Sales_Cred_Num__c = zipMarket2TmTMap.get(ar.TMT_Search__c + ar.Market__c).Sales_Credit_Number__c;
					ar.Sales_Credit_Name__c = zipMarket2TmTMap.get(ar.TMT_Search__c + ar.Market__c).Sales_Credit_Name__c;
				} 
				else if (zipMarket2TmTMap.containsKey(ar.TMT_Search__c + 'Utility Direct')) 
				{
					ar.Partner_2_Sales_Cred_Num__c = zipMarket2TmTMap.get(ar.TMT_Search__c + 'Utility Direct').Sales_Credit_Number__c;
					ar.Sales_Credit_Name__c = zipMarket2TmTMap.get(ar.TMT_Search__c + 'Utility Direct').Sales_Credit_Name__c;
				}

				arUpdate.add(ar);
			} 
			else if (a.Organization_Type__c == 'ED-Encompass Program Distributor' 
				|| a.Organization_Type__c == 'FE-Flow End Customer' 
				|| a.Organization_Type__c == 'FM-Skid Manufacturer/OEM' 
				|| a.Organization_Type__c == 'TD-Turf Distributor' 
				|| a.Organization_Type__c == 'WD-Wyco Distributor' 
				|| a.Organization_Type__c == 'WE-Wyco End Customer/Contractor')
                // Allium - Moved this line to block above
				//|| a.Organization_Type__c == 'WM-Wyco OEM')
			{
				if (zipMarket2TmTMap.containsKey(ar.TMT_Search__c + ar.Market__c)) 
				{
					ar.Partner_2_Sales_Cred_Num__c = zipMarket2TmTMap.get(ar.TMT_Search__c + ar.Market__c).Sales_Credit_Number__c;
					ar.Sales_Credit_Name__c = zipMarket2TmTMap.get(ar.TMT_Search__c + ar.Market__c).Sales_Credit_Name__c;
				} 
				else if (zipMarket2TmTMap.containsKey(ar.TMT_Search__c + 'Flow Direct')) 
				{
					ar.Partner_2_Sales_Cred_Num__c = zipMarket2TmTMap.get(ar.TMT_Search__c + 'Flow Direct').Sales_Credit_Number__c;
					ar.Sales_Credit_Name__c = zipMarket2TmTMap.get(ar.TMT_Search__c + 'Flow Direct').Sales_Credit_Name__c;
				}

				arUpdate.add(ar);
			} 
			else if (a.Organization_Type__c == 'IR-Flow Industrial/Commercial Rep')
			{

				if (zipMarket2TmTMap.containsKey(ar.TMT_Search__c + ar.Market__c))
				{
					ar.Partner_2_Sales_Cred_Num__c = zipMarket2TmTMap.get(ar.TMT_Search__c + ar.Market__c).Sales_Credit_Number__c;
					ar.Sales_Credit_Name__c = zipMarket2TmTMap.get(ar.TMT_Search__c + ar.Market__c).Sales_Credit_Name__c;
				} 
				else if (zipMarket2TmTMap.containsKey(ar.TMT_Search__c + 'Flow Direct'))
				{
					ar.Partner_2_Sales_Cred_Num__c = zipMarket2TmTMap.get(ar.TMT_Search__c + 'Flow Direct').Sales_Credit_Number__c;
					ar.Sales_Credit_Name__c = zipMarket2TmTMap.get(ar.TMT_Search__c + 'Flow Direct').Sales_Credit_Name__c;
				}

				arUpdate.add(ar);
			}
		}
        
        
		
		System.debug('End ' + TAG_NAME);
	}

    
    /**	Updates the value of the Sales Credit Name field according to the value of the
     * 	Primary Sales Credit Number field for each account.
     * 	
     * 	@author	Allium IT, Joseph Bunda
     * 	@date	2019-08-26
     * 
     * 	@param	accounts	The list of accounts to update.
     */
    
    
    public static void updateSalesCreditNames (List <Account_Relationship__c> accountRelationships) {
        
        System.debug('Entering UAccountRelationship.updateSalesCreditNames');
        
        // Compile the sales credit numbers in the set of account relationships and blank the name.
        Set <String> salesCreditNumberSet = new Set <String> ();
        for (Account_Relationship__c a : accountRelationships) {
            if (!String.isBlank(a.Partner_2_Sales_Cred_Num__c)) salesCreditNumberSet.add(a.Partner_2_Sales_Cred_Num__c);
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
            // Added Channel_Partner__r.name to the query.
            for (Sales_Credit_ID__c sc : [Select Sales_Credit_Number__c, User__r.Name, Channel_Partner__r.Sales_Credit_Name__c, Channel_Partner__r.name From Sales_Credit_ID__c Where Sales_Credit_Number__c in :salesCreditNumberSet]) salesCreditNumberToName_SalesCredit_Map.put(sc.Sales_Credit_Number__c, sc);
            System.debug('Found '+ salesCreditNumberToName_SalesCredit_Map.size() +' sales credit numbers in the Sales Credit ID table.');
            
            // Keep a counter of how many account relationships were updated for this action.
            Integer updatedAccountRelationships = 0;
            
            // Iterate over the account relationships and assign the sales credit name based on the number, if possible.        
            for (Account_Relationship__c a : accountRelationships) {
                
                if (!String.isBlank(a.Partner_2_Sales_Cred_Num__c)) {
                    
                    // Blank the current sales credit name.
                    a.Sales_Credit_Name__c = '';
                    
                    /* Allium - Remove searching for Sales Credit Name using the TMT table - Causing Error due to a Non-selective query
                    // Look in the TMT table first.
                    if (salesCreditNumberToName_TMT_Map.containsKey(a.Partner_2_Sales_Cred_Num__c)) {
                        a.Sales_Credit_Name__c = salesCreditNumberToName_TMT_Map.get(a.Partner_2_Sales_Cred_Num__c);
                        updatedAccountRelationships++;
                        System.debug('Account Relationship "'+ a.Name +'" sales credit name updated from TMT object: '+ a.Sales_Credit_Name__c);
                    }*/
					
                    
                    // If nothing was found in the TMT table, check the Sales Credit ID table.
                    if (String.isBlank(a.Sales_Credit_Name__c)) {
                        if (salesCreditNumberToName_SalesCredit_Map.containsKey(a.Partner_2_Sales_Cred_Num__c)) {
                            Sales_Credit_ID__c sc = salesCreditNumberToName_SalesCredit_Map.get(a.Partner_2_Sales_Cred_Num__c);     
                            
                            // The user field takes precendence over the channel partner field.
                            if (!String.isBlank(sc.User__r.Name)) {
                                a.Sales_Credit_Name__c = sc.User__r.Name;
                                updatedAccountRelationships++;
                                System.debug('Account Relationship "'+ a.Name +'" sales credit name updated from Sales Credit ID object, User field: '+ a.Sales_Credit_Name__c);
                            }
                            else if (!String.isBlank(sc.Channel_Partner__r.Sales_Credit_Name__c)) {
                                //Changed to use the Acc name rather than the Sales Credit Name
                                a.Sales_Credit_Name__c = sc.Channel_Partner__r.name;
                                //a.Sales_Credit_Name__c = sc.Channel_Partner__r.Sales_Credit_Name__c;
                                updatedAccountRelationships++;
                                System.debug('Account Relationship "'+ a.Name +'" sales credit name updated from Sales Credit ID object, Channel Partner field: '+ a.Sales_Credit_Name__c);
                            }
                        }
                    }
                    
                    // If we don't have a result by now, enter this message in the name field.
                    if (String.isBlank(a.Sales_Credit_Name__c)) a.Sales_Credit_Name__c = 'Sales Credit Name not in Sales Credit ID object';
                }
            }
            
            System.debug('Updated '+ updatedAccountRelationships +' of '+ accountRelationships.size() +' account relationships with a sales credit name');
        }

    	System.debug('Exiting UAccountRelationship.updateSalesCreditNames');
    }
}