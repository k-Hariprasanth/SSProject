/***********************************************************************************
*@CLASS: SS_SurveyRunnerSetupController
*@Test Class: SS_SurveyRunnerSetupController_UT 
*-----------------------------------------------------------------------------------
* DEVELOPER                  DATE (MM/DD/YYYY)     REASON
*------------------------------------------------------------------------------------
* Sugumar                                 Created
 *************************************************************************************/
public class SS_SurveyRunnerSetupController {
    
     /*********************************************************************************
    *@Description: check the account is connected
    *********************************************************************************/    
    @AuraEnabled
    public static Boolean isSurveyConnect(){
       List<SSPR__SS_SurveySparrow_OAuth_Manager__c> authList = [SELECT Id,SSPR__SS_Refresh_Token__c,SSPR__SS_is_Refresh_Token_Valid__c FROM SSPR__SS_SurveySparrow_OAuth_Manager__c limit 1];
        
        SSPR__SS_SurveySparrow_OAuth_Manager__c auth = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
        
        if(authList != null && !authList.isEmpty()){
            auth = authList[0];
        }else{
            return false;
        }
       
        return auth.SSPR__SS_is_Refresh_Token_Valid__c;
    }

     /*********************************************************************************
    *@Description: disconnect our account
    *********************************************************************************/    
    @AuraEnabled
    public static void disConnectSurvey(){
        
        Database.executeBatch(new SS_DeleteWebHookHandlerClass(),1);
        List<SSPR__SS_SurveySparrow_OAuth_Manager__c> oauthManager = [SELECT Id,SSPR__SS_is_Refresh_Token_Valid__c FROM SSPR__SS_SurveySparrow_OAuth_Manager__c limit 1];
        if(!oauthManager.isEmpty()){
            SSPR__SS_SurveySparrow_OAuth_Manager__c oauth = oauthManager[0];
            oauth.SSPR__SS_is_Refresh_Token_Valid__c = false;
        
           update oauth;
             
        }
        
    }

     /*********************************************************************************
    *@Description: getting dataCenter value to connect account
    *********************************************************************************/    
    @AuraEnabled
    public static String    getDataChoosenValue(){
        List<SSPR__SS_Manage_SurveySparrow_Integration__c> surveyManageDataCenterList   =   [select SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c from SSPR__SS_Manage_SurveySparrow_Integration__c ];
        if(!surveyManageDataCenterList.isEmpty()){
            SSPR__SS_Manage_SurveySparrow_Integration__c survMange = surveyManageDataCenterList[0];
            if(survMange.SSPR__Is_surveysparrow_Active__c){
                return ' US ';
            }else if(survMange.SSPR__Is_thrivesparrow_Active__c){
                return ' EU ';
            }
            
        }
        return '';
    }

     /*********************************************************************************
    *@Description: upate the custom settings to choosen dataCenter
    *********************************************************************************/    
    @AuraEnabled
    public static void updateSurveyOAuthUrl(String surveyOauthURL){
        List<SSPR__SS_Manage_SurveySparrow_Integration__c> surveyManageList = [select Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c from SSPR__SS_Manage_SurveySparrow_Integration__c ];
        if(!surveyManageList.isEmpty()){
            SSPR__SS_Manage_SurveySparrow_Integration__c survMange = surveyManageList[0];
            if(surveyOauthURL == 'surveysparrow.com'){
                survMange.SSPR__Is_surveysparrow_Active__c = true;
                survMange.SSPR__Is_thrivesparrow_Active__c = false;
            }else if(surveyOauthURL == 'thrivesparrow.com'){
                 survMange.SSPR__Is_surveysparrow_Active__c = false;
                 survMange.SSPR__Is_thrivesparrow_Active__c = true;
            }
            
            if(surveyOauthURL != ''){
                 update survMange;
            }
          
            
        }else{
            SSPR__SS_Manage_SurveySparrow_Integration__c manageSurvey = new SSPR__SS_Manage_SurveySparrow_Integration__c();
            
            
            manageSurvey.SSPR__Is_surveysparrow_Active__c = true;
            manageSurvey.SSPR__Is_thrivesparrow_Active__c = false;
            
            manageSurvey.SSPR__SS_Enable_SurveySparrow_Integration__c = false;
            
            insert manageSurvey;
        }
    }
}