global class Utmt
{

	global class UpdateTMT implements gearsBase.gearsExecute.executeMethod
	{
		public void execute(List<SObject> records, Map<Id, sObject> oldMap, gearsBase.gearsExecute.triggerParameters tp)
		{
			update_User_ChannelPartner(records, (Map<Id, TMT__c>) oldMap, tp);
		}
	}

	/**
	 * update_User_ChannelPartner Sets TMT__c fields Market_Text__c, and Sales_Credit_Name__c
	 * @param  records List of TMT__c records
	 * @param  oldMap  Trigger.oldMap
	 * @param  tp      GearsBase.gearsExecute.triggerParameters
	 */
	public static void update_User_ChannelPartner(List<TMT__c> records, Map<Id, TMT__c> oldMap, gearsBase.gearsExecute.triggerParameters tp)
	{
		final String TAG_NAME = Utmt.class.toString() + '.update_User_ChannelPartner';
		System.debug('Start ' + TAG_NAME);

		if (UUtil.inBatch)
		{
			System.debug(TAG_NAME + '- in batch, bypassing');
			System.debug('End ' + TAG_NAME);
			return;
		}

		Set<String> saleCreditIds = new Set<String> ();

		for (TMT__c tmt : records) 
		{
			if (tmt.Sales_Credit_Number__c != null) 
			{
				saleCreditIds.add(tmt.Sales_Credit_Number__c);
			}

			tmt.Market_Text__c = tmt.Market_Name__c;
		}

		Map<String, Sales_Credit_ID__c> salesCreditIdMap = new Map<String, Sales_Credit_ID__c> ();
		System.debug(TAG_NAME + '- saleCreditIds: ' + saleCreditIds);

		if (saleCreditIds.isEmpty()) 
		{
			System.debug(TAG_NAME + '- nothing to process, exiting');
			System.debug('End ' + TAG_NAME);
			return;
		}

		for (Sales_Credit_ID__c scid :	[SELECT 
												Id, 
												User__c, 
												User__r.Name, 
												Sales_Credit_Number__c, 
												Channel_Partner__c, 
												Channel_Partner__r.Name
		     							 FROM 
		     									Sales_Credit_ID__c
		     							 WHERE 
		     									Active__c = true 
		     							 AND
		     									Sales_Credit_Number__c in : saleCreditIds
		     							 AND
		     									(Channel_Partner__c != null OR User__c != null)])
		{
			salesCreditIdMap.put(scid.Sales_Credit_Number__c, scid);
		}

		if (salesCreditIdMap.isEmpty())
		{
			return;
		}

		for (TMT__c tmt : records) 
		{
			if (tmt.Sales_Credit_Number__c != null
				&& (tp.isInsert
					|| tmt.Sales_Credit_Number__c != oldMap.get(tmt.Id).Sales_Credit_Number__c
					|| tmt.MATest__c != oldMap.get(tmt.Id).MATest__c))
			{
				if (!salesCreditIdMap.containsKey(tmt.Sales_Credit_Number__c)) 
				{
					continue;
				}

				Sales_Credit_ID__c sc = salesCreditIdMap.get(tmt.Sales_Credit_Number__c);
				tmt.User__c = sc.User__c;
				tmt.Channel_Partner__c = sc.Channel_Partner__c;
				String creditName;

				if (sc.User__c != null)
				{
					creditName = sc.User__r.Name;
				}
				else if (sc.Channel_Partner__c != null)
				{
					creditName = sc.Channel_Partner__r.Name;
				}

				if (creditName == null)
				{
					continue;
				}

				tmt.Sales_Credit_Name__c = (creditName.length() > 50) ? creditName.left(50) : creditName;
			}
		}

		System.debug('End ' + TAG_NAME);
	}
}