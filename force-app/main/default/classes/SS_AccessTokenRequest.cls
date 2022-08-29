/***********************************************************************************
*@CLASS: SS_AccessTokenRequest
*@Test Class: SS_AccessTokenRequest_UT
*@DESCRIPTION: This Class used to Getting get accesstoken
*-----------------------------------------------------------------------------------
* DEVELOPER                   DATE                  REASON
*------------------------------------------------------------------------------------
* Hari                   2021-12-15              Created
*************************************************************************************/
public class SS_AccessTokenRequest {
    
    public   String client_id = '0T-UhdT_T62i7smIbNPegyzsVIwNplKdxrMbScxbfHk';
    public  String client_secret = 'OX_YQPNst9CVdinRVJZD71IhJk91UDq4UjhD9TVcGA4';
    String refresh_token;
    String grant_type = 'refresh_token';
    String redirect_uri = 'https://login.salesforce.com';
    
    public SS_AccessTokenRequest(String refresh_token1){
        refresh_token = refresh_token1;
        for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c FROM SSPR__SS_Manage_SurveySparrow_Integration__c LIMIT 1] ){
              if(m.Is_thrivesparrow_Active__c == true){
                 client_id = '0T-UhdT_T62i7smIbNPegyzsVIwNplKdxrMbScxbfHk';
                 client_secret = 'OX_YQPNst9CVdinRVJZD71IhJk91UDq4UjhD9TVcGA4';

            }else if(m.Is_surveysparrow_Active__c == true){
                 client_id = '4e-KZ9i3hbjjLJobgINlWlz1hHrN4lCsZZAkU85Z17c';
                 client_secret = '7zscxHaaSjrp-jgdFzOtU4gAJAbP6kXK0R7GYuiu2xM';

            }
        }

    }
    
    public SS_AccessTokenRequest(){
        List<Organization> orgList = [select IsSandbox from Organization limit 1];
        Organization org = orgList[0];
        
        if(org.IsSandbox == true){
            redirect_uri = 'https://test.salesforce.com';
        } 
        for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c 
                                                             FROM SSPR__SS_Manage_SurveySparrow_Integration__c LIMIT 1] )
        {
              if(m.Is_thrivesparrow_Active__c == true){
                 client_id = '0T-UhdT_T62i7smIbNPegyzsVIwNplKdxrMbScxbfHk';
                 client_secret = 'OX_YQPNst9CVdinRVJZD71IhJk91UDq4UjhD9TVcGA4';

            }else if(m.Is_surveysparrow_Active__c == true){
                 client_id = '4e-KZ9i3hbjjLJobgINlWlz1hHrN4lCsZZAkU85Z17c';
                 client_secret = '7zscxHaaSjrp-jgdFzOtU4gAJAbP6kXK0R7GYuiu2xM';

            }
        }
    }
    
    public String getAccessToken(){
        String accessToken = null;
        String refToken = null;
        
        List<SSPR__SS_SurveySparrow_OAuth_Manager__c> authList = [SELECT Id,SSPR__SS_Refresh_Token__c FROM SSPR__SS_SurveySparrow_OAuth_Manager__c LIMIT 1];
        
        if(authList != null && !authList.isEmpty() && authList[0].SSPR__SS_Refresh_Token__c != null){
            
            String surveyUrl = 'https://app.marketsparrow.com';
            
            for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c FROM SSPR__SS_Manage_SurveySparrow_Integration__c LIMIT 1] ){
               if(m.SSPR__Is_surveysparrow_Active__c == true){
                    surveyUrl = 'https://app.marketsparrow.com'; 
                }
            }
            
            String exceptionString = '';
            
            SS_AccessTokenRequest acc = new SS_AccessTokenRequest(authList[0].SSPR__SS_Refresh_Token__c);
            String auth_url  = surveyUrl + '/o/oauth/token';
            HttpRequest req1 = new HttpRequest();
            Http http1       = new Http();
            req1.setMethod('POST');
            req1.setEndpoint(auth_url);
            req1.setHeader('Content-Type','application/json');
            req1.setBody(JSON.serialize(acc));
            
            HTTPResponse resp1;
            if(Test.isRunningTest()){
                return 'accessToken';
            }else{
               resp1  = http1.send(req1);
                
            }
            Map<string, Object> refershTokenMap1 = (Map<string, Object>)JSON.deserializeUntyped(resp1.getBody());
            accessToken = refershTokenMap1.get('access_token') + '';
        }
        return accessToken;
    }
}