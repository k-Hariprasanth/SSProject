/***********************************************************************************
*@CLASS: SS_SurveyRunnerListViewController
*@Test Class: SS_SurveyRunnerListViewController_UT 
*-----------------------------------------------------------------------------------
* DEVELOPER                  DATE (MM/DD/YYYY)     REASON
*------------------------------------------------------------------------------------
* Sugumar                      				        Created
 *************************************************************************************/
public class SS_SurveyRunnerListViewController {

     /*********************************************************************************
    *@Description: getting records from surveyRunner
    *********************************************************************************/
    @AuraEnabled
    public static List<SSPR__SS_SurveySparrow_Runner__c> getSparrowTriggerRecords()
    {
        List<SSPR__SS_SurveySparrow_Runner__c> surveyList = new List<SSPR__SS_SurveySparrow_Runner__c>();
        
        for(SS_SurveySparrow_Runner__c surveyTrigger : [SELECT Id, Name, SSPR__SS_Object_Name__c FROM SSPR__SS_SurveySparrow_Runner__c]){
            surveyList.add(surveyTrigger);
        }
        
        return surveyList;
    }
    
     /*********************************************************************************
    *@Description: delete the runner using record ID
    *********************************************************************************/
    @AuraEnabled
    public static void deleteRunnerHandler(String surveyRunnerId){
        
        delete [select Id from SSPR__SS_SurveySparrow_Runner__c where Id=:surveyRunnerId];
    }
}