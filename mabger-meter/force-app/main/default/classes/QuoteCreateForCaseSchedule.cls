global class QuoteCreateForCaseSchedule implements Schedulable {

    private Id     accountId;
    private String  thisJobName;
    
    
    public QuoteCreateForCaseSchedule (Id accountId, String jobName) {
        this.accountId     = accountId;
        this.thisJobName   = jobName;
    }
    
    public static void scheduleJob (Id accountId, Integer secondsFromNow) {
        
        DateTime now = DateTime.now().addSeconds(secondsFromNow);        
        String hour = String.valueOf(now.hour());
        String min = String.valueOf(now.minute()); 
        String ss = String.valueOf(now.second());

    //parse to cron expression
    String cronString = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        String jobName = 'QuoteCreateForCaseSchedule-'+cronString;
        
        QuoteCreateForCaseSchedule job = new QuoteCreateForCaseSchedule(accountId, jobName);
        
        System.schedule(jobName, cronString, job);
    }
    
    
    global void execute (SchedulableContext sc) {
        Account a = [Select Id, Case_for_Quote__c, CaseNum_to_Quote__c, PONum_to_Quote__c, Case_Contact_Email_to_Quote__c From Account Where Id = :accountId];
        a.Case_for_Quote__c = null;
        a.CaseNum_to_Quote__c = null;
        a.PONum_to_Quote__c   = null;
        a.Case_Contact_Email_to_Quote__c   = null;
        update a;
        
    List <CronTrigger> thisJob = [SELECT Id FROM CronTrigger Where CronJobDetail.Name = :this.thisJobName Limit 1];
      System.debug('ABORT JOB ID: '+ this.thisJobName);
        System.abortJob(thisJob[0].Id);
    }
    
}