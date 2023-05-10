@IsTest
public class UProductUnitTest {
	
    @TestSetup
    public static void createTestData () {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Case testCase = new Case(AccountId=testAccount.Id, Subject='Test Case', Status='Open');
        insert testCase;
        
        Product_Line__c testProductLine = new Product_Line__c(Case__c=testCase.Id);
        insert testProductLine;
        
        List <Product_Units__c> testProductUnits = new List <Product_Units__c> ();
        for (Integer i = 0; i < 400; i++) {
            testProductUnits.add(new Product_Units__c(Case__c=testCase.Id, Product_Line__c=testProductLine.Id));
        }
        insert testProductUnits;
    }
    
    
    public static testmethod void test () {
        Product_Units__c testProductUnit = [Select Id, Product_Line__c From Product_Units__c Limit 1];
        Integer productUnitCount = (Integer) [Select Product_Line__c, Count(Id) ProductUnitCount From Product_Units__c Where Product_Line__c = :testProductUnit.Product_Line__c Group By Product_Line__c Limit 1][0].get('ProductUnitCount');
        System.debug(productUnitCount);
        
        Test.startTest();
        update testProductUnit;
        Test.stopTest();
        
		testProductUnit = [Select Id, Product_Line__c, ProductUnitLineNumber__c From Product_Units__c Where Id = :testProductUnit.Id];
		System.debug(testProductUnit.ProductUnitLineNumber__c);  
        
        // Ensure that the code assigned the next product unit line number.
        System.assertEquals(productUnitCount+1, testProductUnit.ProductUnitLineNumber__c);
    }
    
}