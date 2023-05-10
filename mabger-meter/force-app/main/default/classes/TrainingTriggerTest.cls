/***
@Purpose: Training Request Trigger Test to handle various tests related to training Request trigg
@Date: 01/25/2017
***/
@isTest
private class TrainingTriggerTest{
    private static User thisUser = [select Id from User where Id = : UserInfo.getUserId() limit 1];
    //private static ID trainingRecID = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Training Request').getRecordTypeId();
    private static string trainingType = 'Beacon/Cellular';
    private static Id profileId;
    private static User usr = new User();
    private static List < User > userList = new List < User > ();
    private static Training_Request__c cas;
    private static Training_Activities__c tac;
    
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
    // insertCase - Reusable method    
    private static Training_Request__c insertTR(){
        cas=new Training_Request__c(Name='testCaseTraining-123',
                          Training_type__c = trainingType
                        );
        insert cas;
        return cas;
    }
    /**
     * This method will verify if the records are getting inserted/updated
     * in Case object as expected.
     */
    static testMethod void verifyTrainingCaseCreation() {    
        createTestData();
        createActivityData();
        System.RunAs(thisUser) {
            cas = insertTR();
        }
    }
    //test creation of activity
    private static void createActivityData(){
        List<Training_Activities__c> lTac = new List<Training_Activities__c>();
        tac=new Training_Activities__c(
            Milestone_or_Activity__c = 'Do Something',
            Training_Type_2__c =trainingType);
        lTac.add(tac);
        tac=new Training_Activities__c(
            Milestone_or_Activity__c = 'Do Something2',
            Training_Type_2__c =trainingType);
        lTac.add(tac);
        tac=new Training_Activities__c(
            Milestone_or_Activity__c = 'Do Something3',
            Training_Type_2__c =trainingType);
        lTac.add(tac);  
        insert lTac;             
    }
    // test water,gas,electric service update on account
    static testMethod void updateTrainingRequest(){
        
        //Insert Account
        Account acc = new Account(Name='Test Account');
        insert acc;

        // Insert Training Request
        Training_Request__c tr = new Training_Request__c(End_User_Account__c=acc.id,Number_Of_Services_Water__c=2,Number_Of_Services_Electric__c=3,Number_Of_Services_Gas__c=5);
        insert tr;

        acc = [SELECT ID,Number_of_Water_Services__c,Number_of_Electric_Services__c,Number_of_Gas_Services__c FROM Account WHERE ID=:acc.id LIMIT 1];
        
        // Asserts that values are updated in Account
        system.assert(acc.Number_of_Water_Services__c=='2');
        system.assert(acc.Number_of_Electric_Services__c=='3');
        system.assert(acc.Number_of_Gas_Services__c=='5');

        tr.Number_Of_Services_Water__c = 10;
        update tr;

        acc = [SELECT ID,Number_of_Water_Services__c,Number_of_Electric_Services__c,Number_of_Gas_Services__c FROM Account WHERE ID=:acc.id LIMIT 1];
        
        // Asserts that value is updated in Account
        system.assert(acc.Number_of_Water_Services__c=='10');
        

    }    
}