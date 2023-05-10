public class LM_LeadMaintenance {

    /*	LM - Lead Maintenance
     * 	
     * 	Module:	Lead Maintenance
     * 
     * 	Author:	Joseph Bunda, Allium - 2020-03-01
     * 
     * 	Responsible for the core functionality of maintaining leads.	
     * 
     */ 
    
    
    
    public static void nurtureOldLeads () {
        /*	Gathers leads that are older than X days of specific record types and marks them as needing more nuturing.
         */ 
        
        // Which status to capture.
        String status = 'New';
        
        // The list of record type names to capture.
        Set <String> recordTypeNames = new Set <String> {
        	'Flow Instrumentation',
            'Utility',
           	'International Lead'
        };
        
        // How far back in days from today that leads should be captured.
        Integer daysOld = 30;
        
        // The date, X days ago.
        Date xDaysOld = Date.today().addDays(-daysOld);
        
        // Gather leads that meet the above criteria. In addition, the leads cannot be converted and the Pardot Consent Last Updated field cannot be empty.
        List <Lead> oldLeads = new List <Lead> ([Select Id, Status, Lifecycle_Status__c From Lead Where Status = :status And RecordType.Name in :recordTypeNames And IsConverted = false And (Pardot_Consent_Last_Updated__c != null And Pardot_Consent_Last_Updated__c < :xDaysOld)]);
        
        // The statuses to update each lead to.
        String newStatus 			= 'Needs More Nurturing';
        String newLifecycleStatus 	= '10 - Expired';
        
        // Update each lead with the new statuses.
        for (Lead l : oldLeads) {
            l.Status 				= newStatus;
        	l.Lifecycle_Status__c 	= newLifecycleStatus;
        }
        
        // Commit the changes and capture the results to be reported on.
        List <Database.SaveResult> updateResults = Database.update(oldLeads, false);
        
        // Get the results in CSV format.
        String csv = compileDatabaseResultsToCSV(updateResults);
        
        // Send an email to the administrator with the results of this operation.
        emailResultsToAdministrators('Nuture Old Leads', csv);
    }
    
    
    
    @TestVisible
    private static String compileDatabaseResultsToCSV (List <Database.SaveResult> results) {
        /*	Compiles the results of a database update into a CSV string.
         */ 
        
        // Establish the CSV headers.
        String csvHeaders = 'Id,Result';
        
        // The CSV body.
        String csv = csvHeaders +'\n';
        
        // Compile the results.
        for (Database.SaveResult result : results) {
            csv += result.getId() +',';
            
            if (result.isSuccess()) {
                csv += 'Success';
            }
            else {
                csv += 'Error: ';
                for (Database.Error error : result.getErrors()) csv += error.getMessage() +'|';
            }
            
            csv += '\n';
        }
        
        return csv;
    }
    
    
    
    @TestVisible
    private static void emailResultsToAdministrators (String operationName, String csvBody) {
        /*	Emails the list of apex job administrators.
         */
        
        // Get the organization info.
        Organization org = [Select InstanceName, IsSandbox From Organization Limit 1];
        
        // Get the list of administrators, a custom setting.
        List <Apex_Job_Administrator__c> admins = new List <Apex_Job_Administrator__c> ([Select Name__c, Email__c From Apex_Job_Administrator__c]);
        
        // Gather the email addresses into one string.
        List <String> emailAddresses = new List <String> ();
        for (Apex_Job_Administrator__c admin : admins) emailAddresses.add(admin.Email__c);
        
        // Get the date for the subject line.
        Date todaysDate = Date.today();
        String todaysDateString = DateTime.newInstance(todaysDate.year(), todaysDate.month(), todaysDate.day()).format('yyyy-MM-dd');
        
        // Craft the subject.
        String subject = 'Apex Job Results - '+ todaysDateString +' - '+ operationName;
        
        // Indicate the sender.
        String sender = (org.InstanceName +' ') + (org.IsSandbox ? '(Sandbox) ' : '') + 'Salesforce Apex Jobs';
        
        // Create the CSV attachment.
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.filename = subject+'.csv';
        efa.setBody(Blob.valueOf(csvBody));
        efa.setContentType('text/csv');
        
        // Craft the email message.
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setSenderDisplayName(sender);
        email.setToAddresses(emailAddresses);
        email.setPlainTextBody('Please see attachment.');
        email.setFileAttachments(new List <Messaging.EmailFileAttachment> {efa});
        
        // Send the email.
        Messaging.sendEmail(new List <Messaging.SingleEmailMessage> {email});
    }
    
}