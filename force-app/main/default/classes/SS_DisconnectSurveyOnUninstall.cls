global class SS_DisconnectSurveyOnUninstall implements Database.Batchable<String>,Database.Stateful, Database.AllowsCallouts{
    
    public List<String> webhookIdList;
    public String accessToken;
    public String surveyUrl;
    public String refereshToken;
    public String clientId;
    public String clientSecret; 
    public Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    global SS_DisconnectSurveyOnUninstall(List<String> webHookIdListParam, String refreshTokenParam, 
                                          String clientIdParam, String clientSecretParam, String accessTokenParam, String surveyUrlParam)
    {
        webhookIdList = webHookIdListParam;
        accessTokenParam = accessToken;
        surveyUrl  = surveyUrlParam;
        refereshToken = refreshTokenParam;
        clientId = clientIdParam;
        clientSecret = clientSecretParam;
        
        system.debug(accessTokenParam);

        if(accessTokenParam == null){
            AccessTokenRequestClass acc = new AccessTokenRequestClass();
            accessToken =  acc.getAccessToken(refreshTokenParam, clientIdParam, clientSecretParam, surveyUrlParam, mail);  
        } 
    }
    
    global List<String> start(Database.BatchableContext bc) {
        return webhookIdList;
    }
    
    global void execute(Database.BatchableContext bc,List<String>  webHookIds){
        
        Integer webHookId = integer.valueof(webhookIdList[0]);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(surveyUrl+ '/v1/webhooks/'+webHookId);
        req.setMethod('DELETE');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        Http http = new Http();
        
        try{
            HTTPResponse resp = http.send(req);
            if( resp != null && resp.getStatusCode() == 204){
                System.debug('sucesss');
            }
            webhookIdList.remove(0);
        }catch(Exception exe){
            //retry delete webhook on Exception
            List<Folder> folderList= [SELECT Id, Name From Folder Where Name = 'TestPurpose'];
            String docFolderId = folderList[0].Id; 
            Document doc1 = new Document();
            doc1.Name = 'Delete Webhook: '+webHookId ;
            String jsonB= json.serialize(exe.getMessage()+'--'+exe.getCause()+'--'+exe.getLineNumber() + exe.getStackTraceString() );
            doc1.Body = Blob.valueOf(jsonB);
            doc1.ContentType = 'text/plain';
            doc1.Type = 'txt';
            doc1.FolderId = docFolderId;
            doc1.IsPublic = true;
            insert doc1;
            accessToken = null;
        }
    }
    
    //batch finish method
    global void finish(Database.BatchableContext bc){
        String[] toAddresses = new String[] {'hariprasanth.k@bitordertech.com'};
        mail.setToAddresses(toAddresses); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('finish method executed');
    }
 

    public class AccessTokenRequestClass{
        
        String refresh_token;
        String grant_type = 'refresh_token';
        String redirect_uri = 'https://login.salesforce.com';
        String client_id;
        String client_secret;
        public AccessTokenRequestClass(){}
        
        public AccessTokenRequestClass(String refresh_token1,String clientId1, String clientSecret1){
            refresh_token = refresh_token1;
            client_id     = clientId1;
            client_secret = clientSecret1;
            
        }
        
        public String getAccessToken(String refresh_token2, String clientId, String clientSecret,String surveyUrl1, Messaging.SingleEmailMessage  mail){
            
            AccessTokenRequestClass acc1 = new AccessTokenRequestClass(refresh_token2,clientId,clientSecret);   
            String bodyStr = '';
            String auth_url  = surveyUrl1 + '/o/oauth/token';
            HttpRequest req1 = new HttpRequest();
            Http http1       = new Http();
            req1.setMethod('POST');
            req1.setEndpoint(auth_url);
            req1.setHeader('Content-Type','application/json');
            req1.setBody(JSON.serialize(acc1));
            
            HTTPResponse resp1 = null;
            if(Test.isRunningTest()){
                return 'accessToken';
            }else{
                try{
                    resp1  = http1.send(req1);
                }catch(Exception exe){
                    bodyStr =  ':---Exception- While getting Access Token---: ' + exe.getLineNumber() + '--' + exe.getMessage() + '--' + exe.getCause();
                }
            }
            String accessToken1 = null;
            
            if(resp1 != null){
                if(resp1.getStatusCode() != 204 && resp1.getBody() != null){
                    Map<string, Object> refershTokenMap1 = (Map<string, Object>)JSON.deserializeUntyped(resp1.getBody());
                    
                    if(refershTokenMap1.get('access_token') != null){
                        accessToken1  = refershTokenMap1.get('access_token') + ''; 
                    }
                }
                bodyStr = bodyStr + ':-----------------: accessToken1 :' +accessToken1 ;
                
            }else{
                bodyStr = bodyStr + ':-----------------: Response Empty- Null :'  ;
            }
            mail.setPlainTextBody(bodyStr);

            
            return accessToken1;
        }
    }
    
}