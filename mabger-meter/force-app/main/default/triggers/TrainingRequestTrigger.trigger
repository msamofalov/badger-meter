/***
@Purpose: Training Request Trigger Handler to handle various events.. 
@Date: 01/25/2017
    OnAfterInsert - For Auto task creation TODO - Move code to internal function
@TODO: TriggerFactory interface and other framework components 
Version2 -
    @Author: Salesforce PA
    @Purpose:TrainingRequestTrigger Handler that updates Account with TrainingRequest's No of Sevices(Electric, Gas, Water) 
    @Date: 01/25/2017 
***/
trigger TrainingRequestTrigger on Training_Request__c (after delete, after insert, after update, before delete, before insert, before update)
{
    //TODO Future - Implement triggerfactory
    // TriggerFactory.createHandler(Case.sObjectType);
    
    TrainingRequestTriggerHandler handler = new TrainingRequestTriggerHandler(Trigger.isExecuting, Trigger.size);
    /*
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    else 
    */
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    //TODO: merge this and above if condition
    if(Trigger.isAfter &&(Trigger.isInsert || Trigger.isUpdate)){
        Try{
            if(Trigger.isInsert)
                handler.onAfterInsert(Trigger.newMap);
            else 
                handler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
        }Catch(Exception ex){System.debug('@Exception=='+ex.getStackTraceString()+'--'+ex.getMessage());}
    }  
    //Futre methods  
    /*
    else if(Trigger.isUpdate && Trigger.isBefore){
        //handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        //handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        //CaseTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }
    
    else if(Trigger.isDelete && Trigger.isBefore){
        //handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        //handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        //AccountTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
    
    else if(Trigger.isUnDelete){
        //handler.OnUndelete(Trigger.new);    
    }  
    */ 
}