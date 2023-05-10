@isTest(seealldata = true) 
private class UProductLine_Test
{
    static testMethod void Test1()
    {
       id caseRecordTypeId = Sobjecttype.case.getRecordTypeInfosByName().get('Invoice Inquiry').getRecordTypeId();
        
        //cretae Account  
        Account acc1 = new Account();
        acc1.Type = 'End User - 1';
        acc1.Name = 'Test Acc1';
		acc1.BillingCountryCode = 'US';
		acc1.BillingPostalCode = '68137';
        insert acc1;
        
        Case c = new Case();
        c.subject = 'test123';
        c.status = 'open';
        c.AccountId = acc1.id;
        insert c;
       
        Product_Line__c pl = new Product_Line__c();
        pl.Case__c = c.id;
        pl.Sample_Size__c = 2;
        pl.Description__c = 'Test product line';
        insert pl;
        
        pl.sample_size__c = 3;
        update pl;
    }
}