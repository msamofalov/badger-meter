/***
Purpose: TrainingListViewsControllerTest Test to verify various functions of TrainingListViewsController, A controller extension
Date: 01/25/2017
***/
@isTest
private class TrainingListViewsControllerTest{
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
        profileId = UTIL_TestDataCreation.getProfileID('Badger Meter - Training User');        
        //insert a specialist User
        usr = UTIL_TestDataCreation.createUser('testUser', profileId);
        userList.add(usr);
        
        Database.insert(userList);
    }   
    /**
     * insertCase - Reusable method   
     */    
    private static Training_Request__c insertCase(string subj){
        cas=new Training_Request__c(Name=subj,
                          Training_type__c = trainingType
                        );
        insert cas;
        return cas;
    }     
    /**
     * This method will verify if the records are getting inserted/updated
     * in Case object as expected.
     */
    static testMethod void verifyTrainingRequestCreate() {    
        createTestData();
        List <Training_Request__c> lstCase = new List<Training_Request__c>();

        System.RunAs(thisUser) {
            cas = insertCase('testTrainingReq-2');
            lstCase.add(cas);
            cas = insertCase('testTrainingReq-3');
            lstCase.add(cas);            
        }
        Test.startTest();    
            PageReference pref = Page.TrainingListViews;
            Test.setCurrentPage(pref);
    
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstCase);
            stdSetController.setSelected(lstCase);
            TrainingListViewsController objcasc = new TrainingListViewsController(stdSetController);
            objcasc.create();
        Test.stopTest();
    }
    static testMethod void verifyTrainingRequestSave() {    
        createTestData();
        List <Training_Request__c> lstCase = new List<Training_Request__c>();

        System.RunAs(thisUser) {
            cas = insertCase('testTrainingReq-2');
            lstCase.add(cas);
            cas = insertCase('testTrainingReq-3');
            lstCase.add(cas);            
        }
        Test.startTest();    
            PageReference pref = Page.TrainingListViews;
            Test.setCurrentPage(pref);
    
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstCase);
            stdSetController.setSelected(lstCase);
            TrainingListViewsController objcasc = new TrainingListViewsController(stdSetController);
            objcasc.save();
        Test.stopTest();

    }    
}