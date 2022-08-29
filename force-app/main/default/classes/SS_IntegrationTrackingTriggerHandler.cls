/***********************************************************************************
 *@CLASS: SS_IntegrationTrackingTriggerHandler
 *@Test Class: SS_IntegrationTrackingTrigger_UT
 *@DESCRIPTION: This Class used to check the status and update the oauth connector and delete 
 * one month before record
 *-----------------------------------------------------------------------------------
 * DEVELOPER                   DATE                  REASON
 *------------------------------------------------------------------------------------
 * Hari                    2022-2-9              Created
 *************************************************************************************/
public class SS_IntegrationTrackingTriggerHandler {
    
    /****************************************************************************
     * Description : This Method check The integration Status and update the oauthConnector
     * **************************************************************************/
    public static void trackingStatusHandler(List<SSPR__SS_Integration_Tracking__c> integrationTrackingList){
        //set to store unauth status reocrd Id
        Set<Id> integrationIdSet = new Set<Id>();
        
        for(SSPR__SS_Integration_Tracking__c it : integrationTrackingList){
            
            if(it.SSPR__SS_Status__c == 'Unauthorized'){
                integrationIdSet.add(it.id);
            }
        }
        
        //check the set is empty if not empty update the oauth connector
        if(!integrationIdSet.isEmpty() && integrationIdSet != null){
            
            Database.executeBatch(new SS_DeleteWebHookHandlerClass(),1);
            List<SSPR__SS_SurveySparrow_OAuth_Manager__c> oauthConnectorList = new List<SSPR__SS_SurveySparrow_OAuth_Manager__c>();
            
            //query on oauthconnector to get the id to update
            for(SSPR__SS_SurveySparrow_OAuth_Manager__c oa : [select Id,SSPR__SS_is_Refresh_Token_Valid__c from SSPR__SS_SurveySparrow_OAuth_Manager__c 
                                           limit 1])
            {
                SSPR__SS_SurveySparrow_OAuth_Manager__c authConnector = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
                authConnector.Id        = oa.Id;
                authConnector.SSPR__SS_is_Refresh_Token_Valid__c = false;
                
                oauthConnectorList.add(authConnector);
             }
            
            //check the list is empty or not to update 
            if(!oauthConnectorList.isEmpty()){
                if(Schema.sObjectType.SSPR__SS_SurveySparrow_OAuth_Manager__c.isUpdateable()){
                    update oauthConnectorList;
                }
            }
        }
    }
    /****************************************************************************
     * Description : This Method delete the record which is related to before last month
     * **************************************************************************/    
    public static void deleteOldIntegrationTracking(){
        
        //list to delete tracking record
        List<SSPR__SS_Integration_Tracking__c> integrationTrackDeleteList = new List<SSPR__SS_Integration_Tracking__c>();
        
        //variable to store last month date
        Date lastMonthDate = system.today().addMonths(-1);
        
        //query on integration Tracking to releated last month before
        for(SSPR__SS_Integration_Tracking__c intergTrack : [select Id from SSPR__SS_Integration_Tracking__c 
                                                      where CreatedDate <=: lastMonthDate])
        {
            integrationTrackDeleteList.add(intergTrack);
        }
        
        //check the list is empty or not to delete the record
        if(!integrationTrackDeleteList.isEmpty()){
            if(Schema.sObjectType.SSPR__SS_Integration_Tracking__c.isDeletable()){
            	delete integrationTrackDeleteList;
            }
        }
        
    }

}