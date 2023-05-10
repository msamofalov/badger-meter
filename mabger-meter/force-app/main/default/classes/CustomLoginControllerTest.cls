/**
    @Name               :	CustomLoginControllerTest
    @Date               :   29 Sep, 2015
    @Description        :   Test class for CustomLoginController.
*/
@IsTest 
global with sharing class CustomLoginControllerTest {
    
    @IsTest(SeeAllData=true) 
    global static void testCustomLoginController () {
        
        // Instantiate a new controller with all parameters in the page
        CustomLoginController controller = new CustomLoginController();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}