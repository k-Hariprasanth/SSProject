@isTest(SeeAllData=False)
public with sharing class SS_CreateSurveyRunnerController_UT {
   

    //test getting object Name
    @isTest
    static void testgetObjectandSurvey(){ 


        SSPR__SS_Survey__c sur = new SSPR__SS_Survey__c();
        sur.Name = 'Test Survey';
        sur.SSPR__SS_Survey_Id__c = '301';
        sur.SSPR__SS_Is_Active_Survey__c = true;
        insert sur;

        Test.startTest();

        ObjectWrapperClass getObj = SS_CreateSurveyRunnerController.getObjectAndSurvey();
        List<SSPR__SS_Survey__c> surList = [select Id from SSPR__SS_Survey__c];
        system.assertEquals(1, surList.size());
        Test.stopTest();
    }
    

    //get the Selected objectFields and via Type Object Fields
    @isTest
    static void testgetObjectFields(){
        
        String objName   = 'case';
        String emailType = ' EMAIL ';
        String smsType   = ' SMS ';
        Test.startTest();

        List<SS_CreateSurveyRunnerController.ObjectFieldsClass> getObjFields = SS_CreateSurveyRunnerController.getSelectedObjectFields(objName);
        List<String> getSelectedEmailTypeFieldsList = SS_CreateSurveyRunnerController.getSurveyViaTypeFields(objName,emailType);
        List<String> getSelectedSMSTypeFieldsList   = SS_CreateSurveyRunnerController.getSurveyViaTypeFields(objName,smsType);
        system.assertEquals(true,getSelectedSMSTypeFieldsList.size() != null);
        Test.stopTest();
    }

    @isTest
    static void testObjectRelationLookup(){

        String objName   = 'SSPR__SS_Question__c';

        Test.startTest();
        List<String> objectLookupFieldsList = SS_CreateSurveyRunnerController.getResponseSobjectLookupField(objName);
        SS_CreateSurveyRunnerController.ObjectFieldClass rateFieldsObject = SS_CreateSurveyRunnerController.getRateAndCommentsFields('Account');
        system.assertEquals(true,objectLookupFieldsList.size() != null);
        Test.stopTest();
    }

    @isTest
    static void testInsertSurveyRunner(){

        SSPR__SS_Survey__c sur = new SSPR__SS_Survey__c();
        sur.Name            = 'Test Survey';
        sur.SSPR__SS_Survey_Id__c = '301';
        insert sur;


        //surveyRunner WrapperClass
        ObjectWrapperClass surveyRunnerWrapper = new ObjectWrapperClass();

        surveyRunnerWrapper.runnerName          = 'testRunner';
        surveyRunnerWrapper.description         = 'Testing description';
        surveyRunnerWrapper.selectedObject      = 'case';
        surveyRunnerWrapper.sendSurveyFields    = 'testing';
        surveyRunnerWrapper.additionalComField  = 'objectField';
        surveyRunnerWrapper.rateField           = 'objectRateField';
        surveyRunnerWrapper.sendSurveyType      = 'SMS';
        surveyRunnerWrapper.seletedSurveyName   = '301';
        surveyRunnerWrapper.objectLookUpField   = 'surveyLookUpField';

        //sobjectFieldsLsit
        List<String> objectFieldStringList = new List<String>{'field1','field2','field3','field4'};

        //objectLookUp
        Boolean lookup = true;

        Test.startTest();
         String domainUrl = SS_CreateSurveyRunnerController.createSurveyRunnerHandle(surveyRunnerWrapper,objectFieldStringList,lookup);
        List<SSPR__SS_SurveySparrow_Runner__c> surveyRunnerList = [select Id from SSPR__SS_SurveySparrow_Runner__c];
        system.assertEquals(1,surveyRunnerList.size());  
        Test.stopTest();



    }

    @isTest
    static void pullSurveysfromSurveySparrow_UT(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SS_TestMockForTriggerLigthningHTTP_UT()); 
        SS_CreateSurveyRunnerController.pullSurveysfromSurveySparrow();
        List<SSPR__SS_Survey__c> surList = [select Id from SSPR__SS_Survey__c];
        system.assertEquals(7,surList.size());     
        test.stopTest();
        
    }   

    @isTest
    static void testGetShareTypeandSurveyRunner(){
         List<SSPR__SS_Survey__c> surveyInsertList = new List<SSPR__SS_Survey__c>();
         SSPR__SS_Survey__c survey = new SSPR__SS_Survey__c(Name = 'Test 1',SSPR__SS_survey_Type__c = 'NPS',SSPR__SS_Survey_Id__c = '729');

        surveyInsertList.add(survey);

        SSPR__SS_Survey__c survey1 = new SSPR__SS_Survey__c(Name = 'Test33',SSPR__SS_survey_Type__c = 'CSAT',SSPR__SS_Survey_Id__c = '579');
        surveyInsertList.add(survey1);

        insert    surveyInsertList; 



       
    
        SSPR__SS_Survey_Share_Type__c sst = new SSPR__SS_Survey_Share_Type__c();
        sst.SSPR__SS_Name__c  = 'TestingShare';
        sst.SSPR__SS_External_Id__c = '729';
        sst.SSPR__SS_Share_Type__c  = 'EMAIL';
        sst.SSPR__SS_Survey__c  = survey.Id;

        SSPR__SS_Survey_Share_Type__c sst1 = new SSPR__SS_Survey_Share_Type__c();
        sst1.SSPR__SS_Name__c  = 'TestingShare1';
        sst1.SSPR__SS_External_Id__c = '579';
        sst1.SSPR__SS_Share_Type__c  = 'SMS';
        sst1.SSPR__SS_Survey__c  = survey1.Id;


        SSPR__SS_SurveySparrow_Runner__c ss = new  SSPR__SS_SurveySparrow_Runner__c();
        ss.Name = 'testing SurveyRunner Name';

        

        Test.startTest();
        insert ss;
        insert sst;
        insert sst1;

        List<SS_CreateSurveyRunnerController.SurveyShareClass> shareTypeEMAIL = SS_CreateSurveyRunnerController.getSurveyShareType(' EMAIL ','729');
        List<SS_CreateSurveyRunnerController.SurveyShareClass> shareTypeSMS = SS_CreateSurveyRunnerController.getSurveyShareType(' SMS ','729');
        List<String> surveyRunnerNameList = SS_CreateSurveyRunnerController.getSurveyName();
        
         List<SSPR__SS_Survey_Share_Type__c> surShareList = [select SSPR__SS_External_Id__c from SSPR__SS_Survey_Share_Type__c];
        system.assertEquals('729', surShareList[0].SSPR__SS_External_Id__c);
        Test.StopTest();
    }
}