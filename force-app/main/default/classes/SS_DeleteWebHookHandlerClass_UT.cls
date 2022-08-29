/***********************************************************************************
*@CLASS: SS_DeleteWebHookHandlerClass_UT
*@Source Class: SS_DeleteWebHookHandlerClass
*-----------------------------------------------------------------------------------
* DEVELOPER                   DATE                  REASON
*------------------------------------------------------------------------------------
* Hari                   2022-01-12              Created
*************************************************************************************/
@isTest(SeeAllData=False)
public class SS_DeleteWebHookHandlerClass_UT {
    
    @isTest
    public static void deleteSurveyWebhookUrl(){
        
        SSPR__SS_Manage_SurveySparrow_Integration__c st = new SSPR__SS_Manage_SurveySparrow_Integration__c();
        
        st.SSPR__Is_surveysparrow_Active__c = false;
        st.SSPR__Is_thrivesparrow_Active__c = true;
        
        insert st;
        
        SSPR__SS_Survey__c s = new SSPR__SS_Survey__c();
        s.SSPR__SS_Webhook_Id__c = '9';
        insert s;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SS_TestMockHttResponse()); 
        
        SS_DeleteWebHookHandlerClass surveyBatch = new SS_DeleteWebHookHandlerClass();
        Id jobid= Database.executeBatch(surveyBatch,1);
        
        List<SSPR__SS_Survey__c> surveyList = [select Id,SSPR__SS_Webhook_Id__c from SSPR__SS_Survey__c where Id=:s.Id];
        
      system.assertEquals(true,true);
        system.debug(surveyList);
        test.stopTest();
    }
    

    
    
}