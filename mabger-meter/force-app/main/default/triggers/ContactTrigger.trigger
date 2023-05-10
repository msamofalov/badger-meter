/* ************************************************************
 * Created By    : Raja Y (GearsCRM)
 * Created Date  : 09/15/2015
 * Description   : Trigger for the contact object
 * 
 * Modified By   :
 * Modified Date : 
 * Description   :
 * 
 * ************************************************************/   
trigger ContactTrigger on contact (before insert, before update, after insert, after update) 
{
    List<contact> records = trigger.isDelete ? trigger.old : trigger.new;
    
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            UContact.updatePricebookLocation(records,trigger.oldmap);
            //UContact.linkDomainAccount(records);
        }
        else if(trigger.isUpdate)   
        {
            UContact.updatePricebookLocation(records,trigger.oldmap);
        }
        //else if(trigger.isDelete)
        //{     
        //}   
    }
    
    else if(trigger.isAfter)
    {
        if(trigger.isInsert)  
        {
            UContact.updateProductDetails(records,trigger.oldmap);
            
            //Modified by Trekbin on 14 Oct, 2015.
            // 2018-10-17 - Allium IT - Removed by Joe Bunda per client request
        	//UContact.linkDomainAccount(records);
        }
        else if(trigger.isUpdate)
        {
        	
            UContact.updateProductDetails(records,trigger.oldmap);
        }
       //else if(trigger.isDelete)
       //{
       //}
       //else if(trigger.isUndelete)
       //{   
       //}
    }
}