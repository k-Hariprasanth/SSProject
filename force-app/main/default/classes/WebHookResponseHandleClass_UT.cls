/***********************************************************************************
 *@CLASS: WebHookResponseHandleClass_UT
 *@Source Class: WebHookResponseHandleClass
 *-----------------------------------------------------------------------------------
 * DEVELOPER                   DATE                  REASON
 *------------------------------------------------------------------------------------
 * Sugumar                    2022-01-10              Created
 * **********************************************************************************/

@isTest
public class WebHookResponseHandleClass_UT {

    @isTest
    static void testHandleNotificationforCSATSurvey(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Webhooks/incoming/SurveyResponse'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        
        String jsonInput = '{'+
            ' "resultLink":"https://bitordertesting.thrivesparrow.com",\n' +
            ' "surveyName": "EmailSurvey",\n' +
            ' "questions":' + ' [{"id":"totalScore", \n' +
            ' "question":"Total Score"}], \n ' +
            ' "submission": ' + '{"contact": null, \n' +
            ' "answers": ' + ' [{"skipped": false, \n' +
            ' "question_id": 7302, \n' +
            ' "question_tags": [], \n' +
            ' "question":"Rate us", \n' +
            ' "step": 10,"answer": 9}, \n'+ 
            ' {"question_id":"totalScore"}], \n'+
            ' "trigger_id":5906, \n' + 
            ' "survey_id":486, \n'+ 
            ' "channel_id":1976, \n' +
            ' "account_id": 97, \n'+
            ' "state":"COMPLETED", \n '+
            ' "id": 5202} \n' +
            '}';
       
        
        
        req.requestBody = Blob.valueof(jsonInput);
        
        SSPR__SS_Survey__c survey = new SSPR__SS_Survey__c();
        survey.SSPR__SS_Survey_Id__c = '486';
        insert survey;
        
        SSPR__SS_Question__c q = new SSPR__SS_Question__c();
        q.SSPR__SS_Question_Id__c = '7302';
        q.SSPR__SS_Question__c = 'testing questions';
        q.SSPR__Survey__c = survey.Id;
        insert q;
               
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WebHookResponseHandleClass.handleNotification();
        system.assertEquals('testing questions',q.SSPR__SS_Question__c);
        Test.stopTest();  
    }
    
    @isTest
    static void testHandleNotificationNPSSurvey(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Webhooks/incoming/SurveyResponse'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        
        String jsonInput = '{'+
            ' "resultLink":"https://bitordertesting.thrivesparrow.com",\n' +
            ' "surveyName": "EmailSurvey",\n' +
            ' "questions":' + ' [{"id":"totalScore", \n' +
            ' "question":"Total Score"}], \n ' +
            ' "account_id": 97, \n'+
            ' "survey_id":486, \n'+ 
            ' "score":4, \n'+ 
            ' "id": 5202, \n' +
            ' "state":"COMPLETED", \n '+
            ' "nps_channel_id":1976, \n' +
            ' "answers": ' + ' [{"skipped": false, \n' +
            ' "question_id": 7302, \n' +
            ' "question_tags": [], \n' +
            ' "question":"Rate us", \n' +
            ' "step": 10,"answer": 9}, \n'+ 
            ' {"question_id":"totalScore"}], \n'+
            ' "submissions": ' + '{"contact": null, \n' +
            ' "answers": ' + ' [{"skipped": false, \n' +
            ' "question_id": 7302, \n' +
            ' "question_tags": [], \n' +
            ' "question":"Rate us", \n' +
            ' "step": 10,"answer": 9}, \n'+ 
            ' {"question_id":"totalScore"}], \n'+
            ' "trigger_id":5906, \n' + 
            ' "survey_id":486, \n'+ 
            ' "channel_id":1976, \n' +
            ' "account_id": 97, \n'+
            ' "state":"COMPLETED", \n '+
            ' "id": 5202}, \n' +
            '  "customProperties": { \n ' +
            ' "SurveyRunnerId": "a0F5g000003qLLdEAM", \n ' +
            '   "SobjectRecordId": "a055g000003pv6xAAA"  } \n ' +
            '}';
        
       
        
        
        req.requestBody = Blob.valueof(jsonInput);
        
        SSPR__SS_Survey__c survey = new SSPR__SS_Survey__c();
        survey.SSPR__SS_Survey_Id__c = '486';
        insert survey;
        
        SSPR__SS_Question__c q = new SSPR__SS_Question__c();
        q.SSPR__SS_Question_Id__c = '7302';
        q.SSPR__SS_Question__c = 'testing questions';
        q.SSPR__Survey__c = survey.Id;
        insert q;
        
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        WebHookResponseHandleClass.handleNotification();
        system.assertEquals('testing questions',q.SSPR__SS_Question__c);
        Test.stopTest();  
    }
}