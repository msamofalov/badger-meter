/**
    @Name               :	CustomChangePasswordControllerTest
    @Date               :   30 Sep, 2015
    @Description        :   Test class for CustomChangePasswordController.
*/
@IsTest 
public with sharing class CustomChangePasswordControllerTest {
   	
   	@IsTest(SeeAllData=true) 
   	public static void testCustomChangePasswordController() {
        
        // Instantiate a new controller with all parameters in the page
        CustomChangePasswordController controller = new CustomChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}