/***********************************************************************************
*@CLASS: SS_SurveyIntegrationManagerClass_UT
*@Source Class: SS_SurveyIntegrationManagerClass 
*-----------------------------------------------------------------------------------
* DEVELOPER                  DATE (MM/DD/YYYY)     REASON
*------------------------------------------------------------------------------------
* Sugumar                    01/05/2022             Created
*************************************************************************************/
@isTest(SeeALLData=false)
public class SS_SurveyIntegrationManagerClass_UT  {
    
    @TestSetup
    static void makeData(){
        SSPR__SS_Manage_SurveySparrow_Integration__c s = new SSPR__SS_Manage_SurveySparrow_Integration__c();
        s.SSPR__Is_surveysparrow_Active__c = false;
        s.SSPR__Is_thrivesparrow_Active__c = true;
        
        insert s;
        Cache.Org.put('local.AccessTokenValue.accessToken','testAccessToken');
    }
    
    @isTest
    static void testClassicSurveyEmail(){
        SSPR__SS_Survey__c survey = new SSPR__SS_Survey__c();
        survey.Name = 'testSurvey';
        survey.SSPR__SS_Survey_Type__c = 'Classic';
        survey.SSPR__SS_Survey_Id__c = '724';   
        insert survey;
        
        SSPR__SS_SurveySparrow_Runner__c ss = new SSPR__SS_SurveySparrow_Runner__c();
        ss.Name = 'testWorkOrder';
        ss.SSPR__SS_Object_Name__c = 'Contact';
        ss.SSPR__SS_Send_Survey_Via__c = 'EMAIL';
        ss.SSPR__SS_Object_Fields_Name__c = 'Phone,Email';
        ss.SSPR__SS_Send_Survey_to__c  = 'Email';
        ss.SSPR__SS_Survey__c = survey.Id;
        
        insert ss;
        
        Contact con = new Contact();
        con.LastName = 'Testing';
        con.Phone = '+9170104101';
        con.Email = 'testing@bot.com';
        
        
        
        test.startTest();
        insert con;
        List<SS_SurveyIntegrationManagerClass.FlowInputs> flowInputList = new List<SS_SurveyIntegrationManagerClass.FlowInputs>();
        
        SS_SurveyIntegrationManagerClass.FlowInputs flowInput = new SS_SurveyIntegrationManagerClass.FlowInputs();
        flowInput.sobjectRecordId = con.Id;
        flowInput.surveyRunnerName = 'testWorkOrder';
        
        flowInputList.add(flowInput);
        Test.setMock(HttpCalloutMock.class, new SS_TestMockHttResponse()); 
        SS_SurveyIntegrationManagerClass.sparrowIntegration(flowInputList);
        system.assertEquals('testing@bot.com', con.Email);
        test.stopTest();
        
    }
    
    @isTest
    static void testNPSSurveyEmail(){
        SSPR__SS_Survey__c survey = new SSPR__SS_Survey__c();
        survey.Name = 'testSurvey';
        survey.SSPR__SS_Survey_Type__c = 'NPS';
        survey.SSPR__SS_Survey_Id__c = '724';   
        insert survey;
        
        SSPR__SS_SurveySparrow_Runner__c ss = new SSPR__SS_SurveySparrow_Runner__c();
        ss.Name = 'testWorkOrder';
        ss.SSPR__SS_Object_Name__c = 'Contact';
        ss.SSPR__SS_Send_Survey_Via__c = 'EMAIL';
        ss.SSPR__SS_Send_Survey_to__c  = 'Email';
        ss.SSPR__SS_Survey__c = survey.Id;
        
        
        insert ss;
        
        Contact con = new Contact();
        con.LastName = 'Testing';
        con.Phone = '+9170104101';
        con.Email = 'testing@bot.com';
        
        
        
        test.startTest();
        insert con;
        List<SS_SurveyIntegrationManagerClass.FlowInputs> flowInputList = new List<SS_SurveyIntegrationManagerClass.FlowInputs>();
        
        SS_SurveyIntegrationManagerClass.FlowInputs flowInput = new SS_SurveyIntegrationManagerClass.FlowInputs();
        flowInput.sobjectRecordId = con.Id;
        flowInput.surveyRunnerName = 'testWorkOrder';
        
        flowInputList.add(flowInput);
        Test.setMock(HttpCalloutMock.class, new SS_TestMockHttResponse()); 
        SS_SurveyIntegrationManagerClass.sparrowIntegration(flowInputList);
        System.assertEquals('+9170104101',con.Phone );
        
        test.stopTest();
        
    }
    
