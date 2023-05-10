/* 
    Created By:  GearsCRM
    Created Date: 9/15/2015
    Description:  contact Helper Class
    
    Modified By   :  Trekbin
    Modified Date :  14 Oct, 2015
    Description   :  Modified linkDomainAccount method to deactivate the User.
	Test class    :  test_UContact 
*/
  
public without sharing class UContact    
{

    /**
     * updatePricebookLocation Sets Contact.Pricebook_Location_for_Extranet__c
     * @param  record List of Contact records
     * @param  oldMap Trigger.oldMap
     */
    public static void updatePricebookLocation(List <contact> records, map<id,contact> oldMap)
    {  
        boolean isInsert = (oldMap == null);
        
        for(contact con : records)
        {
            string retvalue = '';
            if (isInsert == true || (isInsert == false && con.Pricebook_Location__c  != oldMap.get(con.id).Pricebook_Location__c ))
            {
                if(con.Pricebook_Location__c != null)
                {
                    retvalue = con.Pricebook_Location__c;
                    retvalue = retvalue.replaceAll(';',',');
                    con.Pricebook_Location_for_Extranet__c = retvalue;
                   //con.Pricebook_Location_for_Extranet__c = con.Pricebook_Location__c;
                }
                else if(con.Pricebook_Location__c  == null)
                {
                    con.Pricebook_Location_for_Extranet__c = '';
                }
            }   
        }
    }
    
    /**
     * updateProductDetails UAccount.updateProductDetails should use this method -- duplicate logic
     * @param  record List of Contact records
     * @param  oldMap Trigger.oldMap
     */
    public static void updateProductDetails(List <contact> records, map<id,contact> oldMap)
    {  
        boolean isInsert = (oldMap == null);
        list<contact> updContact = new list<contact>();   
        for(contact con : [select id,AccountId,account.products__c,Products_CSV_for_Extranet_1__c,Products_CSV_for_Extranet_2__c,Products_CSV_for_Extranet_3__c,Products_CSV_for_Extranet_4__c,Inactive__c   
                         from contact where id in : records and account.products__c != null])
                        // from contact where id in : records ])
        {
            string returnvalue = '';
            //if (isInsert == true || (isInsert == false && con.AccountId  != oldMap.get(con.id).AccountId && (con.account.products__c != null || con.account.products__c == null )))
            
            system.debug('_____isInsert_____' + isInsert);
            system.debug('_____con.Inactive__c____' + con.Inactive__c);
            system.debug('_____con.AccountId____' + con.AccountId);
            if(isInsert == false)
            {
                system.debug('_____oldMap.get(con.id).AccountId____' + oldMap.get(con.id).AccountId);
                system.debug('_____oldMap.get(con.id).Inactive__c____' + oldMap.get(con.id).Inactive__c);
            }
            
            if ((isInsert == true && con.Inactive__c == false) 
               || (isInsert == false
                  &&((con.AccountId  != oldMap.get(con.id).AccountId &&  con.Inactive__c == false) || (con.Inactive__c != oldMap.get(con.id).Inactive__c && con.Inactive__c == false))))
            {
                system.debug('______con.account.products__c____' + con.account.products__c);
                if(con.account.products__c != null)
                {
                    returnvalue = con.account.products__c;
                    returnValue=returnValue.replaceAll(';',',');
                    con.Products_for_Extranet__c = returnValue;
               
                    con.Products_CSV_for_Extranet_1__c = con.Products_for_Extranet__c.MID(0,254);
                    con.Products_CSV_for_Extranet_2__c = con.Products_for_Extranet__c.MID(255,255);
                    con.Products_CSV_for_Extranet_3__c = con.Products_for_Extranet__c.MID(510,255);
                    con.Products_CSV_for_Extranet_4__c = con.Products_for_Extranet__c.MID(765,255);
                }
                else if(con.account.products__c == null)
                {
                    con.Products_for_Extranet__c = '';
                    con.Products_CSV_for_Extranet_1__c = '';
                    con.Products_CSV_for_Extranet_2__c = '';
                    con.Products_CSV_for_Extranet_3__c = '';
                    con.Products_CSV_for_Extranet_4__c = '';
                }
                system.debug('______con.Products_CSV_for_Extranet_1__c______' + con.Products_CSV_for_Extranet_1__c);
                system.debug('______con.Products_CSV_for_Extranet_2__c______' + con.Products_CSV_for_Extranet_2__c);
                updContact.add(con);
            }   
        }
        
        if(updContact.size() > 0 && updContact != null)
        {
            update updContact;
        }
    }
    
    // 2018-10-17 - Allium IT - Removed by Joe Bunda per client request
    /*
    public static void linkDomainAccount(List <contact> records) { 	
    	
    	//Modified by Trekbin on 14 Oct, 2015.
    	map<string,Domain__c> domainMap = new map<string,Domain__c>();
		set<Id> setNoMatchingDomainContactIds = new set<Id>();
		List<Contact> lstContactsToUpdate = new List<Contact>();
		
        for(Domain__c dm :[	SELECT id,Account_Name__c,Domain_Name__c 
        					FROM domain__c 
        					WHERE Domain_Name__c != null
        				  ]) {
        	
            domainMap.put(dm.Domain_Name__c,dm);
        }
           
        for(contact con : records) {
        	
            AccountCustomSettings__c acs = AccountCustomSettings__c.getOrgDefaults();
      		
            if (con.accountId != null && con.accountId == acs.Self_Registration_Account_ID__c && domainMap.containsKey(con.Domain__c)) {
            	
                if(domainMap.containskey(con.Domain__c) && domainMap.get(con.Domain__c).Account_Name__c == null) {
                	
                    Contact objContact = new Contact(Id = con.Id, No_Matching_Domain__c = true);
                    lstContactsToUpdate.add(objContact);
                    setNoMatchingDomainContactIds.add(objContact.Id);
                
                } else if(domainMap.containskey(con.Domain__c) && domainMap.get(con.Domain__c).Account_Name__c != null) {
                	
                    Contact objContact = new Contact(Id = con.Id, accountId = domainMap.get(con.Domain__c).Account_Name__c, Domain_Match_Found__c = true);
                    lstContactsToUpdate.add(objContact);
                }
                
            } else {
            	
                Contact objContact = new Contact(Id = con.Id, No_Matching_Domain__c = true);
                lstContactsToUpdate.add(objContact);
                setNoMatchingDomainContactIds.add(objContact.Id);
            }
        }
        
        if(!lstContactsToUpdate.isEmpty())
        	update lstContactsToUpdate;
        	
        deactivateUser(setNoMatchingDomainContactIds);
    }
    
    @future
    public static void deactivateUser(set<Id> setNoMatchingDomainContactIds) {
    	
    	List<User> lstUsersToDisable = new List<User>();
    	
    	for(User objUser :  [	SELECT Isactive, IsPortalEnabled, Deactivate_User__c
        						FROM User 
        						WHERE ContactID IN:setNoMatchingDomainContactIds 
        						AND Isactive = true
        					]) {

        	objUser.Isactive = false;
        	objUser.Deactivate_User__c = true;
        	lstUsersToDisable.add(objUser);
        }

		if(!lstUsersToDisable.isEmpty()) { 
			
			try { 
				
				update lstUsersToDisable;
				
			} catch(exception e) {
				
				system.debug('--------message--------' + e.getMessage());
			}
			
		}	
    }
	*/
}