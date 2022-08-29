/***********************************************************************************
*@CLASS: SS_SurveyIntegrationManagerClass
*@Test Class: SS_SurveyIntegrationManagerClass_UT 
*-----------------------------------------------------------------------------------
* DEVELOPER                  DATE (MM/DD/YYYY)     REASON
*------------------------------------------------------------------------------------
* Sugumar                    12/21/2021             Created
*************************************************************************************/
global class SS_SurveyIntegrationManagerClass {
    
    public static String relatedtoId ;
    public static String relatedtoName ;
    public static String surveyName;
    public static String surveyRunnerId;
    public static String accessToken1;
    public static List<SSPR__SS_Integration_Tracking__c>  integratioTrackingList;
    
    //flow invokable method 
    @InvocableMethod(label='SurveySparrow Runner')
    global static void sparrowIntegration(List<FlowInputs> listOfInput){
        
        String runnerNameInSurvey;
        for(FlowInputs f : listOfInput){
            runnerNameInSurvey = f.surveyRunnerName;
            
        }
        List<SSPR__SS_SurveySparrow_Runner__c> surveyRunnerList = [select Id from SSPR__SS_SurveySparrow_Runner__c where Name =:runnerNameInSurvey];
        //check if List contain Value Then invoke Future Method
        if(!surveyRunnerList.isEmpty()){
            
            handleCallOut(JSON.serialize(listOfInput));
        }
        
    }
    
    
    
    @future(callout=true)
    public static void handleCallOut(String flist){
        
        String accessToken;
        
        
        
        //deserialize the inputs
        List<FlowInputs> listOfInput = (List<FlowInputs>)JSON.deserialize(flist, List<FlowInputs>.class);
        Map<Id, String> objIdtoTrigName = new MAp<Id,String>();
        
        //iterate the list of input to get the RunnerName and SobjectId
        Set<String> surveyRunnerNameSet = new Set<String>();
        String ObjectAPIName = null;
        
        
        
        String selectedRecipient;
        
        Map<String, SSPR__SS_SurveySparrow_Runner__c> surveyRunnerMap = new Map<String, SSPR__SS_SurveySparrow_Runner__c>();
        
        for(FlowInputs fi : listOfInput){
            
            surveyRunnerNameSet.add(fi.surveyRunnerName);
            objIdtoTrigName.put(fi.sobjectRecordId, fi.surveyRunnerName);
        }
        
        ObjectAPIName = getSurveyRunnerRecord(surveyRunnerMap, surveyRunnerNameSet);
        Boolean createTracking = SS_HandleIntegrationTrack.getIsCreateIntegrateTrack();
        
        List<Sobject> sobjectRecordsList = getObjectRecords(ObjectAPIName, objIdtoTrigName.keySet());
        
        
        
        for(Sobject objIterator : sobjectRecordsList){
            
            if(objIdtoTrigName.get(objIterator.Id) != null 
               && surveyRunnerMap.get(objIdtoTrigName.get(objIterator.Id)) != null)
            {
                SSPR__SS_SurveySparrow_Runner__c ssRunner = surveyRunnerMap.get(objIdtoTrigName.get(objIterator.Id));
                
                relatedtoId    = objIterator.Id;
                surveyName     = ssRunner.SSPR__SS_Survey__r.Name;
                surveyRunnerId = ssRunner.Id;
                
                //Create share Link that will attached in the message
                String share_link = null;
                
                Boolean isSuccess = false;
                
                if(ssRunner.SSPR__SS_Send_Survey_Via__c == 'EMAIL'){
                    
                    
                    
                    //   String channelId = getShareIdResponse(ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c, 'EMAIL', accessToken,ssRunner.SSPR__SS_Survey__r.Name);
                    String recipientEmail = String.valueOf(objIterator.get(ssRunner.SSPR__SS_Send_Survey_to__c) );
                    if(ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'NPS'  || ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'NPSChat' ||
                       ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'CES' || ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'CESChat' || 
                       ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'CSAT' || ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'CSATChat' )
                    {
                        
                        isSuccess = shareNPSemailsurvey(ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c,recipientEmail,objIterator,ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c,ssRunner, accessToken);
                        
                    }else{
                        isSuccess = shareEmailSurveyv2(ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c, ssRunner.SSPR__SS_Survey_Share__c, recipientEmail, share_link,objIterator,ssRunner, accessToken,ssRunner.SSPR__SS_Survey__r.Name);
                        
                    }
                }else if(ssRunner.SSPR__SS_Send_Survey_Via__c == 'SMS'){
                    
                    //Get Share Id - Email Share or SMS Share
                    String channelId = getShareIdResponse(ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c, 'SMS', accessToken,ssRunner.SSPR__SS_Survey__r.Name);
                    
                    String mobileNo = String.valueOf(objIterator.get(ssRunner.SSPR__SS_Send_Survey_to__c) );
                    
                    
                    if(ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'NPS'  || ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'NPSChat' ||
                       ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'CES' || ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'CESChat' || 
                       ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'CSAT' || ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c == 'CSATChat' )
                    {
                        isSuccess = shareNPSSurveySMS(ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c,mobileNo,ssRunner,objIterator,ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c, accessToken,ssRunner.SSPR__SS_Survey_Share__c,channelId);
                    }else{
                        isSuccess = shareSMSSurveyv2(ssRunner.SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c, ssRunner.SSPR__SS_Survey_Share__c, mobileNo, share_link,objIterator,ssRunner, accessToken,ssRunner.SSPR__SS_Survey__r.Name);
                        
                    }
                    
                }
            }
            
        }
        
      /*if(createTracking){
            if(Schema.sObjectType.SSPR__SS_Integration_Tracking__c.isCreateable()){
                insert integratioTrackingList;
            }
            
        } */
    }
    
    
    public static List<Sobject> getObjectRecords(String ObjectAPIName, Set<Id> sobjectIdSet){
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(ObjectAPIName).getDescribe().fields.getMap();
        Set<String> sobjectFields = fieldMap.keyset();
        
        String fieldsString =  '';
        
        for(String str : sobjectFields){
            fieldsString += str + ', ';
        }
        
        
        fieldsString = fieldsString.substring(0, fieldsString.length()-2);
        
        String query = 'SELECT '+ fieldsString +' FROM  ' + ObjectAPIName + ' WHERE Id IN: sobjectIdSet';
        List<sObject> sobjectRecordsList = Database.query(query);
        return sobjectRecordsList;
    }
    
    //Query Survey Sparrow Trigger record and Email Template information
    public static String getSurveyRunnerRecord(Map<String, SSPR__SS_SurveySparrow_Runner__c> surveyRunnerMap, Set<String> surveyRunnerNameSet){
        
        // Set<String> templateName = new Set<String>();
        String ObjectAPIName = null;
        //query on sparrow object and  check the trigger action
        for(SSPR__SS_SurveySparrow_Runner__c ssp : [SELECT Id, Name,SSPR__SS_Survey__r.Name,SSPR__SS_Send_Survey_Via__c,
                                              SSPR__SS_Survey__c,SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c,SSPR__SS_Survey__r.SSPR__SS_Survey_Type__c, 
                                              SSPR__SS_Object_Name__c,SSPR__SS_Object_Fields_Name__c,SSPR__SS_Send_Survey_to__c,SSPR__SS_Survey_Share__c  
                                              FROM SSPR__SS_SurveySparrow_Runner__c WHERE Name IN: surveyRunnerNameSet])
        {
            surveyRunnerMap.put(ssp.Name, ssp);
            
            
            
            if(ObjectAPIName == null){
                ObjectAPIName = String.valueOf(ssp.SSPR__SS_Object_Name__c);
                
            }
        }
        
        
        
        return ObjectAPIName;
    }
    
    public static String getShareIdResponse(String survey_id, String type, String accessToken,String surveyName){
        
        String channelId = null;
        String url = '/v1/surveys/' + survey_id + '/shares?type=' + type;
        
        try{
            
            HTTPResponse response = getResponse(url, 'GET', null, accessToken,surveyName,survey_id);
            
            if(response.getStatus() == 'Ok' && response.getStatusCode() == 200 && response.getBody() != null ){
                channelId = getShareId( (Map<String,Object>)JSON.deserializeUntyped(response.getBody()), type);
            }
            
        }catch(Exception exe){
            
        }
        
        return channelId;
    }
    
    
    /*********************************************
*@Description: Format the endpoint URL and method dynamically for Email Share
**********************************************/
    public static Boolean shareEmailSurveyv2(String surveyId, String shareId, String email, String share_link,sobject targetObject,SSPR__SS_SurveySparrow_Runner__c ssRunner, String accessToken,String surveyName){
        
        Map<String,String> objectFieldsValueMap = getselectedFieldsValueMap(ssRunner,targetObject);
        if(!objectFieldsValueMap.keySet().isEmpty()){
            objectFieldsValueMap.put('SurveyRunnerId',surveyRunnerId);
        }
        
        
        ShareEmailSurveyV2Request req = new ShareEmailSurveyV2Request(email,false,objectFieldsValueMap);
        
        HTTPResponse response = getResponse('/v2/survey/' + surveyId + '/shares/email/' + shareId, 'PUT', JSON.serialize(req), accessToken,surveyName,surveyId);
        return true;
    } 
    
    /*********************************************
*@Description: Format the endpoint URL and method dynamically for SMS Share
**********************************************/
    public static Boolean shareSMSSurveyv2(String surveyId, String channelId, String mobileNumber, String share_link,Sobject targetObject,SSPR__SS_SurveySparrow_Runner__c ssRunner, String accessToken,String surveyName){
        Map<String,String> objectFieldsValueMap = getselectedFieldsValueMap(ssRunner,targetObject);
        if(!objectFieldsValueMap.keySet().isEmpty()){
            objectFieldsValueMap.put('SurveyRunnerId',surveyRunnerId);
        }
        
        ShareSMSSurveyV2Request req = new ShareSMSSurveyV2Request(mobileNumber,  'Hey, Can you spare a moment to take this survey {survey_link}?',JSON.serialize(objectFieldsValueMap));
        system.debug('------------sms json------------'+ JSON.serialize(req));
        HTTPResponse response = getResponse('/v2/survey/' + surveyId + '/shares/sms/' + channelId, 'PUT', JSON.serialize(req), accessToken,surveyName,surveyId);
        
        return true;
    }
    /*********************************************
*@Description: Format the endpoint URL and method dynamically for Nps Email Share
**********************************************/
    public static Boolean shareNPSemailsurvey(String surveyId,String email,Sobject targetObject,String npsName,SSPR__SS_SurveySparrow_Runner__c ssRunner,String accessToken){
        Map<String,String> objectFieldsValueMap =  getselectedFieldsValueMap(ssRunner,targetObject);
        if(!objectFieldsValueMap.keySet().isEmpty()){
            objectFieldsValueMap.put('SurveyRunnerId',surveyRunnerId);
        }
        
        ShareNPSsurveyRequest req = new ShareNPSsurveyRequest(email,JSON.serialize(objectFieldsValueMap));
        
        HTTPResponse response = getResponse('/v1/nps/'+surveyId+'/email', 'POST', JSON.serialize(req), accessToken,npsName,surveyId);
        return true;
        
    }
    public static Boolean shareNPSSurveySMS(String surveyId,String mobileNo,SSPR__SS_SurveySparrow_Runner__c ssRunner,Sobject targetObject,String surveyName, String accessToken,String shareId,String channelId){
        Map<String,String> objectFieldsValueMap = getselectedFieldsValueMap(ssRunner,targetObject);
        
        if(!objectFieldsValueMap.keySet().isEmpty()){
            objectFieldsValueMap.put('SurveyRunnerId',surveyRunnerId);
        }
        
        String messageContent = 'Take survey via sms {survey_link}';
        ShareSMSSurveyNPSRequest req = new ShareSMSSurveyNPSRequest(mobileNo,messageContent,JSON.serialize(objectFieldsValueMap));
        HTTPResponse response = getResponse('/v1/nps/' + surveyId + '/sms', 'POST', JSON.serialize(req), accessToken,surveyName,surveyId);
        
        return true;
        
    }
    
    
    /*********************************************
*@Description: This method used send a request to Survey Sparrow to the end point
**********************************************/
    public static HTTPResponse getResponse(String url, String method, String reqWrapper, String accessToken,String surveyName,String surveyId){
        
        String surveyUrl = 'https://app.marketsparrow.com';
        String exceptionString = '';
        for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c FROM SSPR__SS_Manage_SurveySparrow_Integration__c] ){
            if(m.SSPR__Is_thrivesparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com';
            }else if(m.SSPR__Is_surveysparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com'; 
            }
        }
        
        Boolean createTracking = SS_HandleIntegrationTrack.getIsCreateIntegrateTrack();
        if (Cache.Org.contains('SSPR.AccessTokenValue.accessToken')) {
            accessToken1 = (String)Cache.Org.get('SSPR.AccessTokenValue.accessToken');
        }else{
            accessToken1 = getAccessTokenAndPutCache();
             
        }
        
       
        
        if(String.isNotBlank(surveyUrl)){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(surveyUrl+ url);
            system.debug(surveyUrl+ url);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken1);
            if(reqWrapper != null){
                req.setBody(reqWrapper); 
            }
            
            Http http = new Http();
            HTTPResponse resp = null;
            try{
                if(test.isRunningTest()){
                    SS_TestMockHttResponse testMockUp = new SS_TestMockHttResponse();
                    resp =  testMockUp.respond(req);
                }else{
                    
                    
                    resp = http.send(req);
                    if(resp.getStatus() == 'Unauthorized'){
                       
                        accessToken1 = getAccessTokenAndPutCache();
                        req.setHeader('Authorization', 'Bearer ' + accessToken1);
                        resp = http.send(req);
                        if(resp.getStatus() == 'Unauthorized'){
                            
                            accessToken1 = getAccessTokenAndPutCache();
                            req.setHeader('Authorization', 'Bearer ' + accessToken1);
                            resp = http.send(req);
                        }
                     /* if(createTracking == false){
                            SS_HandleIntegrationTrack.updateSurveyOauth();
                        } */
                    }
                }
                
                
            }catch(Exception exe){
                exceptionString = exe.getMessage();
            }
            system.debug('==========='+resp.getStatus());
            system.debug('==========='+req.getEndpoint());
            system.debug('==========='+resp.getBody());
            system.debug('==========='+req.getMethod());
            
            
          /*  if(createTracking){
                integratioTrackingList = new List<SSPR__SS_Integration_Tracking__c>();
                integratioTrackingList.add(createIntegrationTrack(resp.getStatus(),req.getEndpoint(),resp.getBody(),surveyName,surveyId,
                                                                  req.getMethod(),exceptionString));
            }   */
            
            
            return resp;                
        }
        
        return null;
        
        
    }
    
    public static String getAccessTokenAndPutCache(){
        String accessTokenString;
        SS_AccessTokenRequest ac = new SS_AccessTokenRequest();
        accessTokenString = ac.getAccessToken();
         Cache.Org.put('SSPR.AccessTokenValue.accessToken', accessTokenString,350);
        return accessTokenString;
    }
    
    public static Map<String,String> getselectedFieldsValueMap(SSPR__SS_SurveySparrow_Runner__c ssRunner,Sobject targetObject){
        Map<String,String> objectFieldsValueMap = new Map<String,String>();
        List<String> fieldsList = new List<String>();
        if(ssRunner.SSPR__SS_Object_Fields_Name__c != null){
            fieldsList.addAll(ssRunner.SSPR__SS_Object_Fields_Name__c.split(','));
        }
        if(!fieldsList.isEmpty()){
            for(String s : fieldsList){
                if(s == 'Id'){
                    objectFieldsValueMap.put('SobjectRecordId',String.valueof(targetObject.get(s)));
                }else{
                    if(targetObject.get(s) != null ){
                        objectFieldsValueMap.put(s, String.valueof(targetObject.get(s)));
                    }
                    
                }
            }
        }
        
        return objectFieldsValueMap;
    }
    
    /**********************************************
*@Description: This method return the share_id from the create link api response 
**********************************************/
    public static String getShareId(Map<String,Object> josnRowMap, String type){
        
        Object shareObject = josnRowMap.get('shares');
        List<Object> shareObjectList = (List<Object>)shareObject;
        
        for(Object objIterator : shareObjectList){
            
            Map<String,Object> shareVariableMap = (Map<String,Object>)objIterator;
            if(shareVariableMap.get('status') == 'ACTIVE' && shareVariableMap.get('type') == type){
                return String.valueOf(shareVariableMap.get('id'));
            }
            
        }
        return null;
    }
    
    //create Record On intergration Track
    public static SSPR__SS_Integration_Tracking__c createIntegrationTrack(String requestStatus,String endPoint,String requestBody,
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
        
        
        return  integrationTrack;
        
        
    }
    
    
    
    public class ShareSMSSurveyV2Request{
        
        public List<contactsPhoneClass> contacts;
        public String message;
        public String variables;
        
        
        public ShareSMSSurveyV2Request(String mobileNo, String message1,String variable){
            message = message1;
            
            contacts = new List<contactsPhoneClass>();
            variables = variable;
            contacts.add(new contactsPhoneClass(mobileNo));
        }
    }
    public class ShareSMSSurveyNPSRequest{
        
        public List<contactsPhoneClass> contacts;
        public PropertiesClass properties;
        public String customProperties;
        
        public ShareSMSSurveyNPSRequest(String mobileNo,String contentMessage,String customPropertiesVariables){
            
            contacts = new List<contactsPhoneClass>();
            contacts.add(new contactsPhoneClass(mobileNo));
            properties = new PropertiesClass(contentMessage);
            customProperties = customPropertiesVariables;
        }
    }
    
    public class contactsPhoneClass{
        public String mobile;
        public contactsPhoneClass(String mob){
            mobile = mob;
        }
    }
    
    public class ShareEmailSurveyV2Request{
        
        public List<contactsClass> contacts ;
        public Map<String,String> variables;
        public Boolean ignoreThrottledContacts;
        
        public ShareEmailSurveyV2Request(String cont, Boolean ignoreThrottled, Map<String,String> variable ){
            
            variables = variable;
            
            ignoreThrottledContacts = ignoreThrottled;
            //    variables = new VariablesClass(team, manager);
            contacts = new List<contactsClass>();
            contacts.add(new contactsClass(cont));
        }             
    }
    public class ShareNPSsurveyRequest{
        
        
        public List<contactsClass> contacts;
        public String name = 'NPS';
        public String mode = 'BLAST';
        public String customProperties;
        
        public ShareNPSsurveyRequest(String email,String customPropertiesVariables){
            contacts = new List<contactsClass>();
            contacts.add(new contactsClass(email));
            customProperties = customPropertiesVariables;
        }
    }
    
    public class contactsClass{
        
        public String email;
        public contactsClass(String email1){
            email = email1;
        }        
    }
    
    
    
    public class PropertiesClass{
        public String content;
        public PropertiesClass(String contentMessage){
            content = contentMessage;
        }
    }
    
    global class FlowInputs{
        @InvocableVariable(label = 'Record Id' required=true)
        global Id sobjectRecordId;
        @InvocableVariable(label = 'Survey Runner Name' required=true)
        global String surveyRunnerName;
    }
    
}