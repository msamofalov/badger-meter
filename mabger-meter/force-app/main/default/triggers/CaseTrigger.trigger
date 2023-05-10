trigger CaseTrigger on Case (after update) {
	
    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            FCRMetricHelper.calculate(trigger.new);
        }
    }
    
}