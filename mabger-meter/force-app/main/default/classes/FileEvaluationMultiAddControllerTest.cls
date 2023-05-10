/***
Purpose: FileEvaluationMultiAddControllerTest Test to verify various functions of TrainingActivityRelatedListController, 
A controller extension for Training activity related list
Date: 03/25/2017
***/
@isTest
private class FileEvaluationMultiAddControllerTest{
    private static User thisUser = [select Id from User where Id =: UserInfo.getUserId() limit 1];
    private static String trainingtype = 'Beacon/Cellular';
    private static Id profileId;
    private static User usr = new User();
    private static List < User > userList = new List < User > ();
    private static Training_Request__c cas;  
    private static Training_Activity__c ta;  
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
    private static Training_Activity__c insertActivity(Training_Request__c tr) {
        //ta = [select Id from Training_Activity__c where Training_Request__r.id =: tr.id limit 1];
        ta = new Training_Activity__c (Subject__c='test123-1', Status__c='Initiated', Training_Request__c=tr.id);
        insert ta;
        return ta;
    }
    /**
     * This method will verify if the records are getting inserted/updated
     * in File Evaluation object as expected.
     */
    static testMethod void verifyTrainingRequestSave() {    
        createTestData();

        System.RunAs(thisUser) {
            cas = insertCase('testTrainingReq-2');   
             ta = insertActivity(cas);       
        }
        Test.startTest();    
            
            ApexPages.StandardController sc = new ApexPages.StandardController(ta);
            FileEvaluationMultiAddController objcasc = new FileEvaluationMultiAddController(sc);

            PageReference pref = Page.FileEvaluationMultiAdd;
            pref.getParameters().put('Id', ta.id);
            Test.setCurrentPage(pref);
            
            
            
            objcasc.Add();
            objcasc.Save();
            objcasc.addMore();
            //objcasc.Save();
            //objcasc.Del();
            
            objcasc.back();

        Test.stopTest();

    }           
}