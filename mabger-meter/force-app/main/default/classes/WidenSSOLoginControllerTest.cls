@IsTest
public class WidenSSOLoginControllerTest {
    
    @TestSetup
    public static void createTestData () {
        // Account
        Account testPartnerAccount = new Account ();
        testPartnerAccount.Name = 'Test Partner Account';
        testPartnerAccount.Market_Libraries__c = 'Concrete Finishing Partner Library';
        insert testPartnerAccount;

        Contact testPartnerContact = new Contact ();
        testPartnerContact.AccountId = testPartnerAccount.Id;
        testPartnerContact.FirstName = 'External';
        testPartnerContact.LastName = 'McTesterson';
        testPartnerContact.Email = 'external.mctesterson@gmail.com';
        insert testPartnerContact;

        Id standardUserProfile = [Select Id From Profile Where Name = 'Badger Meter - Standard User' Limit 1].Id;
        Id communityUserProfile = [Select Id From Profile Where Name = '2018 Partner Central Community User' Limit 1].Id;
        
        User testInternalUser = new User();
        testInternalUser.FirstName = 'Internal';
        testInternalUser.LastName = 'McTesterson';
        testInternalUser.Email = 'internal.mctesterson@notarealorg.com';
        testInternalUser.Username = 'internal.mctesterson@notarealorg.com';
        testInternalUser.Alias = 'imctest';
        testInternalUser.CommunityNickName = 'imctest';
        testInternalUser.ProfileId = standardUserProfile;
        testInternalUser.LocaleSidKey = 'en_US';
        testInternalUser.LanguageLocaleKey = 'en_US';
        testInternalUser.EmailEncodingKey = 'UTF-8';
        testInternalUser.TimeZoneSidKey = 'America/Chicago';
        testInternalUser.IsActive = true;      
        insert testInternalUser;

        User testExternalUser = new User();
        testExternalUser.FirstName = 'External';
        testExternalUser.LastName = 'McTesterson';
        testExternalUser.Email = 'external.mctesterson@notarealorg.com';
        testExternalUser.Username = 'external.mctesterson@notarealorg.com';
        testExternalUser.Alias = 'emctest';
        testExternalUser.CommunityNickName = 'emctest';
        testExternalUser.ProfileId = communityUserProfile;
        testExternalUser.LocaleSidKey = 'en_US';
        testExternalUser.LanguageLocaleKey = 'en_US';
        testExternalUser.EmailEncodingKey = 'UTF-8';
        testExternalUser.TimeZoneSidKey = 'America/Chicago';
        testExternalUser.IsActive = true;
        testExternalUser.ContactId = testPartnerContact.Id;
        insert testExternalUser;


    }
    
    public static testmethod void testInternalUserLogin () {
        Test.setMock(HttpCalloutMock.class, new WidenSSOLoginControllerTestMock());

        User internalUser = [Select Id From User Where Name = 'Internal McTesterson' Limit 1];
        
        System.runAs(internalUser) {
            Test.startTest();{
                new WidenSSOLoginController().authenticateAndRedirectToWidenDAM();
            }Test.stopTest();
        }
    }


    public static testmethod void testExternalUserLogin () {
        PageReference testPageReference = Page.WidenSSOLoginFlow;
        Test.setCurrentPage(testPageReference);
        Test.setMock(HttpCalloutMock.class, new WidenSSOLoginControllerTestMock());


        User externalUser = [Select Id From User Where Name = 'External McTesterson' Limit 1];
        
        System.runAs(externalUser) {
            Test.startTest();{
                new WidenSSOLoginController().authenticateAndRedirectToCommunityHome();
            }Test.stopTest();
        }
    }

}