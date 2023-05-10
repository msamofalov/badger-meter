global class LM_LeadMaintenanceSchedulable implements Schedulable {
	/*	LM - Lead Maintenance
     * 	
     * 	Module:	Lead Maintenance Schedulable
     * 
     * 	Author:	Joseph Bunda, Allium - 2020-03-01
     * 
     * 	Responsible for scheduling jobs.	
     * 
     */
    
    
    
    global void execute (SchedulableContext SC) {
        /*	The work loop. Additional lead maintenance tasks should be added here.
         */
        
        LM_LeadMaintenance.nurtureOldLeads();
    }
}