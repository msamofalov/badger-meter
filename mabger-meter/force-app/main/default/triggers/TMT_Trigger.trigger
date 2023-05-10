trigger TMT_Trigger on TMT__c (before insert,  before update, before delete, after insert,  after update, after delete, after undelete )  {
	
	GearsBase.GearsExecute.executeAllMethods();


 }