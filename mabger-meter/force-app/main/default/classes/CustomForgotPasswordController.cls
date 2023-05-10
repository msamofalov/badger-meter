/**
    @Name               :           CustomForgotPasswordController
    @Date               :           28 Sep, 2015
    @Description        :           An apex page controller for CustomForgotPassword page that exposes the site forgot password functionality
    @TestClass          :      		CustomForgotPasswordControllerTest
*/
public with sharing class CustomForgotPasswordController {
    
	public String username {get; set;}   
	
	/* 
		@Name 			: CustomForgotPasswordController
		@Description	: Constructor.
		@Type			: public
	*/
	public CustomForgotPasswordController() {}
	
	/* 
		@Name 			: forgotPassword
		@Description	: method is called on click of submit button which redirects the user to CustomForgotPasswordConfirm page on success.
		@Type			: public
	*/
	public PageReference forgotPassword() {
	  
		if(username == '') {
		      
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Value is required.'));
			return null;
		
		} else {
	     
			boolean success = Site.forgotPassword(username);
			PageReference pr = Page.CustomForgotPasswordConfirm;
			pr.setRedirect(true);
				      
			if (success)        
				return pr;
	      
			return null;
		}
	}
}