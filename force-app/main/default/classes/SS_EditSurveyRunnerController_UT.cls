@isTest(SeeAllData=false)
public  class SS_EditSurveyRunnerController_UT {



    @TestSetup
    static void makeData(){
        //create survey
        SSPR__SS_Survey__c sur = new SSPR__SS_Survey__c();
        sur.Name            = 'Test Survey';
        sur.SSPR__SS_Survey_Id__c = '729';
        insert sur;

        SSPR__SS_Survey_Share_Type__c ss = new SSPR__SS_Survey_Share_Type__c();
        ss.SSPR__SS_Name__c  = 'Testingsushare';
        ss.SSPR__SS_External_Id__c = '799';
        ss.SSPR__SS_Share_Type__c  = 'EMAIL';
        ss.SSPR__SS_Survey__c  = sur.Id;

        insert ss;

        //create surveyRunner
        SSPR__SS_SurveySparrow_Runner__c sst = new SSPR__SS_SurveySparrow_Runner__c();

        sst.Name = 'Testing Record';
        sst.SSPR__SS_Description__c = 'descriptionTest';
        sst.SSPR__SS_Object_Name__c = 'case';
        sst.SSPR__SS_Object_Fields_Name__c = 'Name,';
        
        sst.SSPR__SS_Send_Survey_Via__c     = 'EMAIL';
        sst.SSPR__SS_Rate_your_latest_interaction__c = 'Testing interation';
        sst.SSPR__SS_Additional_Comments__c           =  'testing Comments';
        sst.SSPR__SS_Send_Survey_to__c = 'Phone';
        sst.SSPR__SS_Survey__c    = sur.Id;
        sst.SSPR__SS_Lookup_Relationship_Enabled__c     = true;

        insert sst;
    }

    
    @isTest
    static void testgetSurveyRunnerRecord(){

        SSPR__SS_SurveySparrow_Runner__c surveyRunnerRecord = [select Id,SSPR__SS_Object_Name__c from SSPR__SS_SurveySparrow_Runner__c limit 1];

        Test.startTest();

        EditObjectWrapperClass editSurveyRecord =  SS_EditSurveyRunnerController.getSurveyRunnerRecord(surveyRunnerRecord.Id);
         
        //change object Name
        
        surveyRunnerRecord.SSPR__SS_Send_Survey_Via__c = 'SMS';

        update surveyRunnerRecord;

        EditObjectWrapperClass editSurveyRecordObjectName =  SS_EditSurveyRunnerController.getSurveyRunnerRecord(surveyRunnerRecord.Id);
        
        SSPR__SS_SurveySparrow_Runner__c runnerRecord	= [select SSPR__SS_Send_Survey_Via__c from SSPR__SS_SurveySparrow_Runner__c where Id =: surveyRunnerRecord.Id];
        
         system.assertEquals('SMS', runnerRecord.SSPR__SS_Send_Survey_Via__c);
        Test.stopTest();


    }

    //get the Selected objectFields and via Type Object Fields
    @isTest
    static void testgetObjectFields(){
        
        String objName   = 'case';
        String emailType = 'EMAIL';
        String smsType   = 'SMS';
        Test.startTest();

        List<String> getSelectedEmailTypeFieldsList = SS_EditSurveyRunnerController.getSurveyViaTypeFields(objName,emailType);
        List<String> getSelectedSMSTypeFieldsList   = SS_EditSurveyRunnerController.getSurveyViaTypeFields(objName,smsType);
        system.assertEquals(true,getSelectedSMSTypeFieldsList.size() != null);

        Test.stopTest();
    }

