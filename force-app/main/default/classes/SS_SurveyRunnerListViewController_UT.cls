@isTest(SeeAllData=False)
public with sharing class SS_SurveyRunnerListViewController_UT {
    
    @isTest
    static void testGetSurveyRunnerRecord(){
        
        SSPR__SS_SurveySparrow_Runner__c sr = new SSPR__SS_SurveySparrow_Runner__c();
        sr.Name  = 'Testing Runner';
        sr.SSPR__SS_Object_Name__c = 'Case';

        Test.StartTest();

        insert sr;
        List<SSPR__SS_SurveySparrow_Runner__c> surveyRunnerList = SS_SurveyRunnerListViewController.getSparrowTriggerRecords();

        system.assertEquals('Testing Runner',surveyRunnerList[0].Name);
        Test.stopTest();
    }

    @isTest
    static void testDeleteSurveyRunner(){

        SSPR__SS_SurveySparrow_Runner__c sr = new SSPR__SS_SurveySparrow_Runner__c();
        sr.Name  = 'Testing Delete Runner';
        sr.SSPR__SS_Object_Name__c = 'Account';

        Test.StartTest();

        insert sr;

        SS_SurveyRunnerListViewController.deleteRunnerHandler(sr.Id);
        
        List<SSPR__SS_SurveySparrow_Runner__c> surveyRunnerList = SS_SurveyRunnerListViewController.getSparrowTriggerRecords();
        system.assertEquals(0,surveyRunnerList.size());
        Test.stopTest();
    }

}