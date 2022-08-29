@isTest
public class SS_AccessTokenRequest_UT{

    @isTest static void testAccessTokenRequest(){
        
        SSPR__SS_SurveySparrow_OAuth_Manager__c oauth = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
        oauth.Name = 'Test Refresh Token';
        oauth.SSPR__SS_Refresh_Token__c  = 'Test Refresh Token';
        insert oauth;
        
        SSPR__SS_Manage_SurveySparrow_Integration__c  intTrac = new SSPR__SS_Manage_SurveySparrow_Integration__c();
        intTrac.Name = 'Test';
        intTrac.SSPR__Is_thrivesparrow_Active__c = true;
        insert intTrac;
        
        Test.startTest();
        SS_AccessTokenRequest req = new SS_AccessTokenRequest();
        
        req.getAccessToken();
        system.assertEquals('accessToken',req.getAccessToken());
        Test.stopTest();
    
    }
}