    @isTest
    static void testUpdateSurveyRunner(){

        
        EditObjectWrapperClass surveyRunnerWrapper = new EditObjectWrapperClass();

        surveyRunnerWrapper.runnerName          = 'testRunner';
        surveyRunnerWrapper.description         = 'Testing description';
        surveyRunnerWrapper.selectedObject      = 'Account';
        surveyRunnerWrapper.sendSurveyFields    = 'testing';
        surveyRunnerWrapper.additionalComField  = 'objectField';
        surveyRunnerWrapper.rateField           = 'objectRateField';
        surveyRunnerWrapper.sendSurveyType      = 'SMS';
        surveyRunnerWrapper.seletedSurveyName   = '729';
        surveyRunnerWrapper.objectLookUpField   = 'surveyLookUpField';

        //sobjectFieldsLsit
        List<String> objectFieldStringList = new List<String>{'Name','AssetId'};

        List<String> oldFieldStringList = new List<String>{'Name'};
            
        //objectLookUp
        Boolean lookup = true;

        SSPR__SS_SurveySparrow_Runner__c surveyRunnerRecord = [select Id,SSPR__SS_Object_Name__c from SSPR__SS_SurveySparrow_Runner__c limit 1];

        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new SS_TestMockForTriggerLigthningHTTP_UT()); 
        SS_EditSurveyRunnerController.updateSurveyRunnerHandle(surveyRunnerWrapper,objectFieldStringList,lookup,surveyRunnerRecord.Id,oldFieldStringList);
        system.assertEquals('case', surveyRunnerRecord.SSPR__SS_Object_Name__c);
        Test.stopTest();

    }
    
    @isTest
    static void getsurveyShareType(){

        List<SSPR__SS_Survey__c> surveyInsertList = new List<SSPR__SS_Survey__c>();
        
        SSPR__SS_Survey__c survey = new SSPR__SS_Survey__c(Name = 'Test 1',SSPR__SS_survey_Type__c = 'NPS',SSPR__SS_Survey_Id__c = '789');

        surveyInsertList.add(survey);

        SSPR__SS_Survey__c survey1 = new SSPR__SS_Survey__c(Name = 'Test33',SSPR__SS_survey_Type__c = 'CSAT',SSPR__SS_Survey_Id__c = '579');
        surveyInsertList.add(survey1);

        insert    surveyInsertList; 



       
    
        SSPR__SS_Survey_Share_Type__c sst = new SSPR__SS_Survey_Share_Type__c();
        sst.SSPR__SS_Name__c  = 'TestingShare';
        sst.SSPR__SS_External_Id__c = '789';
        sst.SSPR__SS_Share_Type__c  = 'EMAIL';
        sst.SSPR__SS_Status__c = true;
        sst.SSPR__SS_Survey__c  = survey.Id;

        SSPR__SS_Survey_Share_Type__c sst1 = new SSPR__SS_Survey_Share_Type__c();
        sst1.SSPR__SS_Name__c  = 'TestingShare1';
        sst1.SSPR__SS_External_Id__c = '579';
        sst1.SSPR__SS_Share_Type__c  = 'SMS';
        sst1.SSPR__SS_Status__c = true;
        sst1.SSPR__SS_Survey__c  = survey1.Id;
        
        
        
        SSPR__SS_SurveySparrow_Runner__c ss = new  SSPR__SS_SurveySparrow_Runner__c();
        ss.Name = 'testing SurveyRunner Name';

        

        Test.startTest();
        insert ss;

        insert sst;
        insert sst1;
        
        List<SurveyShareClass> surveyShareCl = SS_EditSurveyRunnerController.getSurveyShareType(' EMAIL ', '789');
        List<SurveyShareClass> surveyShareCl1 = SS_EditSurveyRunnerController.getSurveyShareType(' SMS ', '789');
        List<String> surveyRunnerNameList = SS_EditSurveyRunnerController.getSurveyName();
        
         SSPR__SS_Survey_Share_Type__c surShareList = [select SSPR__SS_External_Id__c from SSPR__SS_Survey_Share_Type__c where Id=:sst1.Id];
        system.assertEquals('579', surShareList.SSPR__SS_External_Id__c);
        Test.StopTest();
    }
    
}