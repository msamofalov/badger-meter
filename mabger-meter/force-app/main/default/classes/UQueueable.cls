public class UQueueable implements Queueable 
{
    private Boolean isMultiObject;
	private UEnum.DML dmlType;
	private List<UUtil.ReturnObj> retObjHolder;
    private UUtil.ReturnObj retObjProcess;

    private Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

    /**
     * UQueueable Class constructor
     * @param  retObjects Array of UUtil.ReturnObj each containing a list of sObjects and DML type
     */
    public UQueueable(List<UUtil.ReturnObj> retObjects)
    {
        this.isMultiObject = retObjects.size() > 1;
        this.retObjHolder = retObjects;
        this.retObjProcess = retObjects.remove(0);
    }
    
	public void execute(QueueableContext context) 
    {
        UUtil.inBatch = true;
        Boolean allOrNothing = (Test.isRunningTest() || isSandbox) ? false : true;

        if (retObjProcess.dmlType == UEnum.DML.INS)
        {   
            handleSaveResult(Database.insert(retObjProcess.objects, allOrNothing));
        }
        else if (retObjProcess.dmlType == UEnum.DML.UPD)
        {   
            handleSaveResult(Database.update(retObjProcess.objects, allOrNothing));
        }
        else if (retObjProcess.dmlType == UEnum.DML.DEL)
        {   
            handleDeleteResult(Database.delete(retObjProcess.objects, allOrNothing));
        }

        if(isMultiObject && !Test.isRunningTest())
        {
            //Send the remaining lists back into the queue
            System.enqueueJob(new UQueueable(retObjHolder));
        }
    }

    private void handleSaveResult(List<Database.SaveResult> saveResult)
    {
        for (Database.SaveResult sr : saveResult)
        {
            if (sr.isSuccess())
            {
                //handle success
            }
            else
            {
                //handle fail
                handleErrors(sr.getErrors());
            }
        }
    }
    
    private void handleDeleteResult(List<Database.DeleteResult> deleteResult)
    {
        for (Database.DeleteResult dr : deleteResult)
        {
            if (dr.isSuccess())
            {
                //handle success
            }
            else
            {
                //handle fail
                handleErrors(dr.getErrors());
            }
        }
    }
    
    private void handleErrors(List<Database.Error> errors)
    {
        for (Database.Error e : errors)
        {                  
        	System.debug('****Error: ' + e.getStatusCode() + ' - ' + e.getMessage());
        	System.debug('****Fields: ' + e.getFields());
        }
    }
}