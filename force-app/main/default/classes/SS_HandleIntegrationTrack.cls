/***********************************************************************************
*@CLASS: SS_HandleIntegrationTrack
*@Test Class: SS_HandleIntegrationTrack_UT
*@DESCRIPTION: This Class used to Track the Integration
*-----------------------------------------------------------------------------------
* DEVELOPER                   DATE                  REASON
*------------------------------------------------------------------------------------
* Hari                   					          Created
*************************************************************************************/
public class SS_HandleIntegrationTrack {

    public static void updateSurveyOauth(){
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
    
    public static Boolean	 getIsCreateIntegrateTrack(){
        List<SSPR__SS_Manage_SurveySparrow_Integration__c> integrationSettingList = [select SSPR__SS_Enable_SurveySparrow_Integration__c from SSPR__SS_Manage_SurveySparrow_Integration__c limit 1];
        if(integrationSettingList.size() > 0){
            SSPR__SS_Manage_SurveySparrow_Integration__c it = integrationSettingList[0];
            return it.SSPR__SS_Enable_SurveySparrow_Integration__c;
        }
        return false;
    }
    
    //create Record On intergration Track
    public static void createIntegrationTrack(String requestStatus,String endPoint,String requestBody,
                                              String surveyName,String surveyId,
                                             String requestMethod,String errorMessage)
    {
        
        SSPR__SS_Integration_Tracking__c integrationTrack = new SSPR__SS_Integration_Tracking__c();
        integrationTrack.SSPR__SS_End_Point__c      =  endPoint;
        integrationTrack.SSPR__SS_Status__c         =  requestStatus;
        integrationTrack.SSPR__SS_Request_Body__c   =  requestBody;
        integrationTrack.SSPR__SS_Request_Method__c =  requestMethod;
        integrationTrack.SSPR__SS_Error_Message__c  = errorMessage;
        integrationTrack.SSPR__SS_Survey_Name__c    = surveyName;
        integrationTrack.SSPR__SS_Related_to_Id__c  = surveyId;
       
        
        if(Schema.sObjectType.SSPR__SS_Integration_Tracking__c.isCreateable()){
            insert integrationTrack;
        }
        
    }
}