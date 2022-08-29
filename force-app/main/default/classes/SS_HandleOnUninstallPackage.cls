global class SS_HandleOnUninstallPackage implements UninstallHandler {
    global void onUninstall(UninstallContext ctx) {
        try{
            List<String> webhookIdStringList = new List<String>();
            String refreshToken;
            String survey_client_Id;
            String survey_client_Secret_Id;
            String accessToken = null;
            String surveyUrl = 'https://app.marketsparrow.com';
            
            for(SSPR__SS_Survey__c s : [select Id,SSPR__SS_Webhook_Id__c  from SSPR__SS_Survey__c]){
                if(s.SSPR__SS_Webhook_Id__c != null){
                    webhookIdStringList.add(s.SSPR__SS_Webhook_Id__c);
                }
            }
             SS_AccessTokenRequest acc = new SS_AccessTokenRequest();
            survey_client_Id = acc.client_id;
            survey_client_Secret_Id = acc.client_secret;
            
            //query on manageSurvey to get SurveyURL
            for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c FROM SSPR__SS_Manage_SurveySparrow_Integration__c LIMIT 1] ){
                if(m.SSPR__Is_surveysparrow_Active__c == true){
                    surveyUrl = 'https://app.marketsparrow.com'; 
                }
            }
            
            //query on OauthManage
            List<SSPR__SS_SurveySparrow_OAuth_Manager__c> authList = [SELECT Id,SSPR__SS_Refresh_Token__c FROM SSPR__SS_SurveySparrow_OAuth_Manager__c LIMIT 1];
            if(!authList.isEmpty()){
                refreshToken = authList[0].SSPR__SS_Refresh_Token__c;
            }
            if(!webhookIdStringList.isEmpty()){
                SS_DisconnectSurveyOnUninstall disconnectSurveyBatch    = new SS_DisconnectSurveyOnUninstall(webhookIdStringList, refreshToken, survey_client_Id,survey_client_Secret_Id, accessToken,surveyUrl);
                Database.executebatch(disconnectSurveyBatch, 1);
            }
        }Catch(Exception exe){
            List<Folder> folderList= [SELECT Id, Name From Folder Where Name = 'TestPurpose'];
            String docFolderId = folderList[0].Id; 
            Document doc = new Document();
            doc.Name = 'The Uninstall   ApexClass exceeption Handle Invoked ujfjfdiuhjjdkjd';
            String jsonB= json.serialize(exe.getMessage()+'--'+exe.getCause()+'--'+exe.getLineNumber());
            doc.Body = Blob.valueOf(jsonB);
            doc.ContentType = 'text/plain';
            doc.Type = 'txt';
            doc.FolderId = docFolderId;
            doc.IsPublic = true;
            Insert doc;
        }
        
    }
    
}