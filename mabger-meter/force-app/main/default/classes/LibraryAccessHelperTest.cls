@IsTest
public class LibraryAccessHelperTest {
    
    @TestSetup
    public static void createData () {
        Account testAccount = new Account(Name='Test Account', Market_Libraries__c='Utility Water Partner Library');
        insert testAccount;
    }
    
    
    public static testmethod void test1 () {
        Account testAccount = [Select Id, Name From Account Limit 1];
        
        Test.startTest();
        
        LibraryAccessHelper.updateAccess(testAccount);
        
        Test.stopTest();
    }
    
    
    public static testmethod void test2 () {
        Account testAccount = [Select Id, Name From Account Limit 1];
        
        Test.startTest();
        
        testAccount.Market_Libraries__c = 'Concrete Finishing Partner Library';
        update testAccount;
        
        Test.stopTest();
    }
}