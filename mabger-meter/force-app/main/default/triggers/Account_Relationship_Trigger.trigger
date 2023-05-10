trigger Account_Relationship_Trigger on Account_Relationship__c (before insert,  before update, before delete, after insert,  after update, after delete, after undelete )  {
  
  GearsBase.GearsExecute.executeAllMethods();
    
    // Added by Allium
    // Update related Beacon Service Pricing records
    if (trigger.isAfter && trigger.isUpdate) {

        set <ID> AccountIDs = new set <ID>();
        set <String> CustomerNumbers = new set <String>();
        
        // get set of Accounts represented by the Account Relationship records in Trigger.new
        for (Account_Relationship__c ar : trigger.new){
            // Only get related Account ID if "Ship-To Sales Credit Number" has changed
            // Note: isUpdate is necessary in the following line to prevent a null error for Insert context 
            if(trigger.isUpdate && Trigger.oldMap.get(ar.ID).Partner_2_Sales_Cred_Num__c != Trigger.newMap.get(ar.ID).Partner_2_Sales_Cred_Num__c){
                AccountIDs.add(ar.Partner_1__c);
            }
        }

        if (!AccountIDs.isEmpty()){

            // get set of Customer Numbers of the Accounts represented by the Account Relationship records in Trigger.new
          for (Account a : [SELECT Customer_Number__c
                      FROM Account
                              WHERE ID in : AccountIDs]) CustomerNumbers.add(a.Customer_Number__c);

            // get list of bsp records where bsp.Bill-To# is in the list of Customer Numbers
            list <Beacon_Service_Pricing__c> bsp_records_customer_numbers = new list <Beacon_Service_Pricing__c>(
                [SELECT ID, Bill_To_Number__c, Last_Downstream_Update__c
                 FROM Beacon_Service_Pricing__c
                 WHERE Bill_To_Number__c in : CustomerNumbers]);
                
            // update the bsp records - Last_Downstream_Update__c = system.now();
            // this will activate the Beacon_Service_Pricing trigger to recalcuate sales credit, etc.
            for (Beacon_Service_Pricing__c bsp : bsp_records_customer_numbers) bsp.Last_Downstream_Update__c = system.now();
            for (Beacon_Service_Pricing__c bsp : bsp_records_customer_numbers){
                system.debug('BEACON Customer #: ' + bsp.Account_Customer_Number__c);
                system.debug('Bill To Number: ' + bsp.Bill_To_Number__c);
                system.debug('Ship-To Number: ' + bsp.Ship_To_Number__c);
                system.debug('Sales Credit #: ' + bsp.Sales_Credit_Number__c);
            }
            update bsp_records_customer_Numbers;
        }
    }        
}