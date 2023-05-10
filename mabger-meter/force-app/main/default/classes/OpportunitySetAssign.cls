public class OpportunitySetAssign
{
    public list <Opportunity> Opps;
    
    public OpportunitySetAssign (apexpages.StandardSetController SetController) 
    {
		Opps = SetController.getSelected();
    }
    public void UpdateOwnership() 
    {
        id userId = userInfo.getUserId();
        
        for (Opportunity o:Opps) o.OwnerId = userId;

        update Opps;
    }
}