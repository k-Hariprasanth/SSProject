public with sharing class SS_EditSurveyRunnerController {
   
    @AuraEnabled
    public static EditObjectWrapperClass getSurveyRunnerRecord(String surveyRunnerId){

        EditObjectWrapperClass owc = new EditObjectWrapperClass();
        
        
        List<String> selectedFieldStringList ;
        //getting surveyRunner Record List
        List<SSPR__SS_SurveySparrow_Runner__c> surveyRunnerList = [select Name,SSPR__SS_Description__c,SSPR__SS_Object_Name__c,SSPR__SS_Survey_Share__c,
                                                               SSPR__SS_Additional_Comments__c,SSPR__SS_Lookup_Relationship_Enabled__c,
                                                               SSPR__SS_Lookup_Relationship_Field__c,SSPR__SS_Object_Fields_Name__c,
                                                               SSPR__SS_Rate_your_latest_interaction__c,SSPR__SS_Send_Survey_to__c,
                                                               SSPR__SS_Send_Survey_Via__c,SSPR__SS_Survey__c
                                                                from SSPR__SS_SurveySparrow_Runner__c  where Id=:surveyRunnerId limit 1];
        
        SS_SurveySparrow_Runner__c  sst = surveyRunnerList[0];

                                                              
        
        owc.runnerName = sst.Name;
        owc.description    = sst.SSPR__SS_Description__c;
        owc.selectedObject = sst.SSPR__SS_Object_Name__c;
        owc.sendSurveyFields   = sst.SSPR__SS_Send_Survey_to__c;
        owc.sendSurveyType	   = sst.SSPR__SS_Send_Survey_Via__c;
        owc.rateField     	   = sst.SSPR__SS_Rate_your_latest_interaction__c;
        owc.additionalComField = sst.SSPR__SS_Additional_Comments__c;
        owc.surveyShareTempId  = sst.SSPR__SS_Survey_Share__c;
        
        selectedFieldStringList = sst.SSPR__SS_Object_Fields_Name__c != null ? sst.SSPR__SS_Object_Fields_Name__c.split(',') : new List<String>();

        
        
        
        //getting objectList
        Map<String, Schema.SObjectType> objectsMap = Schema.getGlobalDescribe();
        
        List<String> objectOptions = new List<String>();
        
        for(Schema.SObjectType obj : objectsMap.values()){
            objectOptions.add(String.Valueof(obj));
        }
        objectOptions.sort();
        owc.objectNameList = objectOptions;

        //getting survey
        String surveyIdUnique = '';
        List<SSPR__SS_Survey__c> surveyIdList = [select SSPR__SS_Survey_Id__c from SSPR__SS_Survey__c  where Id=: sst.SSPR__SS_Survey__c];
        if(!surveyIdList.isEmpty()){
            owc.seletedSurveyName = surveyIdList[0].SSPR__SS_Survey_Id__c;
             surveyIdUnique = surveyIdList[0].SSPR__SS_Survey_Id__c;
        }
        
        

        //getting surveyShareType
        List<SurveyShareClass> surveyshareList = new List<SurveyShareClass>();
        
        for(SSPR__SS_Survey_Share_Type__c ss : [select Id,SSPR__SS_Name__c,SSPR__SS_External_Id__c from SSPR__SS_Survey_Share_Type__c 
                                          where SSPR__SS_Share_Type__c =: sst.SSPR__SS_Send_Survey_Via__c AND SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c =: surveyIdUnique AND SSPR__SS_Status__c = true])
        {
            SurveyShareClass surveyShare = new SurveyShareClass();
            surveyShare.shareName       =  ss.SSPR__SS_Name__c;
            surveyShare.shareExternalId =  ss.SSPR__SS_External_Id__c;
            surveyshareList.add(surveyShare);
            
        }
        
        owc.surveyShareTypeList = surveyshareList;
        
        //getting surveyList
        List<surveyList> surList = new List<surveyList>();
        
        for(SSPR__SS_Survey__c ss : [SELECT Id,Name,SSPR__SS_Survey_Id__c,SSPR__SS_Is_Active_Survey__c From SSPR__SS_Survey__c where SSPR__SS_Is_Active_Survey__c = true]){
            
            surveyList s2 = new surveyList();
            s2.text  = ss.Name;
            s2.value = ss.SSPR__SS_Survey_Id__c;
            s2.isActive = ss.SSPR__SS_Is_Active_Survey__c;
            surList.add(s2);
        }
         
        owc.surveyNameList = surList;

        //gettingsendSurveyViaTypes
        List<String>  surveyViaTypes = new List<String>{'SMS','EMAIL'};
            
        owc.surveyViaTypes = surveyViaTypes;


        //getting object Fields
        List<String> fieldList = new List<String>();
       
        List<ObjectFieldsClass> objectSelectedFieldList = new List<ObjectFieldsClass>();
        List<String> rateFieldList     = new List<String>();
        List<String> commentsFieldList = new List<String>();

        if(String.isNotBlank(sst.SSPR__SS_Object_Name__c)){
            
            Map<string,Schema.SObjectField> mapstringobject = objectsMap.get(sst.SSPR__SS_Object_Name__c).getDescribe().fields.getMap();
            
            for(Schema.SObjectField fieldnames : mapstringobject.values()){
               

                fieldList.add(String.valueof(fieldnames));
                //mapping the field to the wrapper List Class
                ObjectFieldsClass objFieldClass = new ObjectFieldsClass();
                objFieldClass.fieldApiName      = String.valueof(fieldnames);
                objFieldClass.isSelected        = false;
                objectSelectedFieldList.add(objFieldClass);

            }
            
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
        
       
        owc.rateYourInteractionFieldList = rateFieldList;
        owc.additionalCommentsFieldList  = commentsFieldList;
        

        owc.sobjectFieldListString = fieldList;

       //find the selected Fields In 
       for(ObjectFieldsClass objfie : objectSelectedFieldList){
            
        for(String s : selectedFieldStringList){
              if(objfie.fieldApiName == s){
                  objfie.isSelected = true;
               }

               if(objfie.fieldApiName == 'Id'){
                objfie.disabledvalue = true;
                
               }
            
            }
        
        }

        owc.selectedFieldWrapper = objectSelectedFieldList;
        

        //getting share type object fields

        List<String> objectViaTypeList = new List<String>();
        
        
        if(String.isNotBlank(sst.SSPR__SS_Object_Name__c)){
            
            Map<string,Schema.SObjectField> mapstringobject = objectsMap.get(sst.SSPR__SS_Object_Name__c).getDescribe().fields.getMap();
            
            for(Schema.SObjectField field : mapstringobject.values()){
                
                Schema.DescribeFieldResult fieldResult = field.getDescribe();    
                Schema.DisplayType fielddataType = fieldResult.getType();  
            
                if(fielddataType == Schema.DisplayType.Email && sst.SSPR__SS_Send_Survey_Via__c == 'EMAIL') {  
                    
                    objectViaTypeList.add(fieldResult.getName());
                    
                }else if(fielddataType == Schema.DisplayType.Phone && sst.SSPR__SS_Send_Survey_Via__c == 'SMS' ) {  
                    
                    objectViaTypeList.add(fieldResult.getName()); 
                    
                }
                
               
            }
        }
        owc.shareTypeObjectFields =   objectViaTypeList;

      //  getting object Lookup Response Fields
       
        owc.isEnabledLookup   = sst.SSPR__SS_Lookup_Relationship_Enabled__c;
        owc.objectLookUpField = sst.SSPR__SS_Lookup_Relationship_Field__c;
        
        List<String> objectLookUpFieldList = new List<String>();
        
        Map<string,Schema.SObjectField> mapstringResponseFields = objectsMap.get('SSPR__SS_Answer__c').getDescribe().fields.getMap();
        
        for(Schema.SObjectField fieldnames : mapstringResponseFields.values()){
            String fieldName = String.valueof(fieldnames);
            Schema.DescribeFieldResult f = Schema.getGlobalDescribe().get('SSPR__SS_Answer__c')
                .getDescribe()
                .fields
                .getMap()
                .get(fieldName)
                .getDescribe();
            
            for(Schema.SObjectType reference : f.getReferenceTo()) {
                if(reference.getDescribe().getName() == sst.SSPR__SS_Object_Name__c){
                    objectLookUpFieldList.add(fieldName);
                } 
                
            }
        }

        owc.objectLooupListField =  objectLookUpFieldList; 
        

        return owc;
    }

    @AuraEnabled
    public static List<String> getSurveyViaTypeFields(String sobjectName,String viaType){

        List<String> objectViaTypeList = new List<String>();
        Map<String, Schema.SObjectType> objectsMap = Schema.getGlobalDescribe();
        
        if(String.isNotBlank(sobjectName)){
            
            Map<string,Schema.SObjectField> mapstringobject = objectsMap.get(sobjectName).getDescribe().fields.getMap();
            
            for(Schema.SObjectField field : mapstringobject.values()){
                
                Schema.DescribeFieldResult fieldResult = field.getDescribe();    
                Schema.DisplayType fielddataType = fieldResult.getType();  
            
                if(fielddataType == Schema.DisplayType.Email && viaType == 'EMAIL') {  
                    
                    objectViaTypeList.add(fieldResult.getName());
                    
                }else if(fielddataType == Schema.DisplayType.Phone && viaType == 'SMS' ) {  
                    
                    objectViaTypeList.add(fieldResult.getName()); 
                    
                }
                
               
            }
        }  

        
        return objectViaTypeList;
    }
    
    @AuraEnabled
    public static void updateSurveyRunnerHandle(EditObjectWrapperClass objectWrapperRecord,List<String> sobjectFieldList,
                                                  Boolean lookUpEnableCheck,String surveyRunnerId,List<String> oldobjectFieldList)
    {

     
        SSPR__SS_SurveySparrow_Runner__c ss = new SSPR__SS_SurveySparrow_Runner__c();
        ss.Id     = surveyRunnerId;
        ss.Name   = objectWrapperRecord.runnerName;
        ss.SSPR__SS_Description__c 	= objectWrapperRecord.description;
        ss.SSPR__SS_Object_Name__c	= objectWrapperRecord.selectedObject;
        ss.SSPR__SS_Send_Survey_to__c = objectWrapperRecord.sendSurveyFields;
        ss.SSPR__SS_Additional_Comments__c           = objectWrapperRecord.additionalComField;
        ss.SSPR__SS_Rate_your_latest_interaction__c  = objectWrapperRecord.rateField;
        ss.SSPR__SS_Send_Survey_Via__c     = objectWrapperRecord.sendSurveyType;
        ss.SSPR__SS_Survey_Share__c    = objectWrapperRecord.surveyShareTempId;
        List<SSPR__SS_Survey__c>  surveyList = [select Id,SSPR__SS_Survey_Id__c from SSPR__SS_Survey__c where SSPR__SS_Survey_Id__c =: objectWrapperRecord.seletedSurveyName];
       	String surveyId;
        if(!surveyList.isEmpty()){
            ss.SSPR__SS_Survey__c    = surveyList[0].Id;
            surveyId = surveyList[0].SSPR__SS_Survey_Id__c;
        } 
        String sObjectFields = '';
       
        if(sobjectFieldList != null && !sobjectFieldList.isEmpty()){
            
            for(String s : sobjectFieldList){
                sObjectFields += s + ',';
            }
            sObjectFields.removeEnd(',');
            
        } 
        ss.SSPR__SS_Object_Fields_Name__c  =  sObjectFields;
       	ss.SSPR__SS_Lookup_Relationship_Field__c  = objectWrapperRecord.objectLookUpField;
        ss.SSPR__SS_Lookup_Relationship_Enabled__c = lookUpEnableCheck;
        
       
		
        if(!sobjectFieldList.isEmpty()  && String.isNotEmpty(surveyId)){
            handleVariableCreation(surveyId,objectWrapperRecord.selectedObject,sobjectFieldList);
        }
        
       	update ss;
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
            }else if(fieldAPIName == 'Id'){
                req = new VariablesRequest('SobjectRecordId', 'SobjectRecordId', 'STRING');
            }else{
                req = new VariablesRequest(fieldLabel, fieldAPIName, 'STRING');
            }
           
            
           createVariables(req, surveyUrl, surveyId);
            
        }
        
        VariablesRequest reqVariable = new VariablesRequest('SurveyRunnerId', 'SurveyRunnerId', 'STRING');
        createVariables(reqVariable, surveyUrl, surveyId);
    }
    
    /*********************************************************************************
    *@Description: Create Variable in Survey Sparrow for selected Varaible in Survey trigger
    *********************************************************************************/
    public static void createVariables(VariablesRequest varReq, String surveyUrl, String surveyId){
    
        //Get Access token
        SS_AccessTokenRequest a = new SS_AccessTokenRequest();
        String accessToken = a.getAccessToken();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint( surveyUrl + '/v1/surveys/' + Integer.valueOf(surveyId) + '/variables');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setBody(JSON.serialize(varReq));
        system.debug('-------variable json-----'+JSON.serialize(varReq));
        try{
            
            Http http = new Http();
            HTTPResponse resp = http.send(req);
           
            
            if(resp.getStatus() == 'Ok' && resp.getStatusCode() == 200 && resp.getBody() != null){
                Map<String,Object> liskResponse = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
            }
            
        }catch(Exception exe){
            system.debug(exe.getMessage());
        }
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
                                              where SSPR__SS_Share_Type__c =: shareTypeName AND SSPR__SS_Survey__r.SSPR__SS_Survey_Id__c =: surveyName AND SSPR__SS_Status__c = true])
            {
                SurveyShareClass surveyShare = new SurveyShareClass();
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