trigger SS_IntegrationTrackingTrigger on SS_Integration_Tracking__c (before insert) {

    if(Trigger.isInsert && Trigger.isBefore){
        SS_IntegrationTrackingTriggerHandler.trackingStatusHandler(Trigger.New);
        SS_IntegrationTrackingTriggerHandler.deleteOldIntegrationTracking();
    }
}