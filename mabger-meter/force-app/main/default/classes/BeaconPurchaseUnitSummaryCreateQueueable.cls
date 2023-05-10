public with sharing class BeaconPurchaseUnitSummaryCreateQueueable implements Queueable {

    private Date earliestMonthStart;
    private Date latestMonthEnd;

    public BeaconPurchaseUnitSummaryCreateQueueable (Date earliestMonthStart, Date latestMonthEnd) {
        this.earliestMonthStart = earliestMonthStart;
        this.latestMonthEnd = latestMonthEnd;
    }

    public void execute (QueueableContext context) {
        System.debug('BeaconPurchaseUnitSummaryCreateQueueable Execution.');
        BeaconHelper.createPurchaseUnitSummaryRecords(earliestMonthStart, latestMonthEnd);
    }

}