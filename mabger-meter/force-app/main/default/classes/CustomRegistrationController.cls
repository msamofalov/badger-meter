/**
    @Name               :           CustomRegistrationController
    @Date               :           28 Sep, 2015
    @Description        :           An apex class that creates a portal user
    @TestClass          :      		CustomRegistrationControllerTest
*/
public with sharing class CustomRegistrationController {
    
	// PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
	// you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.     

    private String strUrlforRedirection ;
	public User objNewProtalUser {get; set;}         
	
	/* 
		@Name 			: CustomRegistrationController
		@Description	: Constructor.
		@Type			: public
		@Parameters		: ApexPages.StandardController
	*/
	public CustomRegistrationController (ApexPages.StandardController controller) {
		
		strUrlforRedirection = '';
		objNewProtalUser = new User();  
		 
		if(apexpages.currentpage().getparameters().containskey('startUrl') && apexpages.currentpage().getparameters().get('startUrl') != '') {
			
			strUrlforRedirection = apexpages.currentpage().getparameters().get('startUrl');
		}
	}
	
	public String password {get; set {password = value == null ? value : value.trim(); } }
	public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
	
	/* 
		@Name 			: isValidPassword
		@Description	: Check for matching between password and confirmPassword.
		@Type			: private
	*/
	private boolean isValidPassword() {
	    
		return password == confirmPassword;
	}
    
    /* 
		@Name 			: registerUser
		@Description	: Create portal community user.
		@Type			: public
	*/
	public PageReference registerUser() {

		if (!isValidPassword()) {
            
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
			ApexPages.addMessage(msg);
			return null;
		}    
        
		if(objNewProtalUser.Email.contains('@badgermeter.com')) 
		    objNewProtalUser.Username = objNewProtalUser.Email.substringBefore('@badgermeter.com')+'@bmiextranet.com';
		else
			objNewProtalUser.Username = objNewProtalUser.Email;
			
		objNewProtalUser.CommunityNickname = objNewProtalUser.FirstName + objNewProtalUser.LastName + String.valueOf(Math.random()).substring(2, 5);
        
		String userId;
		
		try {
            
            userId = Site.createExternalUser(objNewProtalUser, '', password);
        	
        } catch(Site.ExternalUserCreateException ex) {
           
            List<String> errors = ex.getDisplayMessages();
            
            for (String error : errors)  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
            
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
        }
        
		if (userId != null) { 
            
			if (password != null && password.length() > 1) {
			    
				return Site.login(objNewProtalUser.Username, password, strUrlforRedirection);
			
			} else {
			    
				PageReference page = System.Page.CommunitiesSelfRegConfirm;
				page.setRedirect(true);
				
				return page;
			}
		}
        
		return null;
	}
}