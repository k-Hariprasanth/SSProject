@isTest(SeeAllData=false)
public with sharing class SS_SurveyRunnerSetupController_UT {
    
    @isTest
    static void testSurveyConnectFalse(){
        
        Test.StartTest();
        Boolean isConnect = SS_SurveyRunnerSetupController.isSurveyConnect();
        Test.StopTest();
    }
    
    @isTest
    static void testSurveyConnect(){
        SSPR__SS_SurveySparrow_OAuth_Manager__c surveyOAuth = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
        surveyOAuth.SSPR__SS_Refresh_Token__c  = 'XyIo983BBmoLPWBISl';
        surveyOAuth.SSPR__SS_is_Refresh_Token_Valid__c = true;
        
        Test.StartTest();
        
        insert surveyOAuth;
        
        Boolean isConnect = SS_SurveyRunnerSetupController.isSurveyConnect();
        SSPR__SS_SurveySparrow_OAuth_Manager__c ss  = [select SSPR__SS_is_Refresh_Token_Valid__c from SSPR__SS_SurveySparrow_OAuth_Manager__c limit 1];
        system.assertEquals(true,ss.SSPR__SS_is_Refresh_Token_Valid__c);
        Test.StopTest();
    }
    
    @isTest
    static void testDeleteSurveyConnect(){
        
        SSPR__SS_SurveySparrow_OAuth_Manager__c surveyOAuth = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
        surveyOAuth.SSPR__SS_Refresh_Token__c  = 'XyIo983BBmoLPWBISl';
        surveyOAuth.SS_is_Refresh_Token_Valid__c = true;
        
        Test.StartTest();
        
        insert surveyOAuth;
        
        SS_SurveyRunnerSetupController.disConnectSurvey();
        List<SSPR__SS_SurveySparrow_OAuth_Manager__c> ss  = [select Id,SSPR__SS_is_Refresh_Token_Valid__c from SSPR__SS_SurveySparrow_OAuth_Manager__c ];
        system.assertEquals(1,ss.size());
        Test.StopTest();
    }
    
    @isTest
    static void testgetDataChoosenValue(){
        SSPR__SS_Manage_SurveySparrow_Integration__c ms = new SSPR__SS_Manage_SurveySparrow_Integration__c();
        ms.SSPR__Is_surveysparrow_Active__c = true;
        ms.SSPR__Is_thrivesparrow_Active__c = false;
        
        insert ms;
        
        Test.startTest();
        
        String returnChooseValue = SS_SurveyRunnerSetupController.getDataChoosenValue();
        SS_SurveyRunnerSetupController.updateSurveyOAuthUrl('surveysparrow.com');
        SS_SurveyRunnerSetupController.updateSurveyOAuthUrl('thrivesparrow.com');
        Test.stopTest();
    }
}