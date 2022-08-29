/***********************************************************************************
*@CLASS: SS_SurveySparrowOAuthController_UT
*@Source Class: SS_SurveySparrowOAuthController
*-----------------------------------------------------------------------------------
* DEVELOPER                   DATE (MM/DD/YYYY)     REASON
*------------------------------------------------------------------------------------
* Sugumar                    01/04/2022             Created
*************************************************************************************/
@isTest(SeeAllData=false)
public class SS_SurveySparrowOAuthController_UT {
    
    @isTest
    static void testAuthStep1(){
        SSPR__SS_SurveySparrow_OAuth_Manager__c Oaconnect = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
        Oaconnect.SSPR__SS_Refresh_Token__c = 'testingPurpose';
        insert Oaconnect;
        
        test.startTest();
        SS_SurveySparrowOAuthController surveyOauthController = new SS_SurveySparrowOAuthController();
        pagereference pp = surveyOauthController.auth_Step_1();
        system.assertEquals('testingPurpose', Oaconnect.SSPR__SS_Refresh_Token__c);
        test.stopTest();
    }
    
    @isTest
    static void testAuthStepWithCode(){
        
        SSPR__SS_SurveySparrow_OAuth_Manager__c Oaconnect = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
        Oaconnect.SSPR__SS_Refresh_Token__c = 'testingPurpose';
        insert Oaconnect;
        
        ApexPages.currentPage().getParameters().put('code','22');
        test.startTest();
        SS_SurveySparrowOAuthController surveyOauthController = new SS_SurveySparrowOAuthController();
        pagereference pp = surveyOauthController.auth_Step_1();
        system.assertEquals('testingPurpose', Oaconnect.SSPR__SS_Refresh_Token__c);
        test.stopTest();
    }
}