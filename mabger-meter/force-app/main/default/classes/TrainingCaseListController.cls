/***
Purpose: TrainingCaseListController Used by Home Page Layout to display recently created Training Request cases
Date: 01/25/2017
***/
public class TrainingCaseListController {
    public List<Training_Request__c> trList;
    public TrainingCaseListController() {
        trList = [SELECT Training_Request_Number__c, Id, Name, Status__c, Training_Type__c FROM Training_Request__c where status__c = 'Open' order by createddate desc limit 20];
    }

    /***
    Purpose: getter method for bidning with VF page
    Date: 01/25/2017
    ***/
    public List<Training_Request__c> getTrainingRequests() 
    {
        return trList;
    }
}