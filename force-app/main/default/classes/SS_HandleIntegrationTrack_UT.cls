@isTest(SeeAllData=false)
public class SS_HandleIntegrationTrack_UT {

  @isTest
  static void testUpdateOauth(){

    SSPR__SS_SurveySparrow_OAuth_Manager__c oa = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
    oa.SSPR__SS_is_Refresh_Token_Valid__c = true;

    insert oa;
       
    Test.startTest();
    SS_HandleIntegrationTrack.updateSurveyOauth();
    
    Test.StopTest();
  }

  @isTest
  static void testCreateIntegratTrack(){
    SSPR__SS_Manage_SurveySparrow_Integration__c it = new SSPR__SS_Manage_SurveySparrow_Integration__c();
    it.SSPR__SS_Enable_SurveySparrow_Integration__c = true;

    insert it;
    test.startTest();
      Boolean track =	SS_HandleIntegrationTrack.getIsCreateIntegrateTrack();

    delete it;

   Boolean track1	= SS_HandleIntegrationTrack.getIsCreateIntegrateTrack();

    Test.stopTest();
  }

  @isTest
  static void testcreateIntegrationTrack(){

    Test.startTest();
     
    SS_HandleIntegrationTrack.createIntegrationTrack( 'requestStatus', 'endPoint', 'requestBody','surveyName', 'surveyId',
    'requestMethod', 'errorMessage');
    Test.stopTest();
  }
}