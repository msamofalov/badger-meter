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
public with sharing class TrainingRequestTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public TrainingRequestTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    /*
    @Author: Salesforce PA
    @Purpose:TrainingRequestTrigger Handler that create auto tasks (activities custom object) - based on the training type selected 
    @Date: 01/25/2017
    */
    public void OnAfterInsert(Training_Request__c[] newCases){
        List<Training_Activity__c> newtasks = new List<Training_Activity__c>();
        List<Training_Activities__c> relatedTrainingActivities = new List<Training_Activities__c>();
        Set<ID> RTIds = new Set<ID>();  //set of Record Type IDs to match
        Set<string> activityList = new Set<string>();
        for(Training_Request__c newCase : newCases)
        {
                relatedTrainingActivities = [select Milestone_or_Activity__c, Training_Activity_Owner__c, Training_Session_Activity__c, Sequence__c, Dependencies__c, Interface_Analysis__c FROM Training_Activities__c WHERE Training_Type_2__c =: newCase.training_type__c Order By Training_Type_2__c, Sequence__c ];             
                //TODO Required bulkification
                system.debug('newCase.training_type__c-'+ newCase.training_type__c);
                system.debug('relatedTrainingActivities.size()-'+ relatedTrainingActivities.size());
                for (Integer i=0; i<relatedTrainingActivities.size(); i++) {
                    Training_Activity__c newTask = new Training_Activity__c();
                    newTask.Subject__c =relatedTrainingActivities[i].Milestone_or_Activity__c; // Milestone_or_Activity__c
                    newTask.Training_Request__c = newCase.id;
                    newTask.Owner_2__c = relatedTrainingActivities[i].Training_Activity_Owner__c;
                    newTask.Interface_Analysis__c = relatedTrainingActivities[i].Interface_Analysis__c;
                    newTask.Dependencies__c  = relatedTrainingActivities[i].Dependencies__c ;
                    newTask.Activity_Sequence__c = relatedTrainingActivities[i].Sequence__c;
                    newTask.status__c = 'Initiated'; //Not Started
                    newtasks.add(newTask);
                }
        }
        if(newtasks.size() > 0)
            insert newtasks;               
    }
    @future public static void OnAfterInsertAsync(Set<ID> newCaseIDs){
        //Example usage
        //List<Training_Request__c> newCases = [select Id, name from Training_Request__c where Id IN :newCaseIDs];
    }  
    /*
    @Author: Salesforce PA
    @Purpose:TrainingRequestTrigger Handler that updates Account with TrainingRequest's No of Sevices(Electric, Gas, Water) 
    @Date: 01/25/2017
    */    
    public void onAfterInsert(Map<Id,Training_Request__c> trainRequestsMapNew){
        // Guard Condition 
        if(trainRequestsMapNew!=null && !trainRequestsMapNew.isEmpty()){
            
            List<Account> accountsToUpdate = new List<Account>();
            //Gets Current Salesforce Query Limit, i.e max no of records ex:50000
            Integer queryLimit = System.Limits.getLimitQueries();

            //Queries all the training requests along with Accounts
            // Iterates each training request
            for(Training_Request__c tr: [SELECT ID,End_User_Account__c,End_User_Account__r.Number_of_Water_Services__c,End_User_Account__r.Number_of_Electric_Services__c,
                                                End_User_Account__r.Number_of_Gas_Services__c,Number_Of_Services_Water__c,Number_Of_Services_Electric__c,Number_Of_Services_Gas__c FROM Training_Request__c WHERE ID IN:trainRequestsMapNew.keySet() ORDER BY CreatedDate DESC LIMIT: queryLimit]){
                
                //Checks whether any of the No of Sevices(Electric, Gas, Water) has greater than zero or not 
                if(tr.End_User_Account__c!=null && (tr.Number_Of_Services_Water__c>0 || tr.Number_Of_Services_Electric__c>0 || tr.Number_Of_Services_Gas__c>0)){                    
                    
                    Account acc = new Account();
                        acc.Id=tr.End_User_Account__c;
                    if(tr.Number_Of_Services_Water__c>0)
                        acc.Number_of_Water_Services__c=String.valueOf(tr.Number_Of_Services_Water__c);
                    if(tr.Number_Of_Services_Electric__c>0)
                        acc.Number_of_Electric_Services__c = String.valueOf(tr.Number_Of_Services_Electric__c);
                    if(tr.Number_Of_Services_Gas__c>0)
                        acc.Number_of_Gas_Services__c = String.valueOf(tr.Number_Of_Services_Gas__c);
                    
                    accountsToUpdate.add(acc);                  

                }
            }
            //Update Accounts
            if(!accountsToUpdate.isEmpty()){
                update accountsToUpdate;
            }
            
        }
    }
    public void onAfterUpdate(Map<Id,Training_Request__c> trainRequestsMapNew,Map<Id,Training_Request__c> trainRequestsMapOld){
        // Guard Condition 
        if(trainRequestsMapNew!=null && !trainRequestsMapNew.isEmpty() && trainRequestsMapOld!=null && !trainRequestsMapOld.isEmpty()){
            Set<ID> trainRequestIds = new Set<ID>();

            //Filters Training Request Records that are having updated No of Sevices(Electric, Gas, Water)
            for(Training_Request__c tr:trainRequestsMapNew.values()){
                if(tr.Number_Of_Services_Water__c!=trainRequestsMapOld.get(tr.id).Number_Of_Services_Water__c || tr.Number_Of_Services_Electric__c!=trainRequestsMapOld.get(tr.id).Number_Of_Services_Electric__c || tr.Number_Of_Services_Gas__c!=trainRequestsMapOld.get(tr.id).Number_Of_Services_Gas__c)
                    trainRequestIds.add(tr.ID);
            }
            //Stores Accounts that are to be updated
            List<Account> accountsToUpdate = new List<Account>();
            //Gets Current Salesforce Query Limit, i.e max no of records ex:50000
            Integer queryLimit = System.Limits.getLimitQueries();

            //Queries all the training requests(which are filtered) along with Accounts
            // Iterates each training request
            for(Training_Request__c tr: [SELECT ID,End_User_Account__c,End_User_Account__r.Number_of_Water_Services__c,End_User_Account__r.Number_of_Electric_Services__c,
                                                End_User_Account__r.Number_of_Gas_Services__c,Number_Of_Services_Water__c,Number_Of_Services_Electric__c,Number_Of_Services_Gas__c FROM Training_Request__c WHERE ID IN:trainRequestIds ORDER BY CreatedDate DESC LIMIT: queryLimit]){
                
                //Checks whether any of the No of Sevices(Electric, Gas, Water) has greater than zero or not
                if(tr.End_User_Account__c!=null && (tr.Number_Of_Services_Water__c>0 || tr.Number_Of_Services_Electric__c>0 || tr.Number_Of_Services_Gas__c>0)){
                    
                    Account acc = new Account();
                        acc.Id=tr.End_User_Account__c;

                    //Checks whether any of the No of Sevices(Electric, Gas, Water) has changed or not
                    if(tr.Number_Of_Services_Water__c>0 && tr.Number_Of_Services_Water__c!=trainRequestsMapOld.get(tr.id).Number_Of_Services_Water__c)
                        acc.Number_of_Water_Services__c=String.valueOf(tr.Number_Of_Services_Water__c);
                    if(tr.Number_Of_Services_Electric__c>0 && tr.Number_Of_Services_Electric__c!=trainRequestsMapOld.get(tr.id).Number_Of_Services_Electric__c)
                        acc.Number_of_Electric_Services__c = String.valueOf(tr.Number_Of_Services_Electric__c);
                    if(tr.Number_Of_Services_Gas__c>0 && tr.Number_Of_Services_Gas__c!=trainRequestsMapOld.get(tr.id).Number_Of_Services_Gas__c)
                        acc.Number_of_Gas_Services__c = String.valueOf(tr.Number_Of_Services_Gas__c);
                    
                    accountsToUpdate.add(acc);              

                }
            }
            //Update Accounts
            if(!accountsToUpdate.isEmpty()){
                update accountsToUpdate;
            }
            
        }
    }          
}