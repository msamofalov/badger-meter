/* Description: This class is the controller for Loaner Program Home Page */
public with sharing class LoanerAssignmentsController {

    //Label for the object being managed.
    //This variable will be used for all labels and texts
    public String assetlabel {get; private set;}

    //Variable for Total Asset Count
    public Double totalCount {get; private set;}
        
    //Variable for Available Assets Count
    public Integer availableCount {get; private set;}

    //Variable for Available Assets Count, representing % as Integer
    public Double availablePercentage {get; private set;}
    
    //Variable for Assigned Assets Count
    public Integer assignedCount {get; private set;}

    //Variable for Assigned Assets Count, representing % as Integer
    public Double assignedPercentage {get; private set;}   

    //List of available asset record types
    private List<RecordType> rtList= [select Id, 
                                             DeveloperName,
                                             Name 
                                      from RecordType
                                      where sObjectType =: AM_Constants.AM_ASSET_API_NAME];  
    //Record type selection on the home page
    public Id selectedRecordTypeId {get; set;}
    public string recordTypeName = 'Hardware_Assessories_Loaner';
    /*---- Constructors ----*/

    public LoanerAssignmentsController() 
    {   
        //Initiate the home page
        this.init();
    }  

    /*---- Methods ----*/

    /*
    * Description: Method to initiate the homepage content
    */    
    public void init()
    {
        selectedRecordTypeId = [select Id
                                      from RecordType
                                      where DeveloperName =: recordTypeName limit 1][0].Id;
        //Check if there are any Record Types created.
        if(selectedRecordTypeId ==null )
        {
            //If no record types are not created throw an error
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'E2: Did not find asset record types. Please contact administrator.'));                                                                                    
        }
        //Continue with the logic
        else
        {
            //Initialize counts
            this.availableCount = 0;
            this.assignedCount = 0;
            //this.outOfServiceCount = 0;
            this.totalCount = 0;

            //Set the Asset Label - Call the static method to set the asset label
            this.assetLabel = AM_SettingsUtil.setassetLabel(this.selectedRecordTypeId);

            //Get Counts
            this.getCounts();

            //Get Alerts list
            //this.getCaseList();            
        }
    } 
    /*
    * Method to get asset counts
    */
    public void getCounts()
    {
        //Reset all count to 0 before calculating counts
        this.availableCount = 0;
        this.assignedCount = 0;
        //this.outOfServiceCount = 0;
        this.totalCount = 0;

        //Create a list for asset counts
        List<AggregateResult> assetCounts = new List<AggregateResult>();

        try
        {
            //Get the count of avilable and allocated  the based on the record type selected
            assetCounts = [SELECT AM_Available_for_allocation__c, 
                                  COUNT(Id) c
                           FROM Asset 
                           WHERE RecordTypeId =: this.selectedRecordTypeId
                           GROUP BY AM_Available_for_allocation__c];            
        }
        catch (Exception e)
        {
            //Add a message that there was an error fetching records
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'E3: Error fetching Asset records. ( ' + e.getMessage() + ' )'));                                                                        
        } 

        //Loop through the list and assign Available and Assigned counts
        for(AggregateResult assetCount: assetCounts)
        {
            //Check if assetCount is null
            if( assetCount!=null )
            {

                //Variable for Count of asset status
                Integer statusCount = Integer.valueOf(assetCount.get('c'));

                //Count for Available assets
                if(assetCount.get('AM_Available_for_allocation__c')==true)
                {
                    this.availableCount = statusCount;
                }
                //Count for Assigned assets
                else if (assetCount.get('AM_Available_for_allocation__c')==false)
                {
                    this.assignedCount = statusCount;
                }
            }
            else
            {
                    //Add a message that assetcount is null
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                               'E6: Asset count is 0.'));                                                            
            }
        }

        //Get the Out of Service counts
        //this.outOfServiceCount = [select COUNT() from Asset 
        //                          where RecordTypeId =: this.selectedRecordTypeId 
        //                          AND AM_Out_of_Service__c = :true];

        //Calculate the total count
        this.totalCount = this.availableCount + this.assignedCount;

        //Calculate the percentages for each variable if total is not 0 . 
        //Need to use Double versions of the int values for correct totals.
        if(totalCount>0)
        {
            //Available
            this.availablePercentage = (this.availableCount / this.totalCount) * 100;

            //Assigned
            this.assignedPercentage = (this.assignedCount / this.totalCount) * 100;

            //Out of Service
            //this.outOfServicePercentage = (this.outOfServiceCount / this.totalCount) * 100;
        }
        //TotalCount = 0
        else
        {
            this.availablePercentage = 0.0;
            this.assignedPercentage = 0.0;
            //this.outOfServicePercentage = 0.0;
        }           
    }          
}