    @isTest
    static void testClassicSurveySMS(){
        SSPR__SS_Survey__c survey = new SSPR__SS_Survey__c();
        survey.Name = 'testSurvey';
        survey.SSPR__SS_Survey_Type__c = 'Classic';
        survey.SSPR__SS_Survey_Id__c = '724';   
        insert survey;
        
        SSPR__SS_SurveySparrow_Runner__c ss = new SSPR__SS_SurveySparrow_Runner__c();
        ss.Name = 'testWorkOrder';
        ss.SSPR__SS_Object_Name__c = 'Contact';
        ss.SSPR__SS_Send_Survey_Via__c = 'SMS';
        ss.SSPR__SS_Send_Survey_to__c  = 'Phone';
        ss.SSPR__SS_Survey__c = survey.Id;
        
        insert ss;
        
        Contact con = new Contact();
        con.LastName = 'Testing';
        con.Phone = '+9170104101';
        con.Email = 'testing@bot.com';
        
        
        
        test.startTest();
        insert con;
        List<SS_SurveyIntegrationManagerClass.FlowInputs> flowInputList = new List<SS_SurveyIntegrationManagerClass.FlowInputs>();
        
        SS_SurveyIntegrationManagerClass.FlowInputs flowInput = new SS_SurveyIntegrationManagerClass.FlowInputs();
        flowInput.sobjectRecordId = con.Id;
        flowInput.surveyRunnerName = 'testWorkOrder';
        
        flowInputList.add(flowInput);
        Test.setMock(HttpCalloutMock.class, new SS_TestMockHttResponse()); 
        
        SS_SurveyIntegrationManagerClass.sparrowIntegration(flowInputList);
        List<SSPR__SS_SurveySparrow_Runner__c> sr = [select Id from SSPR__SS_SurveySparrow_Runner__c];
        system.assertEquals(1, sr.size());
       
        test.stopTest();
        
    }
    
    @isTest
    static void testNPSSurveySMS(){
        SSPR__SS_Survey__c survey = new SSPR__SS_Survey__c();
        survey.Name = 'testSurvey';
        survey.SSPR__SS_Survey_Type__c = 'NPS';
        survey.SSPR__SS_Survey_Id__c = '724';   
        insert survey;
        
        SSPR__SS_SurveySparrow_Runner__c ss = new SSPR__SS_SurveySparrow_Runner__c();
        ss.Name = 'testWorkOrder';
        ss.SSPR__SS_Object_Name__c = 'Contact';
        ss.SSPR__SS_Send_Survey_Via__c = 'SMS';
        ss.SSPR__SS_Send_Survey_to__c  = 'Phone';
        ss.SSPR__SS_Survey__c = survey.Id;
        
        insert ss;
        
        Contact con = new Contact();
        con.LastName = 'Testing';
        con.Phone = '+9170104101';
        con.Email = 'testing@bot.com';
        
        test.startTest();
        insert con;
        List<SS_SurveyIntegrationManagerClass.FlowInputs> flowInputList = new List<SS_SurveyIntegrationManagerClass.FlowInputs>();
        
        SS_SurveyIntegrationManagerClass.FlowInputs flowInput = new SS_SurveyIntegrationManagerClass.FlowInputs();
        flowInput.sobjectRecordId = con.Id;
        flowInput.surveyRunnerName = 'testWorkOrder';
        
        flowInputList.add(flowInput);
        Test.setMock(HttpCalloutMock.class, new SS_TestMockHttResponse()); 
        SS_SurveyIntegrationManagerClass.sparrowIntegration(flowInputList);
        system.assertEquals('testing@bot.com', con.Email);
            test.stopTest();
        
    }
    
}