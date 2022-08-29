/***********************************************************************************
*@CLASS: SS_CreateSurveyRunnerController
*@Test Class: SS_CreateSurveyRunnerController_UT
*-----------------------------------------------------------------------------------
* DEVELOPER                  DATE (MM/DD/YYYY)     REASON
*------------------------------------------------------------------------------------
* Sugumar                                          Created
*************************************************************************************/
public with sharing class SS_CreateSurveyRunnerController {
    
    
    /*********************************************************************************
*@Description: getting object Name List and Survey List
*********************************************************************************/
    @AuraEnabled
    public static ObjectWrapperClass getObjectAndSurvey(){
        
        
        ObjectWrapperClass ow = new ObjectWrapperClass();
        
        //getting objectList
        Map<String, Schema.SObjectType> objectsMap = Schema.getGlobalDescribe();
        List<String> objectOptions = new List<String>();
        
        for(Schema.SObjectType obj : objectsMap.values()){
            objectOptions.add(String.Valueof(obj));
        }
        objectOptions.sort();
        ow.objectNameList = objectOptions;
        
        //getting surveyList
        List<surveyList> surList = new List<surveyList>();
        
        for(SSPR__SS_Survey__c ss : [SELECT Id,Name,SSPR__SS_Survey_Id__c From SSPR__SS_Survey__c where SSPR__SS_Is_Active_Survey__c = true]){
            surveyList s2 = new surveyList();
            s2.text  = ss.Name;
            s2.value = ss.SSPR__SS_Survey_Id__c;
            surList.add(s2);
        }
        
        ow.surveyNameList = surList;
        
        //gettingsendSurveyViaTypes
        List<String>  surveyViaTypes = new List<String>{' SMS ',' EMAIL '};
            
            ow.surveyViaTypes = surveyViaTypes;
        return ow;
    }
    /*********************************************************************************
*@Description: getting field List using Object Name
*********************************************************************************/
    @AuraEnabled
    public static List<ObjectFieldsClass>  getSelectedObjectFields(String sobjectName){
        system.debug(sobjectName);
        List<ObjectFieldsClass> fieldList = new List<ObjectFieldsClass>();
        
        Map<String, Schema.SObjectType> objectsMap = Schema.getGlobalDescribe();
        
        if(String.isNotBlank(sobjectName)){
            
            Map<string,Schema.SObjectField> mapstringobject = objectsMap.get(sobjectName).getDescribe().fields.getMap();
            
            for(Schema.SObjectField fieldnames : mapstringobject.values()){
                ObjectFieldsClass objField = new ObjectFieldsClass();
                objField.fieldApiName = String.valueof(fieldnames);
                objField.isSelected   = false;
                fieldList.add(objField);
            }
        }  
        return fieldList;
    }
    /*********************************************************************************
*@Description: getting field List using Object Name for mapping response value
*********************************************************************************/   
    @AuraEnabled
    public static ObjectFieldClass getRateAndCommentsFields(String sobjectName){
        ObjectFieldClass ofc = new ObjectFieldClass();
        List<String> rateFieldList     = new List<String>();
        List<String> commentsFieldList = new List<String>();
        if(String.isNotBlank(sobjectName)){
            Map<String, Schema.SObjectType> objectsMap = Schema.getGlobalDescribe();
            Map<string,Schema.SObjectField> mapstringobject = objectsMap.get(sobjectName).getDescribe().fields.getMap();
            
            for (Schema.SObjectField field: mapstringobject.values()) {
                
                Schema.DescribeFieldResult fieldResult = field.getDescribe();    
                Schema.DisplayType fielddataType = fieldResult.getType(); 
                
                if(fielddataType == Schema.DisplayType.Integer || fielddataType ==  Schema.DisplayType.String ) {
                    rateFieldList.add(fieldResult.getName());
                }
                
                if(fielddataType == Schema.DisplayType.TextArea ){
                    commentsFieldList.add(fieldResult.getName());
                }
            }
        }
        
        ofc.rateYourInteractionFieldList = rateFieldList;
        ofc.additionalCommentsFieldList  = commentsFieldList;
        return ofc;
    }
    
    /*********************************************************************************
*@Description: getting email and sms fields	using Object Name 
*********************************************************************************/   
    @AuraEnabled
    public static List<String> getSurveyViaTypeFields(String sobjectName,String viaType){
        
        List<String> objectViaTypeList = new List<String>();
        Map<String, Schema.SObjectType> objectsMap = Schema.getGlobalDescribe();
        
        if(String.isNotBlank(sobjectName)){
            
            Map<string,Schema.SObjectField> mapstringobject = objectsMap.get(sobjectName).getDescribe().fields.getMap();
            
            for(Schema.SObjectField field : mapstringobject.values()){
                
                Schema.DescribeFieldResult fieldResult = field.getDescribe();    
                Schema.DisplayType fielddataType = fieldResult.getType();  
                
                if(fielddataType == Schema.DisplayType.Email && viaType == ' EMAIL ') {  
                    
                    objectViaTypeList.add(fieldResult.getName());
                    
                }else if(fielddataType == Schema.DisplayType.Phone && viaType == ' SMS ' ) {  
                    
                    objectViaTypeList.add(fieldResult.getName()); 
                    
                }
            }
        }  
        return objectViaTypeList;
    }
    /*********************************************************************************
*@Description: getting field List using Object Name for mapping response value
*********************************************************************************/   
    @AuraEnabled
    public static List<String> getResponseSobjectLookupField(String sObjectName){
        
        List<String> objectLookUpFieldList = new List<String>();
        Map<String, Schema.SObjectType> objectsMap = Schema.getGlobalDescribe();
        Map<string,Schema.SObjectField> mapstringobject = objectsMap.get('SSPR__SS_Answer__c').getDescribe().fields.getMap();
        
        for(Schema.SObjectField fieldnames : mapstringobject.values()){
            String fieldName = String.valueof(fieldnames);
            Schema.DescribeFieldResult f = Schema.getGlobalDescribe().get('SSPR__SS_Answer__c')
                .getDescribe()
                .fields
                .getMap()
                .get(fieldName)
                .getDescribe();
            
            for(Schema.SObjectType reference : f.getReferenceTo()) {
                if(reference.getDescribe().getName() == sObjectName){
                    objectLookUpFieldList.add(fieldName);
                } 
            }
        }
        return objectLookUpFieldList;
    }
    /*********************************************************************************
*@Description: creating surveyRunner Record
*********************************************************************************/     
    @AuraEnabled
    public static String createSurveyRunnerHandle(ObjectWrapperClass objectWrapperRecord,List<String> sobjectFieldList,Boolean lookUpEnableCheck){
        
        
        String dominURL;
        
        
        
        SSPR__SS_SurveySparrow_Runner__c ss = new SSPR__SS_SurveySparrow_Runner__c();
        
        ss.Name   = objectWrapperRecord.runnerName;
        ss.SSPR__SS_Description__c     = objectWrapperRecord.description;
        ss.SSPR__SS_Object_Name__c     = objectWrapperRecord.selectedObject;
        ss.SSPR__SS_Send_Survey_to__c  = objectWrapperRecord.sendSurveyFields;
        ss.SSPR__SS_Send_Survey_Via__c = objectWrapperRecord.sendSurveyType;
        ss.SSPR__SS_Survey_Share__c    = objectWrapperRecord.surveyShareTempId;
        
        List<SSPR__SS_Survey__c>  surveyList = [select Id,SSPR__SS_Survey_Id__c from SSPR__SS_Survey__c where SSPR__SS_Survey_Id__c =: objectWrapperRecord.seletedSurveyName];
        if(!surveyList.isEmpty()){
            ss.SSPR__SS_Survey__c    = surveyList[0].Id;
        } 
        String sObjectFields = '';
        
        if(sobjectFieldList != null && !sobjectFieldList.isEmpty()){
            
            for(String s : sobjectFieldList){
                sObjectFields += s + ',';
            }
            
            sObjectFields = sObjectFields.removeEnd(',');
        } 
        
        ss.SSPR__SS_Object_Fields_Name__c  =  sObjectFields;
        ss.SSPR__SS_Additional_Comments__c           = objectWrapperRecord.additionalComField;
        ss.SSPR__SS_Rate_your_latest_interaction__c  = objectWrapperRecord.rateField;
        
        if(lookUpEnableCheck == true){
            ss.SSPR__SS_Lookup_Relationship_Field__c   = objectWrapperRecord.objectLookUpField;
            ss.SSPR__SS_Lookup_Relationship_Enabled__c = lookUpEnableCheck;
        }
        
        
        try{
            
            
            //inserting surveyRunner Record
            insert ss;
            
            handleVariableCreation(surveyList[0].SSPR__SS_Survey_Id__c,objectWrapperRecord.selectedObject, sobjectFieldList); 
            dominURL = URL.getSalesforceBaseUrl().toExternalForm() + '/builder_platform_interaction/flowBuilder.app'; 
            
            
        }catch(Exception exe){
            String	exceptionString = exe.getMessage();
            
            
        }
        
        return dominURL;
        
    }
    
    /*********************************************************************************
*@Description: Make a callout to Survey Sparrow and create Survey records FROM the response. External Id field used to upsert the record.
*********************************************************************************/
    @AuraEnabled
    public static void pullSurveysfromSurveySparrow(){
        
        //Get Access token
        SS_AccessTokenRequest a = new SS_AccessTokenRequest();
        String accessToken = a.getAccessToken();
        String surveyUrl   = getActiveEnvironment();
        
        Boolean createTracking = SS_HandleIntegrationTrack.getIsCreateIntegrateTrack();
        
        if(String.isNotBlank(surveyUrl)){
            String exceptionString;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(surveyUrl+'/v1/surveys');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            HTTPResponse resp;
            try{
                Http http         = new Http();
                resp = http.send(req);
                
                List<SS_Survey_Share_Type__c> sharetoUpsert = new List<SS_Survey_Share_Type__c>();
                
                if(resp.getStatus() == 'Ok' && resp.getStatusCode() == 200 && resp.getBody() != null ){
                    
                    //deserialize the response
                    List<SSPR__SS_Survey__c> surveytoUpsert = deserializeSurveys( (Map<String,Object>)JSON.deserializeUntyped(resp.getBody()) );
                    Set<Id> surveyIdSet = new Set<Id>();
                    
                    for(SSPR__SS_Survey__c survey : surveytoUpsert){
                        HttpRequest req1 = new HttpRequest();
                        HttpRequest req2 =	null;
                        if(survey.SSPR__SS_Survey_Type__c == 'NPS'  || survey.SSPR__SS_Survey_Type__c == 'NPSChat' ||
                           survey.SSPR__SS_Survey_Type__c == 'CES' || survey.SSPR__SS_Survey_Type__c == 'CESChat' || 
                           survey.SSPR__SS_Survey_Type__c == 'CSAT' || survey.SSPR__SS_Survey_Type__c == 'CSATChat' )
                        {
                            req1.setEndpoint(surveyUrl+'/v1/nps/' + survey.SSPR__SS_Survey_Id__c + '/shares?mode=RECURRING');
                            
                            req2 = new HttpRequest();
                            req2.setEndpoint(surveyUrl+'/v1/nps/' + survey.SSPR__SS_Survey_Id__c + '/shares?mode=RELATIVE_RECURRING');
                            req2.setMethod('GET');
                            req2.setHeader('Content-Type', 'application/json');
                            req2.setHeader('Authorization', 'Bearer ' + accessToken);
                        }else{
                            req1.setEndpoint(surveyUrl+'/v1/surveys/' + survey.SSPR__SS_Survey_Id__c + '/shares');
                        }
                        
                        req1.setMethod('GET');
                        req1.setHeader('Content-Type', 'application/json');
                        req1.setHeader('Authorization', 'Bearer ' + accessToken);
                        
                        
                        Http http1         = new Http();
                        HTTPResponse resp1 = http1.send(req1);
                        if(resp1.getStatus() == 'Ok' && resp1.getStatusCode() == 200 && resp1.getBody() != null){
                            system.debug(resp1.getBody());
                            sharetoUpsert.addAll(deserializeSurveyShareType((Map<String,Object>)JSON.deserializeUntyped(resp1.getBody()), survey.SSPR__SS_Survey_Id__c));
                        }else if(resp1.getStatus() == 'Unauthorized'){
                            if(createTracking == false){
                                SS_HandleIntegrationTrack.updateSurveyOauth();
                            }
                        }
                        
                        if(req2 !=null){
                            Http http2        = new Http();
                            HTTPResponse resp2 = http2.send(req2);
                            if(resp2.getStatus() == 'Ok' && resp2.getStatusCode() == 200 && resp2.getBody() != null){
                                system.debug(resp2.getBody());
                                sharetoUpsert.addAll(deserializeSurveyShareType((Map<String,Object>)JSON.deserializeUntyped(resp2.getBody()), survey.SSPR__SS_Survey_Id__c));
                            }else if(resp2.getStatus() == 'Unauthorized'){
                                if(createTracking == false){
                                    SS_HandleIntegrationTrack.updateSurveyOauth();
                                }
                            }
                        }
                        
                        
                    }
                    
                    if(surveytoUpsert != null && !surveytoUpsert.isEMpty()){
                        
                        //Using external Id to upsert the record.
                        Schema.SObjectField ExternalIdField = SSPR__SS_Survey__c.Fields.SSPR__SS_Survey_Id__c;
                        List<Database.UpsertResult> checkListUpsertRes = Database.upsert(surveytoUpsert, ExternalIdField, false);
                        
                        if(sharetoUpsert != null && !sharetoUpsert.isEmpty()){
                            //Using external Id to upsert the record.
                            Schema.SObjectField ExternalIdField1 = SSPR__SS_Survey_Share_Type__c.Fields.SS_External_Id__c;
                            List<Database.UpsertResult> checkListUpsertRes1 = Database.upsert(sharetoUpsert, ExternalIdField1, false);
                        }
                        
                        Database.executeBatch(new SS_SurveySyncManager(), 1);
                    }
                    
                }else if(resp.getStatus() == 'Unauthorized'){
                    if(createTracking == false){
                        SS_HandleIntegrationTrack.updateSurveyOauth();
                    }
                }
            }catch(Exception exe){
                exceptionString	=	exe.getMessage();
                
            }    
            String surveyName = '';
            String surveyId = '';
            
            if(createTracking){
                SS_HandleIntegrationTrack.createIntegrationTrack(resp.getStatus(),req.getEndpoint(),resp.getBody(),surveyName,surveyId,
                                                                 req.getMethod(),exceptionString);
            }
        }
    }
    
    /*********************************************************************************
*@Description: deserialize the Survey response and create Survey records
*********************************************************************************/
    public static List<SSPR__SS_Survey__c> deserializeSurveys(Map<String,Object> josnRowMap){
        
        Object surveysObject              = josnRowMap.get('surveys');
        List<Object> surveysObjectList    = (List<Object>)surveysObject;
        List<SSPR__SS_Survey__c> surveytoUpsert = new List<SSPR__SS_Survey__c>();
        system.debug('-------------survey Json-----------'+surveysObjectList);
        for(Object surveyIterator : surveysObjectList){
            
            Map<String,Object> surveyVariableMap = (Map<String,Object>)surveyIterator;
            
            if(surveyVariableMap.get('id') != null){
                
                SSPR__SS_Survey__c survey      = new SSPR__SS_Survey__c();
                survey.Name              = surveyVariableMap.get('name').toString();
                survey.SSPR__SS_Survey_Id__c   = String.valueOf(surveyVariableMap.get('id'));
                survey.SSPR__SS_Is_Active_Survey__c = true;
                survey.SSPR__SS_Archived__c    = Boolean.valueOf(surveyVariableMap.get('archived'));
                survey.SSPR__SS_Survey_Type__c = surveyVariableMap.get('surveyType').toString();
                surveytoUpsert.add(survey);
                
            }
        }
        return surveytoUpsert;   
    }
    
    @AuraEnabled
    public static List<String> getSurveyName(){
        
        List<String> surveyRunnerNameList = new List<String>();
        for(SSPR__SS_SurveySparrow_Runner__c sr : [select Name from SSPR__SS_SurveySparrow_Runner__c] ){
            surveyRunnerNameList.add(sr.Name);
        }
        
        return surveyRunnerNameList;
    }
    /*********************************************************************************
*@Description: Used to create variable in Survey Sparrow
*********************************************************************************/
    @future(callout = true)
    public static void handleVariableCreation(String surveyId, String sobjectName, List<String> sObjectFieldsList){
        
        Map<string,Schema.SObjectField> mapstringobject = getFieldListbyObjectname(sobjectName);
        Map<string,String> fieldAPINameMap              = new Map<String, String>();
        Map<String,Schema.DisplayType> fieldDataTypeMap    = new Map<String,Schema.DisplayType>();
        
        for(String fieldname : mapstringobject.keySet()){
            
            String fieldLabel = mapstringobject.get(fieldname).getDescribe().getLabel();
            String fieldAPIName = String.valueOf(mapstringobject.get(fieldname)); 
            fieldAPINameMap.put(fieldAPIName, fieldLabel);
            fieldDataTypeMap.put(fieldAPIName,mapstringobject.get(fieldname).getDescribe().getType());
        }
        
        String surveyUrl = getActiveEnvironment();
        
        for(String fieldAPIName : sObjectFieldsList){
            
            String fieldLabel = fieldAPINameMap.get(fieldAPIName);
            VariablesRequest req;
            
            if(fieldDataTypeMap.get(fieldAPIName) == Schema.DisplayType.Integer){
                
                req = new VariablesRequest(fieldLabel, fieldAPIName, 'NUMBER');
                
            }else if(fieldDataTypeMap.get(fieldAPIName) == Schema.DisplayType.DateTime){
                
                req = new VariablesRequest(fieldLabel, fieldAPIName, 'DATE');
            }else if(fieldAPIName ==  'Id'){
                req = new VariablesRequest('SobjectRecordId', 'SobjectRecordId', 'STRING');
            }else{
                req = new VariablesRequest(fieldLabel, fieldAPIName, 'STRING');
            }
            
            createVariables(req, surveyUrl, surveyId);
            
        }
        
        VariablesRequest reqVariable = new VariablesRequest('SurveyRunnerId', 'SurveyRunnerId', 'STRING');
        
        //create surveyRunnerId Variable
        createVariables(reqVariable, surveyUrl, surveyId);
        
    }
    
    /*********************************************************************************
*@Description: Create Variable in Survey Sparrow for selected Varaible in Survey trigger
*********************************************************************************/
    public static void createVariables(VariablesRequest varReq, String surveyUrl, String surveyId){
        
        //Get Access token
        SS_AccessTokenRequest a = new SS_AccessTokenRequest();
        String accessToken = a.getAccessToken();
        
        Boolean createTracking = SS_HandleIntegrationTrack.getIsCreateIntegrateTrack();
        
        String surveyName = '';
        String exceptionString = '';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint( surveyUrl + '/v1/surveys/' + Integer.valueOf(surveyId) + '/variables');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setBody(JSON.serialize(varReq));
        HTTPResponse resp;
        try{
            
            Http http = new Http();
            resp = http.send(req);
            
            if(resp.getStatus() == 'Ok' && resp.getStatusCode() == 200 && resp.getBody() != null){
                system.debug(resp.getBody());
                Map<String,Object> liskResponse = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
            }else if(resp.getStatus() == 'Unauthorized'){
                if(createTracking == false){
                    SS_HandleIntegrationTrack.updateSurveyOauth();
                }
            }
            
        }catch(Exception exe){
            exceptionString =	exe.getMessage();
        }
        
        if(createTracking){
            SS_HandleIntegrationTrack.createIntegrationTrack(resp.getStatus(),req.getEndpoint(),resp.getBody(),surveyName,surveyId,
                                                             req.getMethod(),exceptionString);
        }
        
        
    }
    
    
    /*********************************************************************************
*@Description: deserialize the Survey Share type response
*********************************************************************************/
    public static List<SSPR__SS_Survey_Share_Type__c> deserializeSurveyShareType(Map<String,Object> josnRowMap, String surveyExternalId){
        
        
        Object shareObject              = josnRowMap.get('shares');
        
        List<Object> shareObjectList    = (List<Object>)shareObject;
        system.debug('shareObjectList'+shareObjectList);
        List<SSPR__SS_Survey_Share_Type__c> sharetoUpsert = new List<SSPR__SS_Survey_Share_Type__c>();
        
        if(shareObjectList == null || shareObjectList.isEmpty()){
            return sharetoUpsert; 
        }
        for(Object shareIterator : shareObjectList){
            
            Map<String,Object> shareVariableMap = (Map<String,Object>)shareIterator;
            
            
            if(shareVariableMap.get('id') != null 
               && (shareVariableMap.get('type').toString() == 'SMS' || shareVariableMap.get('type').toString() == 'EMAIL')) 
            {
                
                SS_Survey_Share_Type__c share = new SS_Survey_Share_Type__c();
                share.SS_Name__c              = shareVariableMap.get('name').toString();
                share.SSPR__SS_External_Id__c       = String.valueOf(shareVariableMap.get('id'));
                share.SSPR__SS_Survey__r = new SSPR__SS_Survey__c(SSPR__SS_Survey_Id__c = surveyExternalId);
                
                if(shareVariableMap.get('type').toString() == 'EMAIL'){
                    share.SSPR__SS_Share_Type__c = 'EMAIL';
                }else{
                    share.SSPR__SS_Share_Type__c = 'SMS';
                }
                if(shareVariableMap.get('status').toString() == 'ACTIVE'){
                    share.SSPR__SS_Status__c = true;
                }else{
                    share.SSPR__SS_Status__c = false;
                }
                sharetoUpsert.add(share);
                
            }
        }
        return sharetoUpsert;   
    }
    
    @AuraEnabled
    public static List<SurveyShareClass> getSurveyShareType(String shareTypeName,String surveyName){
        List<SurveyShareClass> surveyClassList = new List<SurveyShareClass>();
        
        if(shareTypeName == ' EMAIL '){
            shareTypeName = 'EMAIL';
        }else if(shareTypeName == ' SMS '){
            shareTypeName = 'SMS';
        }
        
        if(!String.isBlank(shareTypeName) && !String.isBlank(surveyName)){
            
            for(SSPR__SS_Survey_Share_Type__c ss : [select Id,SSPR__SS_Name__c,SSPR__SS_External_Id__c from SSPR__SS_Survey_Share_Type__c 
                                                    where SSPR__SS_Share_Type__c =: shareTypeName AND SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c =: surveyName AND SS_Status__c = true])
            {
                SurveyShareClass surveyShare= new SurveyShareClass();
                surveyShare.shareName       =  ss.SSPR__SS_Name__c;
                surveyShare.shareExternalId =  ss.SSPR__SS_External_Id__c;
                surveyClassList.add(surveyShare);
                
            }
        }
        
        return surveyClassList;
    }
    
    /*********************************************************************************
*@Description: fetch all the field name by passing Object API name
*********************************************************************************/
    public static Map<String , Schema.SObjectField > getFieldListbyObjectname(String objectName){
        
        Map<String, Schema.SObjectType > globalDescription = Schema.getGlobalDescribe();   
        Schema.sObjectType objType                         = globalDescription.get( objectName );  
        Schema.DescribeSObjectResult r1                    = objType.getDescribe();   
        Map<String , Schema.SObjectField > mapFieldList    = r1.fields.getMap(); 
        return mapFieldList;
    }
    
    
    /*********************************************************************************
*@Description: Used to get the Active Environment target URL
*********************************************************************************/
    public static String getActiveEnvironment(){
        
        String surveyUrl = 'https://app.marketsparrow.com';
        for(SSPR__SS_Manage_SurveySparrow_Integration__c m :[SELECT SSPR__Is_surveysparrow_Active__c,SSPR__Is_thrivesparrow_Active__c FROM SSPR__SS_Manage_SurveySparrow_Integration__c] ){
            if(m.SSPR__Is_thrivesparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com';
            }else if(m.SSPR__Is_surveysparrow_Active__c == true){
                surveyUrl = 'https://app.marketsparrow.com'; 
            }
        }
        return surveyUrl;
    }
    
    
    
    public class ObjectFieldClass{
        @AuraEnabled
        public List<String> rateYourInteractionFieldList{get;set;}
        
        @AuraEnabled
        public List<String> additionalCommentsFieldList{get;set;}
    }
    
    
    
    
    public class ObjectFieldsClass{
        @AuraEnabled
        public String fieldApiName{get;set;}
        @AuraEnabled
        public Boolean isSelected{get;set;}
        
        
    }
    
    public class SurveyShareClass{
        @AuraEnabled
        public String shareName{get;set;}
        
        @AuraEnabled
        public String shareExternalId{get;set;}
    }
    
    
    public class VariablesRequest{
        public String label;
        public String name;
        public String type;
        public VariablesRequest(String label1, String name1, String type1){
            label = label1;
            name = name1;
            type = type1;
        }
    }
}