global class FCRMetricHelper {

    @AuraEnabled
    public static String calculateFromLightning (String recordId) {
        if (securityCheck()) {
            try {
                FCR_Metric__c fcrm = [Select Id, Case__c From FCR_Metric__c Where Id = :recordId  Limit 1];
                calculate(fcrm.Case__c);
                return 'Successfully calculated metrics. Please wait a few moments to refresh the record.';
            }
            catch (Exception ex) {
                return ex.getMessage();
            }
        }
        else {
            return 'No permission to recalculate metrics';
        }
    }
    webservice static String calculateFromClassic (String caseId) {
        if (securityCheck()) {
            try {
                calculate(caseId);
                return 'Successfully calculated metrics.';
            }
            catch (Exception ex) {
                return ex.getMessage();
            }
        }
        else {
            return 'No permission to recalculate metrics';
        }
    }
    public static void calculate (Id caseId) {
        calculate(new Case(Id=caseId));
    }
    public static void calculate (Case inputCase) {
        calculate(new List <Case> {inputCase});
    }
    public static void calculate (List <EmailMessage> inputEmailMessages) {
        Set <Id> caseIds = new Set <Id> ();
        for (EmailMessage em : inputEmailMessages) if (((String)(em.ParentId)).startsWith('500')) caseIds.add(em.ParentId);
        List <Case> cases = new List <Case> ();
        for (Id caseId : caseIds) cases.add(new Case(Id=caseId));
        calculate(cases);
    }
    public static void calculate (List <Task> inputTasks) {
        Set <Id> caseIds = new Set <Id> ();
        for (Task t : inputTasks) if (((String)(t.WhatId)).startsWith('500')) caseIds.add(t.WhatId);
        List <Case> cases = new List <Case> ();
        for (Id caseId : caseIds) cases.add(new Case(Id=caseId));
        calculate(cases);
    }
    public static void calculate (List <CaseComment> inputCaseComments) {
        Set <Id> caseIds = new Set <Id> ();
        for (CaseComment cc : inputCaseComments) caseIds.add(cc.ParentId);
        List <Case> cases = new List <Case> ();
        for (Id caseId : caseIds) cases.add(new Case(Id=caseId));
        calculate(cases);
    }
    public static void calculate (List <Case> inputCases) {
        if (inputCases != null && inputCases.size() > 0) {
            // Get the necessary information from the input cases.
            List <CaseWrapper> caseWrappers = createCaseWrappers(inputCases);
            List <FCR_Metric__c> fcrMetrics = new List <FCR_Metric__c> ();
            for (CaseWrapper cw : caseWrappers) fcrMetrics.add(cw.createFCRMetrics());
            upsert fcrMetrics Unique_ID__c;    
        }
    }
    
    
    // Checks to see if the current user has the appropriate permission set to use the button or is a system administrator.
    @TestVisible
    private static Boolean securityCheck () {
        try {
            // First check the user's profile.
            String profileName = [Select Name From Profile Where Id = :UserInfo.getProfileId() Limit 1][0].Name;
            if (profileName == 'System Administrator') 	return true;
            
            // Then check to see if the user has the "Can Recalculate FCR Metric" permission set.
        	PermissionSetAssignment psa = [Select Id From PermissionSetAssignment Where AssigneeId = :UserInfo.getUserId() And PermissionSet.Name = 'Can_Recalculate_FCR_Metric' Limit 1];
      		if (psa != null) 	return true;
            else 				return false;
        }
        catch (Exception ex) {
            return false;
        }
    }
    
    
    
    private static List <CaseWrapper> createCaseWrappers (List <Case> inputCases) {
        Map <Id, Case> 							cases 			= getCases(inputCases);
        Map <Id, List <EmailMessage>> 			emailMessages 	= getEmailMessages(inputCases);
        Map <Id, List <Task>> 					callLogs 		= getCallLogs(inputCases);
        Map <Id, List <CaseCommentWrapper>> 	caseComments 	= getCaseComments(inputCases);
        
        List <CaseWrapper> caseWrappers = new List <CaseWrapper> ();
        for (Case c : cases.values()) caseWrappers.add(new CaseWrapper(cases.get(c.Id), emailMessages.get(c.Id), callLogs.get(c.Id), caseComments.get(c.Id)));
        return caseWrappers;
    }
    
    
    private static Map <Id, Case> getCases (List <Case> inputCases) {
        return new Map <Id, Case> ([Select Id, Subject, ContactId, Origin, OwnerId From Case Where Id in :inputCases And RecordType.Name = 'Inquiry' And Status = 'Closed']);
    }
    
    
    private static Map <Id, List <EmailMessage>> getEmailMessages (List <Case> inputCases) {
    	Map <Id, List <EmailMessage>> emailMessagesMap = new Map <Id, List <EmailMessage>> ();
        for (EmailMessage em : [Select Id, ParentId, Incoming From EmailMessage Where ParentId in :inputCases And Exclude_from_FCR__c = false]) {
            if (!emailMessagesMap.containsKey(em.ParentId)) emailMessagesMap.put(em.ParentId, new List <EmailMessage> ());
            emailMessagesMap.get(em.ParentId).add(em);
        }
        return emailMessagesMap;
    }
    
    
    private static Map <Id, List <Task>> getCallLogs (List <Case> inputCases) {
    	Map <Id, List <Task>> tasksMap = new Map <Id, List <Task>> ();
        for (Task t : [Select Id, WhatId, Direction__c From Task Where WhatId in :inputCases And Type = 'Call' And Exclude_from_FCR__c = false]) {
            if (!tasksMap.containsKey(t.WhatId)) tasksMap.put(t.WhatId, new List <Task> ());
            tasksMap.get(t.WhatId).add(t);
        }
        return tasksMap;
    }
    
    
    private static Map <Id, List <CaseCommentWrapper>> getCaseComments (List <Case> inputCases) {
    	Map <Id, List <CaseCommentWrapper>> caseCommentsMap = new Map <Id, List <CaseCommentWrapper>> ();
        
        List <CaseComment> caseComments = new List <CaseComment> ([Select Id, ParentId, CreatedById, IsPublished From CaseComment Where ParentId in :inputCases]);
        
        Set <Id> userIds = new Set <Id> ();
        for (CaseComment c : caseComments) userIds.add(c.CreatedById);
        Map <Id, User> userMap = new Map <Id, User> ([Select Id, UserType, Profile.UserLicense.Name From User Where Id in :userIds]); 
            
        for (CaseComment c : caseComments) {
            if (!caseCommentsMap.containsKey(c.ParentId)) caseCommentsMap.put(c.ParentId, new List <CaseCommentWrapper> ());
            caseCommentsMap.get(c.ParentId).add(new CaseCommentWrapper(c, userMap.get(c.CreatedById)));
        }
        return caseCommentsMap;
    }
    
    
    
    
    
    
    
    private class CaseWrapper {
        public Case 						theCase;
        public List <EmailMessage> 			emailMessages;
        public List <Task>					callLogs;
        public List <CaseCommentWrapper>	caseComments;
        
        public Integer 	incomingEmails;
        public Integer 	outgoingEmails;
        public Integer 	totalEmails;
        
        public Integer 	incomingCallLogs;
        public Integer 	outgoingCallLogs;
        public Integer 	totalCallLogs;
        
        public Integer 	incomingCaseComments;
        public Integer 	outgoingCaseComments;
        public Integer 	totalCaseComments;
        
        public Integer 	totalIncomingCommunications;
        public Integer 	totalOutgoingCommunications;
        
        public Boolean 	achievesFCR;
        public String	failureReason;
        public String	debugString;
        
        
        public CaseWrapper (Case theCase, List <EmailMessage> emailMessages, List <Task> callLogs, List <CaseCommentWrapper> caseComments) {
            this.theCase 		= theCase;
            this.emailMessages 	= emailMessages != null ? emailMessages : new List <EmailMessage> ();
            this.callLogs 		= callLogs != null ? callLogs : new List <Task> ();
            this.caseComments 	= caseComments != null ? caseComments : new List <CaseCommentWrapper> ();
            
            this.incomingEmails = 0;
            this.outgoingEmails = 0;
            this.totalEmails 	= 0;
            
            this.incomingCallLogs 	= 0;
            this.outgoingCallLogs 	= 0;
            this.totalCallLogs 		= 0;
            
            this.incomingCaseComments 	= 0;
            this.outgoingCaseComments 	= 0;
            this.totalCaseComments 		= 0;
            
            this.totalIncomingCommunications = 0;
            this.totalOutgoingCommunications = 0;
            
            calculate();
            achievesFCR();
        }
        
        
        private void calculate () {
            for (EmailMessage em : emailMessages) if (em.Incoming) incomingEmails++;
            for (EmailMessage em : emailMessages) if (!em.Incoming) outgoingEmails++;
            totalEmails = incomingEmails+outgoingEmails;
            
            for (Task t : callLogs) if (t.Direction__c == 'Incoming') incomingCallLogs++;
            for (Task t : callLogs) if (t.Direction__c == 'Outgoing') outgoingCallLogs++;
            totalCallLogs = incomingCallLogs+outgoingCallLogs;
            
            for (CaseCommentWrapper cc : caseComments) if (cc.isExternalUser()) incomingCaseComments++;
            for (CaseCommentWrapper cc : caseComments) if (cc.isInternalUser() && cc.caseComment.IsPublished) outgoingCaseComments++;
            totalCaseComments = incomingCaseComments+outgoingCaseComments;
            
            totalIncomingCommunications = incomingEmails+incomingCallLogs+incomingCaseComments;
            totalOutgoingCommunications = outgoingEmails+outgoingCallLogs+outgoingCaseComments;
        }
        
        
        private void achievesFCR () {
            debugString = '';
            
            // 1. Strict incoming limits. If there is more than 1 incoming communication, there are too many incoming communications.
            if (totalIncomingCommunications > 1) {
                achievesFCR 	= false;
                failureReason 	= 'Too Many Incoming';
                debugString 	= 'Failed condition 1 - Strict Incoming Limits';
                return;
            }
            
            // 2. If we've reached this point, we've established that there is only 1 incoming communication but we haven't been able to establish
            // that the outgoing communications are within the limit for specific scenarios. If there is more than 1 outgoing communication FCR has failed.
            if (totalOutgoingCommunications > 1 && (outgoingEmails != 1 || outgoingCallLogs != 1)) {
                achievesFCR 	= false;
                failureReason 	= 'Too Many Outgoing';
                debugString 	= 'Failed condition 2 - Strict Outgoing Limits';
                return;
            }
            
            
            // 3. If the case is created from an email or a phone call and there is no followup, it counts as FCR.
            if ((theCase.Origin == 'Email' || theCase.Origin == 'Phone') && totalOutgoingCommunications == 0) {
                achievesFCR = true;
                failureReason = null;
                debugString = 'Passed Condition 3 - Case Origin Email or Phone';
                return;
            }
            
            
            // 4. If there is an incoming email, then the proper response is either 1 outgoing email or 1 outgoing call.
            if (	incomingEmails <= 1 
                && (
                    	(outgoingEmails == 1 && outgoingCallLogs == 1 && outgoingCaseComments == 0) 
                    || 	(outgoingEmails == 1 && outgoingCallLogs == 0 && outgoingCaseComments == 0)
            	)
            ) {
            	achievesFCR 	= true;
                failureReason 	= null;
                debugString 	= 'Passed condition 4 - Incoming Email Response';
                return;
            }
            
            
            // 5. If there is an incoming phone call, then the proper response is 1 outgoing call. One outgoing email is permissible.
            if (	incomingCallLogs == 1 
                && (outgoingEmails <= 1 && outgoingCallLogs == 0 && outgoingCaseComments == 0)
            ) {
            	achievesFCR 	= true;
                failureReason 	= null;
                debugString 	= 'Passed condition 5 - Incoming Phone Call Response';
                return;
            }
            
            // 6. If there is an incoming phone call, then the proper response is 1 outgoing call. One outgoing email is permissible.
            if (incomingCallLogs > 0 && outgoingCallLogs > 0) {
                achievesFCR 	= false;
                failureReason 	= 'Too Many Outgoing';
                debugString 	= 'Failed condition 6 - Incoming Phone Call Response';
                return;
            }
            
            // 7. If there is an incoming phone call, then the proper response is 1 outgoing call. One outgoing email is permissible.
            if (incomingCallLogs == 0 && outgoingCallLogs == 1) {
                achievesFCR 	= true;
                failureReason 	= null;
                debugString 	= 'Passed condition 7 - Incoming Phone Call Response';
                return;
            }
           
            
            // 8. If there is an incoming case comment, then we do not achieve FCR.
            if (incomingCaseComments > 0) {
            	achievesFCR 	= false;
                failureReason 	= 'Too Many Incoming';
                debugString 	= 'Failed condition 8 - Incoming Comment Response';
                return;
            }
            
            
            
            // 9. If there is a single outgoing case comment, then we do not achieve FCR.
            if (incomingCaseComments == 0 && outgoingCaseComments <= 1) {
            	achievesFCR 	= true;
                failureReason 	= null;
                debugString 	= 'Passed condition 9 - Outgoing Comment Response';
                return;
            }
            
            
            // 10. This is a condition that should only ever be reached if there is one incoming communication but no outgoing communications,
            // indicating that the case is in progress and FCR can't reasonably be considered. We'll mark it as not successful but having no failure reason.
            achievesFCR 	= false;
            failureReason 	= null;
            debugString 	= 'Encountered condition 10 - Not Enough Information';
            return;
        }
        
        
        
        public FCR_Metric__c createFCRMetrics () {
        
            // Create a metric and populate the initial required information.
            FCR_Metric__c fcrm = new FCR_Metric__c();
            fcrm.Case__c 					= theCase.Id;
            fcrm.Unique_ID__c 				= 'FCRM-'+theCase.Id;
            fcrm.Contact__c 				= theCase.ContactId;
            fcrm.Case_Owner__c 				= theCase.OwnerId;
            fcrm.Calculation_Date_Time__c	= DateTime.now();
            
            fcrm.Incoming_Emails__c 	= incomingEmails;
            fcrm.Outgoing_Emails__c 	= outgoingEmails;
            fcrm.Total_Emails__c 		= totalEmails;
            
            fcrm.Incoming_Call_Logs__c 	= incomingCallLogs;
            fcrm.Outgoing_Call_Logs__c 	= outgoingCallLogs;
            fcrm.Total_Call_Logs__c 	= totalCallLogs;
            
            fcrm.Incoming_Case_Comments__c 	= incomingCaseComments;
            fcrm.Outgoing_Case_Comments__c 	= outgoingCaseComments;
            fcrm.Total_Case_Comments__c 	= totalCaseComments;
            
            fcrm.Total_Incoming_Communication__c 	= totalIncomingCommunications;
            fcrm.Total_Outgoing_Communication__c 	= totalOutgoingCommunications;
            
            fcrm.Cases_Created_During_Monitoring_Period__c 	= 0; // Todo
            
            fcrm.FCR_Achieved__c 	= achievesFCR;
            fcrm.Failure_Reason__c 	= failureReason;
            fcrm.Debug__c			= debugString;
            
            return fcrm;
        }
    }
    
    
    
    private class CaseCommentWrapper {
        public CaseComment caseComment;
        public User commentUser;
        
        public CaseCommentWrapper (CaseComment caseComment, User commentUser) {
            this.caseComment = caseComment;
            this.commentUser = commentUser != null ? commentUser : new User();
        }
        
        public Boolean isExternalUser () {
            if (commentUser.Profile.UserLicense.Name == 'Partner Community' || commentUser.Profile.UserLicense.Name == 'Customer Community Plus Login') return true;
            else return false;
        }
        
        public Boolean isInternalUser () {
            if (commentUser.UserType == 'Standard') return true;
            else return false;
        }
    }
    
}