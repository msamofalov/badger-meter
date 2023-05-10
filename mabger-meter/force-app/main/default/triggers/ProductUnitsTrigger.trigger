/**
    Created By          :   Raja Yeccherla(GearsCRM)
    Created Date        :   15 Dec, 2015
    Description         :   ProductUnitsTrigger.
     
    Modified By         :    
    Modified Date       :    
    Description         :    
    
*/
trigger ProductUnitsTrigger on  Product_Units__c (before insert, before update)
{
    List<Product_Units__c> records = (trigger.isDelete) ? trigger.old : trigger.new;
  
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            UProductUnit.createProductUnitLineNumber(records);
        }
        else if(Trigger.isUpdate)
        {
            UProductUnit.createProductUnitLineNumber(records);
        }
    }
}