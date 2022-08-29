public class EditObjectWrapperClass {
    
    @AuraEnabled
        public string runnerName{get;set;}

        @AuraEnabled
        public String description{get;set;}

        @AuraEnabled
        public List<surveyList> surveyNameList;

        @AuraEnabled
        public String seletedSurveyName{get;set;}

        @AuraEnabled
        public List<String> sobjectFieldListString;

        @AuraEnabled
        public List<String> objectNameList;
        
        @AuraEnabled
        public List<String> rateYourInteractionFieldList;

        @AuraEnabled
        public List<String> additionalCommentsFieldList;

        @AuraEnabled
        public List<ObjectFieldsClass> selectedFieldWrapper;

        @AuraEnabled
        public String selectedObject{get;set;}
        
        @AuraEnabled
        public String sendSurveyType{get;set;}

        @AuraEnabled
        public List<String> shareTypeObjectFields;

        @AuraEnabled
        public List<String> surveyViaTypes;
        
        @AuraEnabled
        public String rateField{get;set;}

        @AuraEnabled
        public Boolean isEnabledLookup{get;set;}
        
        @AuraEnabled
        public String additionalComField{get;set;}

        @AuraEnabled
        public String sendSurveyFields{get;set;}

        @AuraEnabled
        public String objectLookUpField{get;set;}

        @AuraEnabled
        public List<String> objectLooupListField;
        
         @AuraEnabled
        public String surveyShareTempId{get;set;}
        
        @AuraEnabled
        public List<SurveyShareClass> surveyShareTypeList;

}