/**
    @Name               :	BatchDisableCommunityUser
    @Date               :   14 Oct, 2015
    @Description        :   Make IsPortalEnabled to false On Users with Deactivate_User__c = true.
    @TestClass			:	test_UContact
*/
public with sharing class BatchDisableCommunityUser implements Database.Batchable<sObject> {
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		
		String strQuery = ' SELECT Deactivate_User__c, IsPortalEnabled FROM User WHERE Deactivate_User__c = true';
		
		return Database.getQueryLocator(strQuery);
	}
	
	public void execute(Database.BatchableContext BC, List<User> lstUsers) {
		
		List<User> lstUsersToUpdate = new List<User>();
		
		system.debug('---lstUsers-----'+lstUsers);
		
		for(User objUser : lstUsers) {
			
			objUser.IsPortalEnabled = false;
			objUser.Deactivate_User__c = false;
			lstUsersToUpdate.add(objUser);
		}
		
		system.debug('---lstUsersToUpdate-----'+lstUsersToUpdate);
		
		if(!lstUsersToUpdate.isEmpty())
			update lstUsersToUpdate;
	}
	
	public void finish(Database.BatchableContext BC){
	     // Do nothing
	}
}