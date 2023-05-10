trigger SalesCreditID_Trigger on Sales_Credit_ID__c (before insert,  before update, before delete, after insert,  after update, after delete, after undelete )  {
	
	GearsBase.GearsExecute.executeAllMethods();


 }