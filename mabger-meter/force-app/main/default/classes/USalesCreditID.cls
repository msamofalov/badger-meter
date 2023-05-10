global class USalesCreditID 
{

	global class UpdateTMT implements gearsBase.gearsExecute.executeMethod
	{
		public void execute(List<SObject> records, Map<Id,sObject> oldMap, gearsBase.gearsExecute.triggerParameters tp)
		{
			update_TMT(records, (Map<Id,Sales_Credit_ID__c>)oldMap,  tp);
		}
	}
		
	/**
	 * update_TMT Sets TMT__c fields User__c and Channel_Partner__c when Sales_Credit_ID__c record is inserted or updated
	 * @param  records List of Sales_Credit_ID__c records
	 * @param  oldMap  Trigger.oldMap
	 * @param  tp      GearsBase.gearsExecute.triggerParameters
	 */
	public static void update_TMT(List<Sales_Credit_ID__c> records, Map<Id, Sales_Credit_ID__c> oldMap, gearsBase.gearsExecute.triggerParameters tp)
	{
		final String TAG_NAME = USalesCreditID.class.toString() + '.update_TMT';
		System.debug('Start ' + TAG_NAME);

		Map<String, Sales_Credit_ID__c> scidMap = new Map<String, Sales_Credit_ID__c>();

		for(Sales_Credit_ID__c rec : records)
		{
			if(tp.isInsert
				|| (rec.User__c != oldMap.get(rec.Id).User__c 
					|| rec.Channel_Partner__c != oldMap.get(rec.Id).Channel_Partner__c))
			{
				scidMap.put(rec.Sales_Credit_Number__c, rec);
			}
		}

		if (scidMap.isEmpty())
		{
			System.debug(TAG_NAME + '- nothing to process, exiting');
			System.debug('End ' + TAG_NAME);
			return;
		}

		List<TMT__c> tmtUpdate = new List<TMT__c>();

		for(TMT__c tmt : [SELECT 
								Id, 
								User__c, 
								Channel_Partner__c, 
								Sales_Credit_Number__c 
						  FROM 
						  		TMT__C 
						  WHERE 
						  		Sales_Credit_Number__c in : scidMap.keySet()])
		{
			tmt.User__c = scidMap.get(tmt.Sales_Credit_Number__c).User__c;
			tmt.Channel_Partner__c = scidMap.get(tmt.Sales_Credit_Number__c).Channel_Partner__c;
			tmtUpdate.add(tmt);
		}

		if (tmtUpdate.isEmpty())
		{
			System.debug(TAG_NAME + '- nothing to process, exiting');
			System.debug('End ' + TAG_NAME);
			return;
		}
		
		try
		{	        
			update tmtUpdate;
		}
		catch (DmlException e)
		{
			System.debug(TAG_NAME + '- error: ' + e.getMessage());
		}
		
		System.debug('End ' + TAG_NAME);
	}

}