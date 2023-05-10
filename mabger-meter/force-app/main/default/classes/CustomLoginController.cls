/**
    @Name               :           CustomLoginController
    @Date               :           25 Sep, 2015
    @Description        :           An apex page controller for CustomLogin page that exposes the site login functionality
    @TestClass          :      		CustomLoginControllerTest
*/
global with sharing class CustomLoginController {
    
	global String username {get;set;}
	global String password {get;set;}
	global Boolean isRememberUsername {get;set;}
	global String urlId {get;set;}
	
	global String  startUrl { get; set; }
	
	/* 
		@Name 			: CustomLoginController
		@Description	: Constructor
		@Type			: global
	*/
	global CustomLoginController() {
		 
		urlId = System.currentPageReference().getParameters().get('inresponseto');
		
		startUrl = System.currentPageReference().getParameters().get('startURL');
		system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!! startUrl : ' + startUrl);
		isRememberUsername = false;
		Cookie counter = ApexPages.currentPage().getCookies().get('counter');
		
		if (counter == null) {
		
		}  else {
			
			counter = null;
			ApexPages.currentPage().setCookies(new Cookie[]{counter});
		}
	}
	
	/* 
		@Name 			: login
		@Description	: method is called on click of SignIn button.
		@Type			: global
		@Parameters		: 1- map of new created lead records
						
	*/
	global PageReference login() {
		
		String startUrl = System.currentPageReference().getParameters().get('startURL');
		return Site.login(username, password, startUrl);
	}
}