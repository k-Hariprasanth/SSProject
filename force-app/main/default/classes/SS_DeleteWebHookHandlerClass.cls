/***********************************************************************************
*@CLASS: SS_DeleteWebHookHandlerClass
*@Test Class: SS_DeleteWebHookHandlerClass_UT
*@DESCRIPTION: This Class used to delete Webhook url to Survey Sparrow
*-----------------------------------------------------------------------------------
* DEVELOPER                   DATE                  REASON
*------------------------------------------------------------------------------------
* Hari                   2021-12-15              Created
*************************************************************************************/
global class SS_DeleteWebHookHandlerClass implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'select Id,SSPR__SS_Webhook_Id__c,SSPR__SS_Is_Active_Survey__c from SSPR__SS_Survey__c'+(Test.isRunningTest()?' LIMIT 1':'');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<SSPR__SS_Survey__c> surveyList){
        
        SSPR__SS_Survey__c survey = null;
        
        for(SSPR__SS_Survey__c s : surveyList){
            survey = s;
            break;
        }
        
        if(survey.SSPR__SS_Webhook_Id__c == null || survey == null){
            return;
        }
        
        Integer webHookId = integer.valueof(survey.SSPR__SS_Webhook_Id__c);
        
        String surveyUrl = 'https://app.marketsparrow.com';
        
        string accessToken = null;
        
        SS_AccessTokenRequest a = new SS_AccessTokenRequest();
        accessToken = a.getAccessToken();
        
        for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c FROM SSPR__SS_Manage_SurveySparrow_Integration__c] ){
             if(m.SSPR__Is_thrivesparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com';
            }else if(m.SSPR__Is_surveysparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com'; 
            }
        }
        
        if(String.isNotBlank(surveyUrl)){
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(surveyUrl+ '/v1/webhooks/'+webHookId);
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            
            Http http = new Http();
             HTTPResponse resp = http.send(req);
            try{
               
                if( resp.getStatusCode() == 204){
                    system.debug(survey);
                    survey.SSPR__SS_Webhook_Id__c = '';
                    survey.SSPR__SS_Is_Active_Survey__c   = false;
                    if(Schema.sObjectType.SSPR__SS_Survey__c.isUpdateable()){
                        system.debug('udate============'+survey);
                        update survey;
                    }
                }
                
            }catch(Exception exe){
                
            }
        }
    }
    
    //batch finish method
    global void finish(Database.BatchableContext bc){}
    
    
    
    
}