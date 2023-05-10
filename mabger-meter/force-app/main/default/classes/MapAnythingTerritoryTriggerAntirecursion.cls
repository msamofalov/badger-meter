public Class MapAnythingTerritoryTriggerAntirecursion {
    private static boolean run = true;
    
    public static boolean runOnce () {
    	if (run) {
     		run = false;
     		return true;
    	}
    	else{
        	return run;
    	}
    }
    
    @TestVisible
    private static void reset () {
    	run = true;
    }
}