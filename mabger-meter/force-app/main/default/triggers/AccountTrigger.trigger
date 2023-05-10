/* ************************************************************
 * Created By    : Raja Y (GearsCRM)
 * Created Date  : 09/16/2015
 * Description   : Trigger for the Account object
 * 
 * Modified By   :  Joe Bunda, Allium IT
 * Modified Date :  2020-11-12
 * Description   :  Adds customer number formatting for accounts. Ensures up to 8 characters with leading zeros.
 * 
 * ************************************************************/   
trigger AccountTrigger on account (before insert,  before update, before delete, after insert,  after update, after delete, after undelete )  {
	
	GearsBase.GearsExecute.executeAllMethods();

    // Added by Allium
    // Update related Beacon Service Pricing records
    if (trigger.isAfter && trigger.isUpdate) {

        set <Beacon_Service_Pricing__c> Beacon_Service_Pricing_Records = new set <Beacon_Service_Pricing__c>(
            [SELECT ID,	Account_ID__c
             FROM Beacon_Service_Pricing__c
             WHERE Account_ID__c in : trigger.new]);

        list <Beacon_Service_Pricing__c> BSP_Records_To_Update = new list <Beacon_Service_Pricing__c>();
        
        for (Beacon_Service_Pricing__c bsp : Beacon_Service_Pricing_Records){
        	if(Trigger.oldMap.get(bsp.Account_ID__c).Default_Ship_To__c != Trigger.newMap.get(bsp.Account_ID__c).Default_Ship_To__c
        	|| Trigger.oldMap.get(bsp.Account_ID__c).Default_Account_Relationship__c != Trigger.newMap.get(bsp.Account_ID__c).Default_Account_Relationship__c){

                bsp.Last_Downstream_Update__c = System.now();
                BSP_Records_To_Update.add(bsp);
        	}
        }
        update BSP_Records_To_Update;
    } 
    
    
    
    if (trigger.isAfter && trigger.isUpdate) {
		LibraryAccessHelper.updateAccess(trigger.new, trigger.oldMap);   
    }

    // 2020-11-12 - Allium - Added by JWB for Beacon. Ensures that account's customer numbers are formatted with leading zeroes.
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        BeaconHelper.formatCustomerNumbers(trigger.new);
    }
}