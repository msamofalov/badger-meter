@isTest
private class TestContactUpdate{

    static testMethod void Contact_MQL_Update(){    
              
        Account acc = new Account(
            Name = 'testaccount',
            Organization_Type__c = 'UC - Utility Customer'             
        );
        insert acc;

        Id p = [SELECT id FROM Profile WHERE Name='2017 Badger Meter Partner Community User'].id;
                    
        Contact con = new Contact(
            AccountId = acc.id,
            Lastname = 'testcontact',
            Firstname ='testdata1',
            Email='test123@noemail.com',
            OwnerId = Userinfo.getUserid(),
            Lifecycle_Status__c = '02 - MCL'
            );
        insert con;  
                  
        User user = new User(
            Alias = 'badger12',
            Email='badgermetertest123@noemail.com',
            Emailencodingkey='UTF-8',
            Lastname='Testing',
            Languagelocalekey='en_US',
            Localesidkey='en_US',
            Profileid = p, 
            Country='United States',
            IsActive =true,
            ContactId = con.Id,
            Timezonesidkey='America/Los_Angeles', 
            Username='badgermetertest123@noemail.com');
       
        insert user;
        system.runAs(user) {
            // statements to be executed by this test user.
        }

        con.Lifecycle_Status__c='03 - MQL';
        con.Flow_Concrete_Finishing__c=TRUE;
        con.Flow_Process_Valve__c=TRUE;
        con.Flow_RA_Distributor__c=TRUE;
        con.Flow_Test_Measure__c=TRUE;
        con.Utility__c=TRUE;
              
        Test.startTest();
        update con;
        Test.stopTest();

        //Requery the contact record and check to make sure it was updated.
        Contact result = 
            [Select
               Lifecycle_status__c,Flow_Concrete_Finishing__c,Flow_Process_Valve__c,Flow_RA_Distributor__c,Flow_Test_Measure__c,Utility__c
            From
                Contact
            ];

        System.assertEquals(
        con.Lifecycle_Status__c,result.Lifecycle_Status__c);    
    }
}