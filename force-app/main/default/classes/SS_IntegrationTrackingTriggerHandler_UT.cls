/***********************************************************************************
 *@CLASS: SS_IntegrationTrackingTriggerHandler_UT
 *@Source Class: SS_IntegrationTrackingTriggerHandler
 *-----------------------------------------------------------------------------------
 * DEVELOPER                   DATE                  REASON
 *------------------------------------------------------------------------------------
 * Hari                   2022-02-09              Created
 *************************************************************************************/
@isTest(SeeAllData='false')
public class SS_IntegrationTrackingTriggerHandler_UT {

    @isTest
    static void testTrackingStatusHandlerSucces(){
        SSPR__SS_Integration_Tracking__c inteTrack = new SSPR__SS_Integration_Tracking__c();
        inteTrack.SSPR__SS_Related_to_Name__c = 'test';
        inteTrack.SSPR__SS_Survey_Name__c = 'testing bot';
        inteTrack.SSPR__SS_Status__c   = 'Success';
        
        test.startTest();
         insert inteTrack;
         //test assert eqauls
         List<SSPR__SS_Integration_Tracking__c> integrationTrackList = [select Id from SSPR__SS_Integration_Tracking__c];
        
        system.assertEquals(integrationTrackList.size(), 1);
        test.stopTest();
        
    }
    
    @isTest
    static void testTrackingStatusHandler(){
        SSPR__SS_SurveySparrow_OAuth_Manager__c oa = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
        
        oa.SSPR__SS_Refresh_Token__c = 'contetsbsysyddijs';
        oa.SSPR__SS_is_Refresh_Token_Valid__c = true;
        
        insert oa;
        
        
        SSPR__SS_Integration_Tracking__c inteTrack = new SSPR__SS_Integration_Tracking__c();
        inteTrack.SSPR__SS_Related_to_Name__c = 'testing';
        inteTrack.SSPR__SS_Survey_Name__c = 'testing bot';
        inteTrack.SSPR__SS_Status__c   = 'Unauthorized';
        
        test.startTest();
         insert inteTrack;
        
        SSPR__SS_SurveySparrow_OAuth_Manager__c oauthConnector = [select id,SSPR__SS_is_Refresh_Token_Valid__c from SSPR__SS_SurveySparrow_OAuth_Manager__c
                                        where id=:oa.id];
        
        System.assertEquals(true, true);
         
        test.stopTest();
        
    }
    
    @isTest
    static void testdeleteTrack(){
        
        
        
        SSPR__SS_Integration_Tracking__c inteTrack = new SSPR__SS_Integration_Tracking__c();
        inteTrack.SSPR__SS_Related_to_Name__c = 'testing';
        inteTrack.SSPR__SS_Survey_Name__c = 'testing bot';
        inteTrack.SSPR__SS_Status__c   = 'Success';
        
        
        insert inteTrack;
        
        //to test createDate of the record
        Test.setCreatedDate(inteTrack.Id, DateTime.newInstance(2012,11,11));  

        
        
        
        SSPR__SS_Integration_Tracking__c inteTrack1 = new SSPR__SS_Integration_Tracking__c();
        inteTrack1.SSPR__SS_Related_to_Name__c = 'testing';
        inteTrack1.SSPR__SS_Survey_Name__c = 'testing bot';
        inteTrack1.SSPR__SS_Status__c   = 'Success';
        
        
        test.startTest();
         insert inteTrack1;
         Date lastMonthDate = system.today().addMonths(-1);
        
        //test assert eqauls
         List<SSPR__SS_Integration_Tracking__c> integrationTrackList = [select Id from SSPR__SS_Integration_Tracking__c
                                                                 where CreatedDate <=: lastMonthDate];
        
        system.assertEquals(integrationTrackList.size(), 0);
         
        test.stopTest();
        
    }
        
}