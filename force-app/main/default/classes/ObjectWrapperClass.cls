public class ObjectWrapperClass {
    
    @AuraEnabled
    public string runnerName{get;set;}
    
    @AuraEnabled
    public String description{get;set;}
    
    @AuraEnabled
    public List<surveyList> surveyNameList{get;set;}
    
    @AuraEnabled
    public String seletedSurveyName{get;set;}
    
    @AuraEnabled
    public List<String> objectNameList{get;set;}
    
    @AuraEnabled
    public String selectedObject{get;set;}
    
    @AuraEnabled
    public String sendSurveyType{get;set;}
    
    @AuraEnabled
    public List<String> surveyViaTypes{get;set;}
    
    @AuraEnabled
    public String rateField{get;set;}
    
    @AuraEnabled
    public String additionalComField{get;set;}
    
    @AuraEnabled
    public String sendSurveyFields{get;set;}
    
    @AuraEnabled
    public String objectLookUpField{get;set;}
    
    @AuraEnabled
    public String surveyShareTempId{get;set;}
    
    
}