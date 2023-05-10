/**
    @Name               :	ScheduleBatchDisableCommunityUser
    @Date               :   14 Oct, 2015
    @Description        :   Scheduler class for BatchDisableCommunityUser.
    @TestClass			:	test_UContact
*/
public with sharing class ScheduleBatchDisableCommunityUser implements Schedulable {
	
	public static String scheduledTime = '0 00 22 * * ?'; 
	
	public static String scheduleBatch() {
        
        ScheduleBatchDisableCommunityUser objSchedule = new ScheduleBatchDisableCommunityUser();
        return System.schedule('Batch Disable Community User', scheduledTime, objSchedule);
    }
    
    public void execute(SchedulableContext sc) {

        BatchDisableCommunityUser objScheduleBatch = new BatchDisableCommunityUser();
        ID batchprocessid = Database.executeBatch(objScheduleBatch, 200);           
    }
}