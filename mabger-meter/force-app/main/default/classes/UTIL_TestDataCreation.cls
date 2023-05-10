/***
Purpose: Class which stores the Test Data Creation methods for the Test classes.
Date: 02/11/2017
Class: UTIL_TestDataCreation
***/  
@istest
public class UTIL_TestDataCreation {
    /*
    * Description: This method is used to create User.
    */
    public static User createUser(String usrAlias, ID profileID) {
        try {
            User user = new User(alias = 'alias' , email= Usralias+'@badgermeter.com', emailencodingkey='UTF-8', lastname='testing', languagelocalekey='en_US', 
            localesidkey='en_US', timezonesidkey='America/Chicago', profileid = profileID, username= Usralias +'@badgermeter.com');
            return user; 
        } catch (Exception e) {
            throw e;
        }
    }
    /* 
    * Description: This method is used to retrieve the Profile Id of the System Admin
    */
    public static Id getSysAdminProfileID(){
        try {
            Profile prfle = [SELECT Id,Name FROM Profile WHERE Name =: 'System Administrator'];
            return prfle.Id; 
        } catch (Exception e) {
            throw e;
        }
    } 
    /**
    * Description: This method is used to retrieve the Profile Id .
    */
    public static Id getProfileID(String profileName){
        try {
            Id profileID = null;
            Profile prfle = [SELECT Id,Name FROM Profile WHERE Name =:ProfileName LIMIT 1];
            if(prfle!=null)profileID=prfle.Id;
            return profileID; 
        } catch (Exception e) {
            throw e;
        }
    }
    /**
    * Description: This method is used to retrieve the user related to the System Admin Profile.
    */
    public static User createSysAdminUser(){
        try {
            Id profileId =getSysAdminProfileID();
            User user = new User(alias = 'SysAdmi', email= 'SysAdmin'+'@badgermeter.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = profileID, timezonesidkey='America/Chicago', username= 'SysAdmin@badgermeter.com');
            return user; 
        } catch (Exception e) {
            throw e;
        }
    }  
    /**
     * Method Name :  createTask
     * Arguments: Subject,Type,UserId(AssignTo)
     * Return : Task
     * Description: This method is used to create a Task record
    */
    public static Task createTask(String subj,Id tskOwner,String typ){
        try {
            Task tsk = new Task(Subject=subj,ownerId=tskOwner,Type = typ);
            return tsk;   
        } catch (Exception e) {
            throw e;
        }
 
    }  
    /**
     * Method Name :  createSingleAccount
     * Arguments: String AccountName, Id AccOwner
     * Return : Account
     * Description: This method is used to create Account Test Data
     */
    /* 
    public static Account createSingleAccount(String accountName, Id accOwner){
        try{
            Account acc = new Account(Name=accountName,ownerId= accOwner, Phone = '(123) 456-7896',
                                ShippingStreet='323 Fairchild Drive',ShippingCity='Irving',ShippingState='TX',ShippingCountry='UNITED STATES',ShippingPostalCode='75043'); 
            return acc;  
            
        } catch (Exception e) {
            throw e;
        }
    }
    */
    /**
     * Method Name :  createTestAccount
     * Arguments: String AccountName
     * Return : Account
     * Description: This method is used to create Account Test Data .
     */
    public static Account createTestAccount(String accountName){
        try {
            Account acc = new Account(Name=accountName, Phone = '(123) 456-7896',
                                ShippingStreet='323 Fairchild Drive',ShippingCity='Irving',ShippingState='TX',ShippingCountry='UNITED STATES',ShippingPostalCode='75043'); 
            return acc;  
        } catch (Exception e) {
            throw e;
        }
    } 
    /**
     * Method Name :  createContact
     * Arguments: String FirstName,String LastName, Boolean primary
     * Return : Contact
     * Description: This method is used to create Contact Test Data .
     */
    public static Contact createContact(String firstName,String LastName){
        try {
            Contact con = new Contact(FirstName=firstName,LastName= lastName);
                                 
            return con; 
        } catch (Exception e) {
            throw e;
        }
    }                        
}