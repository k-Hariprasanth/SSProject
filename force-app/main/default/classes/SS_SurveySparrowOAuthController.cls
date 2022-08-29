/***********************************************************************************
*@CLASS: SS_SurveySparrowOAuthController
*@Test Class: SS_SurveySparrowOAuthController_UT 
*-----------------------------------------------------------------------------------
* DEVELOPER                   DATE (MM/DD/YYYY)     REASON
*------------------------------------------------------------------------------------
* Sugumar                    12/20/2021             Created
 *************************************************************************************/
public with sharing class SS_SurveySparrowOAuthController {
    
    public string theCode {get;set;}
    public string theTokenResponse {get;set;}
    public String statusMessage{get;set;}
    public String surveyUrl{get;set;}
    
    /*******************************************
    *   Get Authorization Code
    *******************************************/
    public pagereference auth_Step_1(){
    
        List<Organization> orgList = [SELECT IsSandbox FROM Organization LIMIT 1];
        Organization org = orgList[0];
        String baseURL = 'https://login.salesforce.com';
        if(org.IsSandbox == true){
            baseURL = 'https://test.salesforce.com';
        }
        
        for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c FROM SSPR__SS_Manage_SurveySparrow_Integration__c LIMIT 1] ){
             if(m.SSPR__Is_thrivesparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com';
            }else if(m.SSPR__Is_surveysparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com'; 
            }
        }

         SS_AccessTokenRequest acc = new SS_AccessTokenRequest();
        
        String survey_client_Id = acc.client_id;
        String survey_client_Secret_Id = acc.client_secret;
       
        theCode = apexPages.currentPage().getParameters().get('code');
        system.debug('------------'+theCode);
        try{
            if(theCode == null){
                String auth_url = surveyUrl + '/o/oauth/auth';
                String params = '?client_id=' + survey_client_Id
                                + '&redirect_uri=' + baseURL + '/apex/SSPR__SS_SurveySparrowOAuthPage'
                                + '&response_type=code';
                system.debug(params);
                system.debug(auth_url + params);
                pageReference pr = New PageReference(auth_url + params);            
                return pr;
            }else if(!String.isBlank(theCode)){
                
                RefreshTokenRequest token = new RefreshTokenRequest(theCode,survey_client_Id,survey_client_Secret_Id);
                String auth_url = surveyUrl + '/o/oauth/token';
                system.debug(JSON.serialize(token));
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setMethod('POST');
                req.setEndpoint(auth_url);
                req.setHeader('Content-Type','application/json');
                req.setBody(JSON.serialize(token));
                HTTPResponse resp;
                
                if(test.isRunningTest()){
                    SS_TestMockHttResponse testMockUp = new SS_TestMockHttResponse();
                    resp =  testMockUp.respond(req);
                }else{
                   resp = http.send(req);
                }
                system.debug(resp.getBody());
                map<string,Object> refershTokenMap = (map<string,Object>)JSON.deserializeUntyped(resp.getBody());
                
                System.debug('refershTokenMap   '+refershTokenMap);
                String refToken = refershTokenMap.get('refresh_token') + '';
                statusMessage = 'You have successfully authenticated';
                
                if(refToken != null && refToken != ''){
                    //getting refer token in custom setings
                    List<SSPR__SS_SurveySparrow_OAuth_Manager__c> authList = [SELECT Id,SSPR__SS_Refresh_Token__c,SSPR__SS_is_Refresh_Token_Valid__c FROM SSPR__SS_SurveySparrow_OAuth_Manager__c limit 1];
                    
                    SSPR__SS_SurveySparrow_OAuth_Manager__c auth = new SSPR__SS_SurveySparrow_OAuth_Manager__c();
                    
                    if(authList != null && !authList.isEmpty()){
                        auth = authList[0];
                    }
                    
                    auth.SSPR__SS_Refresh_Token__c = refToken;
                    auth.SSPR__SS_is_Refresh_Token_Valid__c = True;
                    if(Schema.sObjectType.SSPR__SS_SurveySparrow_OAuth_Manager__c.isCreateable() || Schema.sObjectType.SSPR__SS_SurveySparrow_OAuth_Manager__c.isUpdateable() ){
                        upsert auth;
                    }
                }
            }
            
        }catch(Exception exe){
            statusMessage = 'unexpected error found: please contact your System administractor. Error Message: ' + exe.getMessage();
        }
        
        String domainUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/n/SSPR__Setup';
        pageReference surveySetUp   = New PageReference(domainUrl);    
        return surveySetUp;
    }   
    
    public class RefreshTokenRequest{
        String client_id;
        String client_secret;
        String code;
        String grant_type = 'authorization_code';
        String redirect_uri = 'https://login.salesforce.com';
        
        public RefreshTokenRequest(String code1,String survey_client_Id,String survey_client_Secret_Id){
            code = code1;
            client_id = survey_client_Id;
            client_secret = survey_client_Secret_Id;
        }
    }
}