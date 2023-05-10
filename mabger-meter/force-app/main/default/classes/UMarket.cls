global class UMarket 
{

	global class UpdateTMT implements gearsBase.gearsExecute.executeMethod
	{
		public void execute(List<SObject> records, Map<Id, sObject> oldMap, gearsBase.gearsExecute.triggerParameters tp)
		{
			update_TMTProduct(records, (Map<Id, Market__c>) oldMap, tp);
		}
	}

	/**
	 * update_TMTProduct Sets Market__c.Product_List__c
	 * @param  records List of Market__c records
	 * @param  oldMap  Trigger.oldMap
	 * @param  tp      GearsBase.gearsExecute.triggerParameters
	 */
	public static void  update_TMTProduct(List<Market__c> records, Map<Id, Market__c> oldMap, gearsBase.gearsExecute.triggerParameters tp)
	{
		final String METHOD_TAG = UMarket.class.toString() + '.update_TMTProduct';
		System.debug('Start ' + METHOD_TAG);

		if(tp.isInsert == true)
		{
			for(Market__c m : records)
			{
				m.Product_List__c = m.Product__c;
			}
		}

		if(tp.isUpdate == true)
		{
			for(Market__c m : records)
			{
				if(m.Product__c == null )
				{
					m.Product_List__c = '';
				}
				else if(m.Product__c != oldMap.get(m.Id).Product__c)
				{
					m.Product_List__c = m.Product__c.left(255);
				}
			}
		}

		System.debug('End ' + METHOD_TAG);
	}

}