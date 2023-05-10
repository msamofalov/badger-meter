/***
Name: TrainingListViewsController
Purpose:  
    Custom list views to control what to display for users and also custom buttons
    TODO: Enhance for community users to accomodate what lists are visible for them
Date: 01/25/2017
***/
public class TrainingListViewsController {
    private ApexPages.StandardSetController controller;
    public TrainingListViewsController(ApexPages.StandardSetController controller) {
        this.controller = controller;
    }
    public PageReference save()
    {
        controller.save();
        PageReference parentPage = new PageReference('/apex/TrainingListViews');
        parentPage.setRedirect(true);
        return parentPage;
    }
    /**
     * This method purpose is to redirect to create training request visualforce page - CreateTrainingRequest
     * URLParam : Record Type
     */    
    public PageReference create() {
        //TODO future 
        // Map<String,Id> caseRecTypes = UTIL_BMApex.getRecordTypeMapForObjectGeneric(Case.SObjectType);

        //PageReference parentPage = new PageReference('/apex/CreateTrainingRequest/RecordType=012n00000004U77&sfdc.override=1');
        //Id recTypeId = Schema.SObjectType.Training_Request__c.getRecordTypeInfosByName().get('Training Request').getRecordTypeId();        
        //string strRedirURL = '/apex/CreateTrainingRequest';
        //strRedirURL += '?retURL=%2F006%2Fo&save_new=1&sfdc.override=1';
        string strRedirURL = '/a1G/e?retURL=%2Fa1G%2Fo';
        PageReference parentPage = new PageReference(strRedirURL);
        
        parentPage.setRedirect(true);
        return parentPage;
    }    
}