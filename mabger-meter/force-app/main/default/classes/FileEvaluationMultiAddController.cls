public with sharing class FileEvaluationMultiAddController {
    public Training_Activity__c ta; 
    //will hold the account records to be saved
    public List<File_Evaluation__c>lstFe  = new List<File_Evaluation__c>();
    
    //list of the inner class
    public List<innerClass> lstInner 
    {   get;set;    }
    
    //will indicate the row to be deleted
    public String selectedRowIndex
    {get;set;}  
    
    //no. of rows added/records in the inner class list
    public Integer count = 1;
    //{get;set;}
    
    
    ////save the records by adding the elements in the inner class list to lstFe,return to the same page
    public PageReference Save()
    {
        PageReference pr = new PageReference('/'+ta.Id);
        
        for(Integer j = 0;j<lstInner.size();j++)
        {
            lstFe.add(lstInner[j].fileev);
        } 
        insert lstFe;
        pr.setRedirect(True);
        return pr;
    }
        
    //add one more row
    public void Add()
    {   
        count = count+1;
        addMore();      
    }
    
    /*Begin addMore*/
    public void addMore()
    {
        //call to the iner class constructor
        innerClass objInnerClass = new innerClass(count, ta.id);
        
        //add the record to the inner class list
        lstInner.add(objInnerClass);    
        system.debug('lstInner---->'+lstInner);            
    }/* end addMore*/
    
    /* begin delete */
    public void Del()
    {
        system.debug('selected row index---->'+selectedRowIndex);
       // if(lstInner.size() >= 1) {
            lstInner.remove(Integer.valueOf(selectedRowIndex)-1);
            count = count - 1;
       // }
        
    }/*End del*/
    
    public PageReference back() {
        return new PageReference('/'+ta.Id);
    }         
    
    /*Constructor*/
    public FileEvaluationMultiAddController(ApexPages.StandardController ctlr)
    {
        this.ta = (Training_Activity__c)ctlr.getRecord();
        lstInner = new List<innerClass>();
        addMore();
        selectedRowIndex = '0';
        
    }/*End Constructor*/
        


    /*Inner Class*/
    public class innerClass
    {       
        /*recCount acts as a index for a row. This will be helpful to identify the row to be deleted */
        public String recCount
        {get;set;}
        
        
        public File_Evaluation__c fileev 
        {get;set;}
        
        /*Inner Class Constructor*/
        public innerClass(Integer intCount, Id id)
        {
            recCount = String.valueOf(intCount);        
            
            /*create a new account*/
            fileev = new File_Evaluation__c();
            fileev.Training_Activity__c=id;
            
        }/*End Inner class Constructor*/    
    }/*End inner Class*/
}/*End Class*/