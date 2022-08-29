/***********************************************************************************
 *@CLASS: SS_SurveySyncManager
 *@Test Class: SS_SurveySyncManager_UT
 *@DESCRIPTION: This Class used to download the Question and Post Webhook url to Survey Sparrow
 *-----------------------------------------------------------------------------------
 * DEVELOPER                   DATE                  REASON
 *------------------------------------------------------------------------------------
 * Sugumar                    2021-12-16              Created
 *************************************************************************************/

global class SS_SurveySyncManager implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts{

    
    global Database.QueryLocator start(Database.BatchableContext bc) {

        

        String query = 'SELECT Id,Name,SSPR__SS_Survey_Id__c,SSPR__SS_Webhook_Id__c FROM SSPR__SS_Survey__c Where SSPR__SS_Is_Active_Survey__c = true'+(Test.isRunningTest()?' LIMIT 1':'');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SSPR__SS_Survey__c> surveyList){
        
        string accessToken = null;
        //Get Access token
        SS_AccessTokenRequest a = new SS_AccessTokenRequest();
        accessToken             = a.getAccessToken();
        
        String surveyUrl      = 'https://app.marketsparrow.com';
       
        String webhookSiteURL ;
        
       
        
        for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c,SSPR__SS_Webhook_Site_URL__c FROM SSPR__SS_Manage_SurveySparrow_Integration__c] ){
            if(m.SSPR__Is_thrivesparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com';
            }else if(m.SSPR__Is_surveysparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com'; 
            }
            webhookSiteURL = m.SSPR__SS_Webhook_Site_URL__c;
        }


        if(String.isNotEmpty(webhookSiteURL) && webhookSiteURL != null){
            
            if(webhookSiteURL.startsWith('https://')){
                webhookSiteURL = webhookSiteURL + '/services/apexrest/SSPR/api/Webhooks/incoming/SurveyResponse';
            }else{
                webhookSiteURL = 'https://' +webhookSiteURL + '/services/apexrest/SSPR/api/Webhooks/incoming/SurveyResponse';
            }
            
            
            SSPR__SS_Survey__c survey = null;
            List<SSPR__SS_Question__c> questionRecordToBeUpserted = new List<SSPR__SS_Question__c>();
            
            for(SSPR__SS_Survey__c s : surveyList){
                system.debug(s);
                survey = s;
                break;
            }
            system.debug(survey);
            if(survey == null){
                return;
            }
            String exceptionString = '';
             Boolean createTracking = SS_HandleIntegrationTrack.getIsCreateIntegrateTrack();
            //download Survey Question
            HttpRequest req = new HttpRequest();
            req.setEndpoint(surveyUrl + '/v1/surveys/'+ survey.SSPR__SS_Survey_Id__c + '/questions'); 
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            Http http         = new Http();
            HTTPResponse resp = http.send(req);
            try{
                if(resp.getStatus() == 'Ok' && resp.getStatusCode() == 200 && resp.getBody() != null ){
                    system.debug('----------'+resp.getBody());
                    //Deserializing the response
                    Map<string,Object> deserializedResponseMap =  (Map<String,object>)JSON.deserializeUntyped(resp.getBody()) ;
                    Object QuestionObject                      = deserializedResponseMap.get('questions');
                    List<Object> questionObjectList            = (List<Object>)QuestionObject;
                    
                    for(Object eachRecord : questionObjectList){
                        Map<String,Object> questionMap = (Map<String,Object>)eachRecord;
                        
                        //Creating the Question records from the Response   
                        if(questionMap.get('id') != null){
                            
                            SSPR__SS_Question__c question      = new SSPR__SS_Question__c();
                            question.SSPR__SS_Question__c      = questionMap.get('rtxt').toString();
                            question.SSPR__SS_Question_Id__c   = String.valueOf(questionMap.get('id'));
                            question.SSPR__SS_Composite_Key__c = survey.SSPR__SS_Survey_Id__c + '_' + String.valueOf(questionMap.get('id'));
                            question.SSPR__SS_Type__c          = String.valueOf(questionMap.get('type'));
                            question.SSPR__Survey__c           = survey.Id;
                            question.SSPR__SS_Available_Answers__c = JSON.serialize(eachRecord) + '';
                            
                            String choicetxt = '';
                            Map<Integer,String> choicewithposition = new Map<Integer,String>();
                            Object choicesObject                   = questionMap.get('choices');
                            List<Object> choicesObjectList         = (List<Object>)choicesObject;
                            if(choicesObjectList != null && !choicesObjectList.isEmpty()){
                                
                                for(Object choice : choicesObjectList){
                                    
                                    Map<String,Object> choiceMap = (Map<String,Object>)choice;
                                    if(choiceMap.get('txt') != null){
                                        choicewithposition.put(Integer.valueOf(choiceMap.get('position')) , (choiceMap.get('txt') + ''));
                                    }
                                }
                                for(Integer key : choicewithposition.keySet()){
                                    
                                    if(key == 0 && choicetxt == ''){
                                        choicetxt = choicetxt + '' + choicewithposition.get(key) + ',';
                                    }else if(key == 0 && choicetxt != ''){
                                        choicetxt =  choicewithposition.get(key) + ',' + choicetxt + '';
                                    }else{
                                        choicetxt = choicetxt + '' + choicewithposition.get(key) + ',';
                                    }
                                    
                                }                              
                                choicetxt = choicetxt.removeEnd(',');
                                
                            }
                            
                            
                            question.SSPR__SS_Available_Answers__c = choicetxt;
                            questionRecordToBeUpserted.add(question);
                            
                        }
                    }
                    
                    //Upserting the Question Records based on the external Id SSPR__SS_Question_Id__c     
                    if(!questionRecordToBeUpserted.isEmpty()){
                        AddWebHooksUrlSurveyRequest webHookRequest = new AddWebHooksUrlSurveyRequest('Salesforce Response Sync', webhookSiteURL, survey.SSPR__SS_Survey_Id__c, 'POST', questionRecordToBeUpserted);
                        
                        String webhookId = null;
                        
                        if(survey.SSPR__SS_Webhook_Id__c == null || survey.SSPR__SS_Webhook_Id__c == ''){
                            //Check weather the webhook is already persent in Survey Sparrow with same name Salesforce Response Sync
                            //If yes. delete the existing webhook in survey sparrow
                            //And create new webhook for that survey
                            
                            
                            webhookId = addWebhooks(JSON.serialize(webHookRequest), surveyUrl, accessToken,survey.Name,survey.SSPR__SS_Survey_Id__c,createTracking);
                            survey.SSPR__SS_Webhook_Id__c = webhookId;
                            if(Schema.sObjectType.SSPR__SS_Survey__c.isUpdateable()){
                                update survey;
                            }
                            
                            
                        }else{
                            webhookId = updateWebhooks(JSON.serialize(webHookRequest), survey.SSPR__SS_Webhook_Id__c, surveyUrl, accessToken,survey.Name,survey.SSPR__SS_Survey_Id__c,createTracking);
                        }
                        
                        Schema.SObjectField ExternalIdField = SSPR__SS_Question__c.Fields.SSPR__SS_Question_Id__c;
                        if(Schema.sObjectType.SSPR__SS_Question__c.isCreateable() || Schema.sObjectType.SSPR__SS_Question__c.isUpdateable()){
                            List<Database.UpsertResult> UpsertedResult = Database.upsert(questionRecordToBeUpserted, ExternalIdField, false);
                        }
                    }
                }else if(resp.getStatus() == 'Unauthorized'){
                    if(createTracking == false){
                        SS_HandleIntegrationTrack.updateSurveyOauth();
                    }
                }
            }catch(Exception exe){
                exceptionString = exe.getMessage();
            } 
            //Query On CS To Indicate Wheather to Create Integration Track
           
            if(createTracking){
                SS_HandleIntegrationTrack.createIntegrationTrack(resp.getStatus(),req.getEndpoint(),resp.getBody(),survey.Name,survey.SSPR__SS_Survey_Id__c,
                                       req.getMethod(),exceptionString);
            }
            //Post Webhookurl
        }
    }

     //batch finish method
     global void finish(Database.BatchableContext bc){}

    public static String addWebhooks(String reqWrapper, String surveyUrl, String accessToken,String surveyName,String surveyId,Boolean createTracking){
       
        String webhookId = null;
        HttpRequest req = new HttpRequest();
        String exceptionString = '';
        req.setEndpoint(surveyUrl + '/v1/webhooks');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
       
        req.setBody(reqWrapper);
       
        
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        try{
            if(resp.getStatus() == 'Ok' && resp.getStatusCode() == 200 && resp.getBody() != null){
                Map<String,Object> liskResponse = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
                webhookId = String.valueOf(liskResponse.get('id'));
            }else if(resp.getStatus() == 'Unauthorized'){
                if(createTracking == false){
                    SS_HandleIntegrationTrack.updateSurveyOauth();
                }
            }
        }catch(Exception exe){
            exceptionString = exe.getMessage();
        }
        //Query On CS To Indicate Wheather to Create Integration Track
        if(createTracking){
             SS_HandleIntegrationTrack.createIntegrationTrack(resp.getStatus(),req.getEndpoint(),resp.getBody(),surveyName,surveyId,
                                   req.getMethod(),exceptionString);
        }
        
        
        
        
        return webhookId;
    }

    public static String updateWebhooks(String reqWrapper, String webhook, String surveyUrl, 
                                        String accessToken,String surveyName,String surveyId,Boolean createTracking)
    {
       
        String webhookId = null;
        String exceptionString = '';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(surveyUrl + '/v1/webhooks/' + webhook);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setBody(reqWrapper);
       
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        
        try{
            if(resp.getStatus() == 'Ok' && resp.getStatusCode() == 200 && resp.getBody() != null){
                Map<String,Object> liskResponse = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
                webhookId = String.valueOf(liskResponse.get('id'));
            }else if(resp.getStatus() == 'Unauthorized'){
                    if(createTracking == false){
                        SS_HandleIntegrationTrack.updateSurveyOauth();
                    }
            }

        }catch(Exception exe){
            exceptionString = exe.getMessage();
        }
        
        //Query On CS To Indicate Wheather to Create Integration Track
        if(createTracking){
            SS_HandleIntegrationTrack.createIntegrationTrack(resp.getStatus(),req.getEndpoint(),resp.getBody(),surveyName,surveyId,
                                   req.getMethod(),exceptionString);
        }
        
        
        return webhookId;
            
    }

    

    public class AddWebHooksUrlSurveyRequest{
        //webHook Name
        public String name;
        //webHook Url
        public String url;
        //survey Id
        public String surveyId;
        //RequestType
        public  String httpMethod;
        //header Request
        public List<HeaderRequest> headers;
        public String type;
        //Constructor
        //public object payload;
        public AddWebHooksUrlSurveyRequest(String webName, String webHookUrl, String idSurvey, String method, List<SSPR__SS_Question__c> questionList)
        {
            name = webName;
            url = webHookUrl;
            surveyId = idSurvey;
            httpMethod = method;
            type = 'zapier';
            headers = new List<HeaderRequest>();
            headers.add(new HeaderRequest());
            
            //payload = null;
            //payload = getPayLoads(idSurvey, questionList);
        }
        
    }

    public class HeaderRequest{
        //header Request Value
        public String value;
        //header Request Key
        public String key;
        
        //HeaderRequestConstructor
        public HeaderRequest(){
            key = 'Content-Type';
            value = 'application/json';
        }
    }
    
    public static String getPayLoads(String surveyId, List<SSPR__SS_Question__c> questionList1){
        
        String payload = '{ "surveyId": "{survey_id}","submission_Id": "{submission_id}",';
        String questionList = '';
       

        for(SSPR__SS_Question__c q : questionList1){
            String key = q.SSPR__SS_Composite_Key__c;
            String value = '"{question_' + q.SSPR__SS_Question_Id__c + '}"';
            questionList += '"' + key + '"' + ':' + value + ',';
            
        }
        questionList = questionList.removeEnd(',');
        payload = payload + questionList + '}';
       
        return payload;
        
    }
    

}