/***********************************************************************************
*@CLASS: SS_SurveySyncManager_UT
*@Source Class: SS_SurveySyncManager
*-----------------------------------------------------------------------------------
* DEVELOPER                   DATE                  REASON
*------------------------------------------------------------------------------------
* Sugumar                    2022-01-04              Created
*************************************************************************************/
@isTest
public class SS_SurveySyncManager_UT {
    
   
    
    @isTest
    static void testSurveySyncBatchClass(){
        
        SSPR__SS_Manage_SurveySparrow_Integration__c wc = new SSPR__SS_Manage_SurveySparrow_Integration__c();
        wc.SSPR__SS_Webhook_Site_URL__c = 'https://sureveysparrow/testingwebhook/SurveyResponse';
        wc.SSPR__Is_surveysparrow_Active__c = true;
        wc.SSPR__Is_thrivesparrow_Active__c = false;
        
        insert wc;
        
        SSPR__SS_Survey__c s = new SSPR__SS_Survey__c();
        s.Name = 'testing';
        s.SSPR__SS_Is_Active_Survey__c = true;
        insert s;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SS_SurveySyncManager_HTTPTest()); 
        SS_SurveySyncManager surveyBatch = new SS_SurveySyncManager();
        Id jobid= Database.executeBatch(surveyBatch,1);
        system.assertEquals('testing', s.Name);
        Test.stopTest();
    }
    @isTest
    static void testSurveySyncBatchClasswithWebHook(){
        
         SSPR__SS_Manage_SurveySparrow_Integration__c wc = new SSPR__SS_Manage_SurveySparrow_Integration__c();
        wc.SSPR__SS_Webhook_Site_URL__c = 'https://sureveysparrow/testingwebhook/SurveyResponse';
         wc.SSPR__Is_surveysparrow_Active__c = true;
        wc.SSPR__Is_thrivesparrow_Active__c = false;
        
        insert wc;
        
        SSPR__SS_Survey__c s = new SSPR__SS_Survey__c();
        s.Name = 'testing webHook';
        s.SSPR__SS_Webhook_Id__c = '777';
        s.SSPR__SS_Is_Active_Survey__c = true;
        insert s;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SS_SurveySyncManager_HTTPTest()); 
        SS_SurveySyncManager surveyBatch = new SS_SurveySyncManager();
        Id jobid= Database.executeBatch(surveyBatch,1);
        system.assertEquals('testing webHook', s.Name);
        Test.stopTest();
    }
 
}