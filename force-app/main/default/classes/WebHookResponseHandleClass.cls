/***********************************************************************************
*@CLASS: SS_SurveySyWebHookResponseHandleClassncManager
*@Test Class: WebHookResponseHandleClass_UT
*@DESCRIPTION: This Class used to take incomming requestion from Survey Sparrow to Create Response and Answer records
*-----------------------------------------------------------------------------------
* DEVELOPER                   DATE                  REASON
*------------------------------------------------------------------------------------
* Sugumar                    2021-12-16              Created
* **********************************************************************************/

@RestResource(urlMapping='/api/Webhooks/incoming/SurveyResponse/*')
global class WebHookResponseHandleClass {
    
    global Static String jsonBody = '';
    /***********************************************************************************
* @Method Name: handleNotification
* @Description: This method handles incoming POST requests
* ***********************************************************************************/
    @HttpPost
    global static void handleNotification(){
        //Request
        RestRequest resquest = RestContext.request;
        
        system.debug('--------user info--'+UserInfo.getUserName());
        //get Body
        Blob requestBodyType = resquest.requestBody;
        
        Map<String,Object>  responseMap =  (Map<String,Object>) JSON.deserializeUntyped(requestBodyType.toString());
        jsonBody = requestBodyType.toString();
        if(jsonBody.length() > 131072){
            jsonBody = jsonBody.substring(0,131072);
        }
        
        SSPR__SS_Integration_Tracking__c integrationTrack = new SSPR__SS_Integration_Tracking__c();
        integrationTrack.SSPR__Interface_Type__c = 'Inbound';
        
        integrationTrack.SSPR__SS_Request_Body__c   =  jsonBody;
        insert integrationTrack;
        try{
            //Check the survey is CSAT or NPS
            if(responseMap.get('surveyName') != null && responseMap.get('submission') != null){
                //CSAT Survey
                handleCSATResponse(responseMap);
                
            }else if(responseMap.get('nps_channel_id') != null && responseMap.get('answers') != null){
                //NPS Survey
                handleNPSResponse(responseMap);
            }
        } Catch(Exception exe){
                
                SSPR__SS_Integration_Tracking__c integrationTrack1 = new SSPR__SS_Integration_Tracking__c();
                integrationTrack1.SSPR__Interface_Type__c = 'Inbound';
                
                integrationTrack1.SSPR__SS_Request_Body__c   =  exe.getMessage()+'--'+exe.getCause()+'--'+exe.getLineNumber();
                insert integrationTrack1;
            }
        }
        
        /***********************************************************************************
* @Method Name: handleCSATResponse
* @Description: Create Feedback Response records and Anwser records from CSAT Response
* ***********************************************************************************/
        global static void handleCSATResponse(Map<String,Object>  responseMap){
            
            Map<String, SSPR__SS_Question__c> questionMap = new Map<String, SSPR__SS_Question__c>();
            Map<String, Object> submissionMap = (Map<String, Object>)responseMap.get('submission');
            String surveyId = String.valueOf(submissionMap.get('survey_id'));
            String state = String.valueOf(submissionMap.get('state'));
            String submissionId = String.valueOf(submissionMap.get('id'));
            Set<String> answeredQuestions = new Set<String>();
            
            List<SSPR__SS_Survey__c> surveyList = [SELECT Id ,(SELECT Id,SSPR__SS_Question_Id__c,SSPR__SS_Question__c FROM Questions__r) FROM SSPR__SS_Survey__c WHERE SSPR__SS_Survey_Id__c =: surveyId];
            if(surveyList == null || surveyList.isEmpty()){
                return;
            }
            
            SSPR__SS_Survey__c survey = surveyList[0];
            for(SSPR__SS_Question__c q : survey.Questions__r){
                questionMap.put(q.SSPR__SS_Question_Id__c, q);
            }
            System.debug('questionMap  '+questionMap);
            //Create Survey Response Feedback instance 
            SSPR__SS_Survey_Response_Feedback__c feedRes = new SSPR__SS_Survey_Response_Feedback__c();
            feedRes.SSPR__SS_Survey_Id__c   = surveyId;
            feedRes.SSPR__SS_Survey__c      = survey.Id;
            feedRes.SSPR__SS_Answer_Text__c = jsonBody;
            feedRes.SSPR__SS_Response_Id__c = submissionId;
            feedRes.SSPR__Response_Type__c  = String.valueOf(submissionMap.get('channel_type'));
            feedRes.SSPR__SS_Completed_DateTime__c = System.now();
            feedRes.SSPR__SS_Create_DateTime__c    = System.now();
            feedRes.SSPR__SS_Contact_Id__c = String.valueOf(submissionMap.get('contact_id'));
            feedRes.SSPR__SS_Feedback__c   = String.valueOf(submissionMap.get('feedback'));
            feedRes.SSPR__SS_Response_Id__c = submissionId;
            feedRes.SSPR__SS_State__c = state;
            insert feedRes;
            
            List<Object> answersList = (List<Object>)submissionMap.get('answers'); 
            List<Object> questionsList = (List<Object>)responseMap.get('questions');
            List<SSPR__SS_Answer__c> answerListtoinsert = new List<SSPR__SS_Answer__c>();
            
            Id sobjectId = null;
            Id surveyRunnerId = null;
            
            for(Object ansObj : answersList){
                
                Map<String,Object> ansMap = ( Map<String,Object>)ansObj;
                String questionId = ansMap.get('question_id') + '';
                
                if(questionId == 'custom_param_SobjectRecordId'){
                    sobjectId = Id.valueOf(String.valueOf(ansMap.get('answer')));
                    String sObjName = sObjectId.getSObjectType().getDescribe().getName();
                }
                
                if(questionId == 'custom_param_SurveyRunnerId'){
                    surveyRunnerId = Id.valueOf(String.valueOf(ansMap.get('answer')));
                }
            }
            
            String relationShipFieldName = null;
            
            if(surveyRunnerId != null){
                for(SSPR__SS_SurveySparrow_Runner__c ssr :[select Id,SSPR__SS_Lookup_Relationship_Field__c from SSPR__SS_SurveySparrow_Runner__c where Id=:surveyRunnerId]){
                    if(ssr.SSPR__SS_Lookup_Relationship_Field__c != null && String.isNotBlank(ssr.SSPR__SS_Lookup_Relationship_Field__c)){
                        relationShipFieldName = ssr.SSPR__SS_Lookup_Relationship_Field__c;
                    }
                    
                }
            }
            
            //Iterate all the Answers from the response
            for(Object ansObj : answersList){
                
                Map<String,Object> ansMap = ( Map<String,Object>)ansObj;
                String questionId = ansMap.get('question_id') + '';
                
                
                if( questionId.isNumeric() && questionMap.get(questionId) != null){
                    answeredQuestions.add(questionId);
                    
                    //Create Answer instance
                    SSPR__SS_Answer__c  ans = new SSPR__SS_Answer__c();
                    ans.SSPR__SS_Question_Id__c =questionId;
                    if(relationShipFieldName != null && String.isNotBlank(relationShipFieldName) && sobjectId != null){
                        ans.put(relationShipFieldName,sobjectId);
                    }
                    ans.SSPR__SS_Parent_Question__c = questionMap.get(questionId).Id;
                    ans.SSPR__SS_Question__c  = questionMap.get(questionId).SSPR__SS_Question__c;
                    if(String.valueOf(ansMap.get('answer')) != '()'){
                        ans.SSPR__SS_Answer__c = String.valueOf(ansMap.get('answer'));
                    }else{
                        ans.SSPR__SS_Answer__c = '';
                    }
                    
                    ans.SSPR__SS_Submission_Id__c = feedRes.Id;
                    
                    
                    answerListtoinsert.add(ans);
                    
                }
            }
            System.debug('questionsList---'+questionsList);
            //Create Empty Answer records for skipped question.
            for(Object quesObj : questionsList){
                
                Map<String,Object> quesMap = ( Map<String,Object>)quesObj;
                String questionId = quesMap.get('id') + '';
                System.debug('questionId  '+questionId);
                System.debug('questionMap.get(questionId)  '+questionMap.get(questionId));
                System.debug('answeredQuestions '+answeredQuestions);
                System.debug('questionId  '+!answeredQuestions.contains(questionId));
                if( questionId.isNumeric() && questionMap.get(questionId) != null && !answeredQuestions.contains(questionId)){
                    
                    //Create Answer instance
                    SSPR__SS_Answer__c  ans = new SSPR__SS_Answer__c();
                    ans.SSPR__SS_Question_Id__c =questionId;
                    if(relationShipFieldName != null && String.isNotBlank(relationShipFieldName) && sobjectId != null){
                        ans.put(relationShipFieldName,sobjectId);
                    }
                    ans.SSPR__SS_Parent_Question__c = questionMap.get(questionId).Id;
                    ans.SSPR__SS_Question__c  = questionMap.get(questionId).SSPR__SS_Question__c;
                    ans.SSPR__SS_Answer__c = '';
                    ans.SSPR__SS_Submission_Id__c = feedRes.Id;
                    answerListtoinsert.add(ans);
                }
            }
            
            
            
            //Insert Answer records
            if(answerListtoinsert != null && !answerListtoinsert.isEmpty()){
                List<Database.SaveResult> saveRes = Database.insert(answerListtoinsert);
            }
        }
        
        /***********************************************************************************
* @Method Name: handleNPSResponse
* @Description: Create Feedback Response records and Anwser records from NPS Response
* ***********************************************************************************/
        global static void handleNPSResponse(Map<String,Object>  responseMap){
            
            Map<String, SSPR__SS_Question__c> questionMap = new Map<String, SSPR__SS_Question__c>();
            String surveyId = String.valueOf(responseMap.get('survey_id'));
            //getting score and FeedBackValue
            Decimal score   = Decimal.valueOf(String.valueOf(responseMap.get('score')));
            String feedBackValue = String.valueOf(responseMap.get('feedback'));
            
            String state    = String.valueOf(responseMap.get('state'));
            String submissionId = String.valueOf(responseMap.get('id'));
            
            Map<String,Object> customPropertiesMap = (Map<String,Object>)responseMap.get('customProperties');
            Id sobjectId = Id.valueOf(String.valueOf(customPropertiesMap.get('SobjectRecordId')));
            String sObjName = sObjectId.getSObjectType().getDescribe().getName();
            Id surveyRunnerId = Id.valueOf(String.valueOf(customPropertiesMap.get('SurveyRunnerId')));
            Set<String> answeredQuestions = new Set<String>();
            
            String relationShipFieldName = null;
            List<sObject> sobjectValueList = new List<sObject>();
            
            if(surveyRunnerId != null){
                for(SSPR__SS_SurveySparrow_Runner__c ssr :[select Id,SSPR__SS_Lookup_Relationship_Field__c,SSPR__SS_Lookup_Relationship_Enabled__c,
                                                           SSPR__SS_Rate_your_latest_interaction__c,SSPR__SS_Additional_Comments__c
                                                           from SSPR__SS_SurveySparrow_Runner__c where Id=:surveyRunnerId])
                {
                    if(ssr.SSPR__SS_Lookup_Relationship_Field__c != null && String.isNotBlank(ssr.SSPR__SS_Lookup_Relationship_Field__c) 
                       && ssr.SSPR__SS_Lookup_Relationship_Enabled__c == true){
                           relationShipFieldName = ssr.SSPR__SS_Lookup_Relationship_Field__c;
                       }
                    
                    sObject sObj = Schema.getGlobalDescribe().get(sObjName).newSObject() ;
                    sObj.Id = sobjectId;
                    if(ssr.SSPR__SS_Rate_your_latest_interaction__c != null ){
                        sObj.put(ssr.SSPR__SS_Rate_your_latest_interaction__c,String.valueof(score));
                    }
                    
                    if( ssr.SSPR__SS_Additional_Comments__c != null ){
                        sObj.put(ssr.SSPR__SS_Additional_Comments__c,feedBackValue);
                    }
                    
                    sobjectValueList.add(sObj);
                    
                }
            }
            
            if(!sobjectValueList.isEmpty()){
                update sobjectValueList;
            }
            
            List<SSPR__SS_Survey__c> surveyList = [SELECT Id ,(SELECT Id,SSPR__SS_Question_Id__c,SSPR__SS_Question__c FROM Questions__r) FROM SSPR__SS_Survey__c WHERE SSPR__SS_Survey_Id__c =: surveyId];
            if(surveyList == null || surveyList.isEmpty()){
                return;
            }
            
            SSPR__SS_Survey__c survey = surveyList[0];
            for(SSPR__SS_Question__c q : survey.Questions__r){
                questionMap.put(q.SSPR__SS_Question_Id__c, q);
            }
            
            //Create Survey Response Feedback instance 
            SSPR__SS_Survey_Response_Feedback__c feedRes = new SSPR__SS_Survey_Response_Feedback__c();
            feedRes.SSPR__SS_Survey_Id__c   = surveyId;
            feedRes.SSPR__SS_Survey__c      = survey.Id;
            feedRes.SSPR__SS_Answer_Text__c = jsonBody;
            feedRes.SSPR__SS_Response_Id__c = submissionId;
            feedRes.SSPR__SS_Completed_DateTime__c = System.now();
            feedRes.SSPR__SS_Create_DateTime__c    = System.now();
            feedRes.SSPR__Response_Type__c  = String.valueOf(responseMap.get('channel_type'));
            feedRes.SSPR__SS_Contact_Id__c  = String.valueOf(responseMap.get('contact_id'));
            feedRes.SSPR__SS_Feedback__c    = String.valueOf(responseMap.get('feedback')); 
            feedRes.SSPR__SS_Sentiment__c   = String.valueOf(responseMap.get('sentiment'));
            feedRes.SSPR__SS_Response_Id__c = submissionId;
            feedRes.SSPR__SS_State__c = state;
            insert feedRes;
            
            List<Object> answersList = (List<Object>)responseMap.get('answers');
            List<SSPR__SS_Answer__c> answerListtoinsert = new List<SSPR__SS_Answer__c>();
            
            //Iterate all the Answers from the response
            for(Object ansObj : answersList){
                
                Map<String,Object> ansMap = ( Map<String,Object>)ansObj;
                String questionId = String.valueOf(ansMap.get('question_id'));
                
                if(questionId.isNumeric() && questionMap.get(questionId) != null){
                    
                    answeredQuestions.add(questionId);
                    
                    //Create Answer instance
                    SSPR__SS_Answer__c  ans = new SSPR__SS_Answer__c();
                    ans.SSPR__SS_Question_Id__c =questionId;
                    if(relationShipFieldName != null && String.isNotBlank(relationShipFieldName) && sobjectId != null){
                        ans.put(relationShipFieldName,sobjectId);
                    }
                    ans.SSPR__SS_Parent_Question__c = questionMap.get(questionId).Id;
                    ans.SSPR__SS_Question__c  = questionMap.get(questionId).SSPR__SS_Question__c;
                    if(String.valueOf(ansMap.get('answer')) != '()'){
                        ans.SSPR__SS_Answer__c = String.valueOf(ansMap.get('answer'));
                    }else{
                        ans.SSPR__SS_Answer__c = '';
                    }
                    
                    ans.SSPR__SS_Submission_Id__c = feedRes.Id;
                    answerListtoinsert.add(ans);
                }
            }
            
            for(String quesId : questionMap.keySet()){
                
                if(!answeredQuestions.contains(quesId)){
                    
                    //Create Answer instance
                    SSPR__SS_Answer__c  ans = new SSPR__SS_Answer__c();
                    ans.SSPR__SS_Question_Id__c =quesId;
                    if(relationShipFieldName != null && String.isNotBlank(relationShipFieldName) && sobjectId != null){
                        ans.put(relationShipFieldName,sobjectId);
                    }
                    ans.SSPR__SS_Parent_Question__c = questionMap.get(quesId).Id;
                    ans.SSPR__SS_Question__c  = questionMap.get(quesId).SSPR__SS_Question__c;
                    ans.SSPR__SS_Answer__c = '';
                    ans.SSPR__SS_Submission_Id__c = feedRes.Id;
                    answerListtoinsert.add(ans);
                }
            }
            
            //Insert Answer records
            if(answerListtoinsert != null && !answerListtoinsert.isEmpty()){
                List<Database.SaveResult> saveRes = Database.insert(answerListtoinsert);
            }
            
        }
        
    }