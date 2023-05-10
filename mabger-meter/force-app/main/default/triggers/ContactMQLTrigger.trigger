trigger ContactMQLTrigger on Contact (before update) {
    
    Map<ID,Contact> cIdToContact = new Map<Id, Contact> ([SELECT account.ID,Account.Organization_Type__c,Account.Name FROM Contact WHERE ID IN : Trigger.new]);
    System.debug('>>cIdToContact>>' + cIdToContact);

    List<Lead> newLeadList = new List<Lead>();

    Set<Id> accIdSet = new Set<Id>();

    for(Contact c : Trigger.new){
        accIdSet.add(c.Accountid);  
    }

    Map<Id,Account> accMap = new Map<Id,Account>([Select Id, Account.Name, Account.Organization_Type__c from Account where id =: accIdSet]);    
    System.debug('>>accMap>>' + accMap);

    for(Contact con : Trigger.new){
    //Here I am checking if the previous value was no and updated to new then needs to create lead 
        if((con.Lifecycle_Status__c=='03 - MQL'&&con.Business_Unit__c!='Flow') && Trigger.oldMap.get(con.Id).Lifecycle_Status__c!='03 - MQL'&&con.Business_Unit__c!='Flow') {  

            Lead led=new Lead();
            led.Company=accMap.get(con.Accountid).Name;
            led.LastName=con.LastName;
            led.FirstName=con.FirstName;
            led.Title=con.Title;
            led.Country=con.MailingCountry;
            led.State=con.MailingState;
            led.City=con.MailingCity;
            led.Street=con.MailingStreet;
            led.Email=con.Email;
            led.Phone=con.Phone;
            led.Form_Comments__c=con.Form_Comments_Contact__c;
            led.Form_Comments_History__c=con.Form_Comments_History_Contact__c;
            led.Hide_from_Marketo__c = TRUE;
            led.Industry__c=con.Industry__c;
            led.LeadSource=con.LeadSource;
            led.Lifecycle_Status__c=con.Lifecycle_Status__c;
            led.Contact__c=con.id;
            led.Description=con.Description;
            led.Organization_Type__c=accMap.get(con.Accountid).Organization_Type__c;
            led.mkto_si__Last_Interesting_Moment_Date__c=con.mkto_si__Last_Interesting_Moment_Date__c;
            led.mkto_si__Last_Interesting_Moment_Desc__c=con.mkto_si__Last_Interesting_Moment_Desc__c;
            led.mkto_si__Last_Interesting_Moment_Source__c=con.mkto_si__Last_Interesting_Moment_Source__c;
            led.mkto_si__Last_Interesting_Moment_Type__c=con.mkto_si__Last_Interesting_Moment_Type__c;
            System.Debug('Contact Lifecycle Status = 03 - MQL' + led.Lifecycle_Status__c);
            // Add more fields here
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            led.setOptions(dmo);
            newLeadList.add(led);

        }
 
    }
    
    //insert into leads
    System.debug('>>newLeadList>>' + newLeadList);  
    Insert newLeadList; 
    
}