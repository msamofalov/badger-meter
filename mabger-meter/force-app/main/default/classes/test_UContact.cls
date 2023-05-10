@isTest(SeeAllData=true)
public class test_UContact {
 
    public static testMethod void ContactMeth()
    {
        //cretae Account
        Account acc1 = new Account();
        acc1.Type = 'End User - 1';
        acc1.Name = 'Test Acc1';
        acc1.products__c = 'test product';
		acc1.BillingCountryCode = 'US';
		acc1.BillingPostalCode = '68137';
        insert acc1;
        
        //Create Contact..
        Contact con = new Contact();
        con.LastName= 'TestCon';
        con.AccountId = acc1.Id;
        con.Pricebook_Location__c = 'Latin America';
        insert con ;
        
        system.debug('_______con_____' + con);

        con.Pricebook_Location__c = 'United States';
        update con;

        system.debug('_______con2____' + con);
       

  }
    
	// 2018-10-17 - Allium IT - Removed by Joe Bunda per client request
    /*
    static testMethod void testLinkDomainAccount() {
        
        //cretae Account
        Account acc1 = new Account();
        acc1.Type = 'End User - 1';
        acc1.Name = 'Test Acc1';
        acc1.products__c = 'test product';
		acc1.BillingCountryCode = 'US';
		acc1.BillingPostalCode = '68137';
        insert acc1;
        
        AccountCustomSettings__c acs = AccountCustomSettings__c.getOrgDefaults();
        
        Domain__c dm = new Domain__c(Account_Name__c = acc1.Id, Domain_Name__c = 'trigger.com');
        insert dm;
        
        //Create a contact
        contact c = new contact(accountid=acs.Self_Registration_Account_ID__c, firstname='test', lastname='test', Email = 'testDeactiv@trigger.com');
        insert c;
        
    }
    
    static testMethod void testdeactivateUser() {
        
        //cretae Account
        Account acc1 = new Account();
        acc1.Type = 'End User - 1';
        acc1.Name = 'Test Acc1';
        acc1.products__c = 'test product';
		acc1.BillingPostalCode = '68137';
		acc1.BillingCountryCode = 'US';
        insert acc1;
        
        Domain__c dm = new Domain__c(Account_Name__c = acc1.Id, Domain_Name__c = 'trigger.com');
        insert dm;
        
        //Create a contact
        Contact c = new Contact(accountid=acc1.id, firstname='test', lastname='test', Email = 'testDeactiv@trigger.com');
        insert c;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User']; 
        
        User u = new User();
        u.Alias = 'deact';
        u.Email = 'testDeactiv@trigger.com';
        u.EmailEncodingKey = 'UTF-8';
        u.Firstname = 'Test';
        u.Lastname = 'User';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.Profileid = p.Id;
        u.TimezoneSidKey = 'America/Los_Angeles';
        u.Username = 'testDeactiv@trigger.com';
        u.isActive = true;
        u.ContactId = c.Id;
        
        insert u;
        
        Set<Id> setContactIds = new Set<Id>{c.id};
        Test.startTest();
            UContact.deactivateUser(setContactIds);
        Test.stopTest();
    }
    */
    
    static testMethod void testBatchDisableCommunityUser() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User u = new User();
        u.Alias = 'deact';
        u.Email = 'testDeactiv1@trigger.com';
        u.EmailEncodingKey = 'UTF-8';
        u.Firstname = 'Test';
        u.Lastname = 'User';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.Profileid = p.Id;
        u.TimezoneSidKey = 'America/Los_Angeles';
        u.Username = 'testDeactiv1@trigger.com';
        u.isActive = true;
        u.Deactivate_User__c = true;
        insert u;
        
        Database.executebatch(new BatchDisableCommunityUser());
    }
    
    //static testMethod void testScheduleBatchDisableCommunityUser() {
    //    
    //    ScheduleBatchDisableCommunityUser.scheduleBatch();
   // }
}