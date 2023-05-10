/**
    @Name               :           CustomChangePasswordController
    @Date               :           30 Sep, 2015
    @Description        :           An apex page controller for CustomChangePassword page that exposes the change password functionality.
    @TestClass          :      		CustomChangePasswordControllerTest
*/
public with sharing class CustomChangePasswordController {
    
	public String oldPassword {get; set;}
	public String newPassword {get; set;}
	public String verifyNewPassword {get; set;}        
    
    /* 
		@Name 			: changePassword
		@Description	: method is called on click of change password button which changes the password of the user on success.
		@Type			: public
	*/
	public PageReference changePassword() {
	    
		return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
	}     
    
    //Constructor.
	public CustomChangePasswordController() {}
}