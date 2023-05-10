trigger BEACON_Service_Pricing_trigger on BEACON_Service_Pricing__c (before update) {
    
    if (trigger.isBefore && trigger.isUpdate) {
        
        // Get Default Ship-To and Default Ship-To Sales Credit # from related Accounts
		Map <ID,BEACON_Service_Pricing__c> bsp_list_with_account_data = new Map <ID,BEACON_Service_Pricing__c>(
            [select Account_ID__r.Default_Ship_To_Sales_Credit__c,
             		Account_ID__r.Default_Ship_To__c,
             		Account_ID__r.Default_Account_Relationship__r.Partner_2_Sales_Cred_Num__c //Ship To Sales Credit #
             from BEACON_Service_Pricing__c
             where id in :Trigger.newMap.keyset()]);

        // *****************************************************
        // Populate list with all Bill-To Numbers represented in trigger.new
        List <string> Bill_To_Numbers = new List<string>();
        for (BEACON_Service_Pricing__c bsp : trigger.new){
            Bill_To_Numbers.add(bsp.Bill_To_Number__c);
        }

        // The following map uses "Customer Number - Ship-To Number" as the Key, with Ship-To SC# as the value.
        map <string, string> Sales_Credit_By_Bill_To_Number = new Map <string, string>();
		// Populate the map with Account Relationship data
        for (Account_Relationship__c ar: 
            [SELECT ar.ID,
             		ar.Partner_1__r.Customer_Number__c,
             		ar.Ship_To_Number__c,
             		ar.Partner_2_Sales_Cred_Num__c,
             		ar.Customer_Number__c
             FROM Account_Relationship__c ar
             WHERE ar.Partner_1__r.Customer_Number__c in :Bill_To_Numbers]){
  			
            Sales_Credit_By_Bill_To_Number.put(ar.Customer_Number__c + '-' + ar.Ship_To_Number__c, ar.Partner_2_Sales_Cred_Num__c);
        }
		// *****************************************************
        
        for (BEACON_Service_Pricing__c bsp : trigger.new) {
            
            system.debug('Processing Account Customer Number ' + bsp.Account_Customer_Number__c);

            // If the Bill-To Number = Customer Number (the Account)   
            if (bsp.Bill_To_Number__c == bsp.Account_Customer_Number__c){
                system.debug('Bill-To Number = Customer Number');
                
                // Set Sales Credit Number = Account’s - Default Account Relationship’s – Ship-To-SC #
                system.debug('Setting Sales Credit Number = ' + bsp_list_with_account_data.get(bsp.id).Account_ID__r.Default_Account_Relationship__r.Partner_2_Sales_Cred_Num__c);
                bsp.Sales_Credit_Number__c = bsp_list_with_account_data.get(bsp.id).Account_ID__r.Default_Account_Relationship__r.Partner_2_Sales_Cred_Num__c;
                
                // Set Ship-To = Default Ship-To of the Account
                system.debug('Setting Ship-To Number = ' + bsp_list_with_account_data.get(bsp.id).Account_ID__r.Default_Ship_To__c);
                bsp.Ship_To_Number__c = bsp_list_with_account_data.get(bsp.id).Account_ID__r.Default_Ship_To__c;
            }
            else {
                system.debug('Bill-To Number ' + bsp.Bill_To_Number__c + ' != Customer Number ' + bsp.Account_Customer_Number__c);
                
                // Set Sales Credit Number to the Ship-To SC# of the Account with Customer Number = Bill-To Number
                system.debug('Setting Sales Credit Number = ' + Sales_Credit_By_Bill_To_Number.get(bsp.Bill_To_Number__c + '-' + bsp.Ship_To_Number__c));
                bsp.Sales_Credit_Number__c = Sales_Credit_By_Bill_To_Number.get(bsp.Bill_To_Number__c + '-' + bsp.Ship_To_Number__c);
            }
            
        } // End loop through changed records.
        
    } // End if Trigger is of certain type(s).
    
} // End Trigger