@isTest(SeeAllData=false)
public class SS_DisconnectSurveyOnUninstall_UT {
    
    @isTest
    static void testUninstallScript() {
        
        SSPR__SS_Manage_SurveySparrow_Integration__c msI = new SSPR__SS_Manage_SurveySparrow_Integration__c();
        msI.SSPR__Is_surveysparrow_Active__c = true;
        msI.SSPR__Is_thrivesparrow_Active__c = false;
        
        insert msI;
        
        
        SSPR__SS_Survey__c sur1 = new SSPR__SS_Survey__c();
        sur1.SSPR__SS_Webhook_Id__c = '111';
        
        
        
        //insert surveyList
        insert sur1;
        
        SSPR__SS_SurveySparrow_OAuth_Manager__c oauth = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
        oauth.SSPR__SS_Refresh_Token__c = '9ssudhTYUV908uJoNSBJyIponPk';
        
        insert oauth;
        
        Test.setMock(HttpCalloutMock.class, new SS_TestMockHttResponse()); 
       
        Test.startTest();
        
        
        Test.testUninstall(new SS_HandleOnUninstallPackage());
        
        Test.stopTest();
        
    }
    
    
    
}