/**
    Created By         :   Raja Yeccherla(GearsCRM)
    Created Date       :   15 Dec, 2015
    Description        :   ProductLineTrigger.
     
    Modified By         :    
    Modified Date       :    
    Description         :    
    
*/
trigger ProductLineTrigger on  Product_Line__c(after insert, after update)
{

    List<Product_Line__c> records = (trigger.isDelete) ? trigger.old : trigger.new;
 
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            UProductLine.createNewProductUnits(records);
        }
        else if(Trigger.isUpdate)
        {
            UProductLine.createNewProductUnits(records);
        }
    }
}