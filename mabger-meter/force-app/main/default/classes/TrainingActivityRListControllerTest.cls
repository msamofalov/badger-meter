/***
Purpose: TrainingActivityRelatedListControllerTest Test to verify various functions of TrainingActivityRelatedListController, 
A controller extension for Training activity related list
Date: 01/25/2017
***/
@isTest
private class TrainingActivityRListControllerTest{
    private static User thisUser = [select Id from User where Id = : UserInfo.getUserId() limit 1];
    //private static ID trainingRecID = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Training Request').getRecordTypeId();
    private static string trainingType = 'Beacon/Cellular';
    private static Id profileId;
    private static User usr = new User();
    private static List < User > userList = new List < User > ();
    private static Training_Request__c cas;
    /**
     * This method is used to create test data.
     */
    private static void createTestData() {
        //to get the profile userId
        profileId = UTIL_TestDataCreation.getProfileID('2017 Training User');        
        //insert a specialist User
        usr = UTIL_TestDataCreation.createUser('testUser', profileId);
        userList.add(usr);
        
        Database.insert(userList);
    }   
    /**
     * insertCase - Reusable method   
     */    
    private static Training_Request__c insertCase(string subj){
        Date receivedByTrainingRequiredField = Date.valueOf('2019-02-07');
        cas=new Training_Request__c(Name=subj, Received_by_Training__c = receivedByTrainingRequiredField);
        insert cas;
        return cas;
    }     
    /**
     * This method will verify if the records are getting inserted/updated
     * in Case object as expected.
     */
    static testMethod void verifyTrainingRequestSave() {    
        createTestData();

        System.RunAs(thisUser) {
            cas = insertCase('testTrainingReq-2');          
        }
        Test.startTest();    
            
            ApexPages.StandardController sc = new ApexPages.StandardController(cas);
            TrainingActivityRelatedListController objcasc = new TrainingActivityRelatedListController(sc);

            PageReference pref = Page.TrainingActivityList;
            pref.getParameters().put('Id', cas.id);
            Test.setCurrentPage(pref);
            
            objcasc.getCaseStatus();
            objcasc.getIFItems();
            objcasc.getNonIFItems();
            //objcasc.getActivities();
            
            objcasc.processSelected();
            objcasc.CreateNew();
        Test.stopTest();

    }    
}