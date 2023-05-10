public class TrainingActivityRelatedListController {

    private List<Training_Activity__c> PTs;
    private Training_Request__c cas;
    public boolean taskrender {get; set;} 
        
    public TrainingActivityRelatedListController(ApexPages.standardController controller) {
        this.cas= (Training_Request__c)controller.getRecord();
        this.cas=[select id, name, Training_Request_Number__c, status__c, OwnerId from Training_Request__c where id=:this.cas.id];
    }
    public string getCaseStatus(){
        return this.cas.status__c;
    }
    String[] nonIFActivityStatus = new String[]{};
    String[] IFActivityStatus = new String[]{};
    //Our collection of the class/wrapper objects cContact 
    public List<cActivity> activityList {get; set;}

    //This method uses a simple SOQL query to return a List of Contacts
    public List<cActivity> getActivities() {
        if(activityList == null) {
            activityList = new List<cActivity>(); //where WhatId = :cas.Id
            for(Training_Activity__c c: [select Id, Owner_2__c, Training_Request__r.id, Status__c, Subject__c, Activity_Date__c, Training_Time__c, Interface_Analysis__c,Dependencies__c, Comments__c from Training_Activity__c where Training_Request__c = :cas.Id ORDER BY Id ASC LIMIT 100]) {
                // As each contact is processed we create a new cContact object and add it to the contactList
                activityList.add(new cActivity(c));
            }
        }
        return activityList;
    }

    public List<SelectOption> getIFItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Pending','Pending'));
        options.add(new SelectOption('Initiated','Initiated'));
        options.add(new SelectOption('Awaiting File','Awaiting File'));
        options.add(new SelectOption('Received/Reviewing File','Received/Reviewing File'));
        options.add(new SelectOption('Export Sent','Export Sent'));         
        options.add(new SelectOption('Waiting for Billing Vendor','Waiting for Billing Vendor'));
        options.add(new SelectOption('Waiting for Customer','Waiting for Customer'));
        options.add(new SelectOption('Waiting on Badger Meter','Waiting on Badger Meter')); 
        options.add(new SelectOption('Reviewing File','Reviewing File'));
        options.add(new SelectOption('Complete - RFA','Complete - RFA')); 
        options.add(new SelectOption('On Hold','On Hold'));
        options.add(new SelectOption('Deferred','Deferred'));
        options.add(new SelectOption('Canceled','Canceled'));      
        options.add(new SelectOption('Completed','Completed'));
        options.add(new SelectOption('Outsource','Outsource'));
        options.add(new SelectOption('Outsource - SL','Outsource - SL'));
        return options;
    }
    public List<SelectOption> getNonIFItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Pending','Pending'));
        options.add(new SelectOption('Initiated','Initiated'));
        options.add(new SelectOption('Scheduled','Scheduled'));
        options.add(new SelectOption('Canceled','Canceled'));
        options.add(new SelectOption('Completed','Completed'));
        return options;
    }        
    public PageReference processSelected() {
        try {
            //We create a new list of Contacts that we be populated only with Contacts if they are selected
            List<Training_Activity__c> selectedTasks = new List<Training_Activity__c>();
    
            //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
            for(cActivity cCon: getActivities()) {
                if(cCon.selected == true) {
                    selectedTasks.add(cCon.con);
                }
            }
    
            // Now we have our list of selected contacts and can perform any type of logic we want, sending emails, updating a field on the Contact, etc
            System.debug('These are the selected Contacts...');
            for(Training_Activity__c con: selectedTasks) {
                system.debug(con);
            }
            if (selectedTasks.size() >0) {
                upsert selectedTasks;
            }
            activityList=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now
        } catch(Exception e) {
            ApexPages.addMessages(e) ; 
        } 
        return null;
    }

    public PageReference createNew() {
        //get Training Request Object Prefix
        Schema.DescribeSObjectResult r = Training_Activity__c.sObjectType.getDescribe();
        string trainingActivitykeyPrefix = r.getKeyPrefix();
		
        PageReference parentPage = new PageReference('/' + trainingActivitykeyPrefix + '/e?CF00N38000003qkd6=' + this.cas.Name);

        parentPage.setRedirect(true);
        return parentPage;
    }   

    // This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper class contains both the standard salesforce object Contact and a Boolean value
    public class cActivity {
        public Training_Activity__c con {get; set;}
        public Boolean selected {get; set;}

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public cActivity(Training_Activity__c c) {
            con = c;
            selected = false;
        }
    }
    /*
    public void showPopup() {   
        id rowNumber = ApexPages.currentPage().getParameters().get('rowId');
        id recNumber = ApexPages.currentPage().getParameters().get('rowId');  
        id cPage = Apexpages.currentPage().getParameters().get('rPgName');      
        System.debug(' SHOW Page '+cPage);
        boolean displayPopup = true;  
        taskrender = true;    
    }    
    public PageReference closePopup() {
        id cPage = Apexpages.currentPage().getParameters().get('rPgName');
        boolean displayPopup = false;
        taskrender = false;
       
        PageReference pr = new PageReference (cPage);
        pr.setRedirect(true);
        return pr;
    }
    */
}