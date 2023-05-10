/**
    @Name               :	CustomRegistrationControllerTest
    @Date               :   29 Sep, 2015
    @Description        :   Test class for CustomRegistrationController.
*/
@IsTest 
public with sharing class CustomRegistrationControllerTest {
    
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegController() {
    	
    	User objUser = new User(FirstName = 'FirstName', lastName = 'LastName', Email = 'test@force.com');
    	Apexpages.StandardController sc = new Apexpages.StandardController(objUser);
    	
        CustomRegistrationController controller = new CustomRegistrationController(sc);
        
        // registerUser will always return null when the page isn't accessed as a guest user
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        controller.objNewProtalUser = objUser;
        System.assert(controller.registerUser() == null);  
        
        User objUser1 = new User(FirstName = 'FirstName', lastName = 'LastName', Email = 'test@badgermeter.com');
    	Apexpages.StandardController sc1 = new Apexpages.StandardController(objUser1);
    	
        CustomRegistrationController controller1 = new CustomRegistrationController(sc1);
        
        // registerUser will always return null when the page isn't accessed as a guest user
        controller1.password = 'abcd1234';
        controller1.confirmPassword = 'abcd1234';
        controller1.objNewProtalUser = objUser1;
        System.assert(controller1.registerUser() == null); 
        
        User objUser2 = new User(FirstName = 'FirstName', lastName = 'LastName', Email = 'test@badgermeter.com');
    	Apexpages.StandardController sc2 = new Apexpages.StandardController(objUser2);
    	
        CustomRegistrationController controller2 = new CustomRegistrationController(sc2);
        
        // registerUser will always return null when the page isn't accessed as a guest user
        controller2.password = 'abcd1234';
        controller2.confirmPassword = 'abcd123';
        controller2.objNewProtalUser = objUser2;
        System.assert(controller2.registerUser() == null); 
        
        User objUser3 = new User(FirstName = 'FirstName', lastName = 'LastName', Email = 'test@force.com');
    	Apexpages.StandardController sc3 = new Apexpages.StandardController(objUser3);
    	
        CustomRegistrationController controller3 = new CustomRegistrationController(sc3);
        
        // registerUser will always return null when the page isn't accessed as a guest user
        controller3.password = 'abcd1234';
        controller3.confirmPassword = 'abcd1234';
        controller3.objNewProtalUser = objUser;
        System.assert(controller3.registerUser() == null);  
    }    
}