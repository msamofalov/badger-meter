/**
    @Name               :	CustomForgotPasswordControllerTest
    @Date               :   29 Sep, 2015
    @Description        :   Test class for CustomForgotPasswordController.
*/
@IsTest 
public with sharing class CustomForgotPasswordControllerTest {
  	 
  	 @IsTest(SeeAllData=true) 
  	 public static void testCustomForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	CustomForgotPasswordController controller = new CustomForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    	
    	CustomForgotPasswordController controller1 = new CustomForgotPasswordController();
    	controller1.username = '';    
    	controller1.forgotPassword();
    }
}