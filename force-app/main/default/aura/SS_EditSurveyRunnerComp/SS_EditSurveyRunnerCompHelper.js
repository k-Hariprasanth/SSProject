({
    updateSurveyRunnerRecord : function(component, event, helper) {
        debugger;
	    var dataWrapperObject = component.get("v.dataWrapper");
        var selectedSobjectFields = dataWrapperObject.selectedFieldWrapper;
        var oldFieldArray  = component.get("v.oldObjectFieldList");
      console.log(oldFieldArray);
        var fieldsArray = [];
        
        for(var i = 0 ; i < selectedSobjectFields.length ; i++){
            var field = selectedSobjectFields[i];
            
            if(field.isSelected == true){
                fieldsArray.push(field.fieldApiName);
            }
            
        }
        
        
        var updateSurveyRunnerAction = component.get("c.updateSurveyRunnerHandle");
        
        var checkCmp = component.find("chkbox").get("v.checked");
        var recordId = component.get("v.surveyRunnerId");
        updateSurveyRunnerAction.setParams({
            objectWrapperRecord : dataWrapperObject,
            sobjectFieldList    : fieldsArray,
            lookUpEnableCheck   : checkCmp,
            surveyRunnerId      : recordId,
            oldobjectFieldList  : oldFieldArray
        }); 
        
       
        updateSurveyRunnerAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                    
                    component.set('v.showListView', true);
                    component.set('v.showEditPage', false);
                    
                    
                    $A.createComponent(
                        "c:SS_SurveyRunnerListViewComp",{
                        },
                        function(newCard, status, errorMessage){
                            
                            if (status === "SUCCESS") {
                                
                                
                                var body = component.get("v.body");
                                body.push(newCard);
                                component.set("v.body", body);
                                component.set("v.loaded",false);
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                            } else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                            }
                        }
                    ); 
                
            }
        });
        
        $A.enqueueAction(updateSurveyRunnerAction);
    },
    getSurveyRunnerName : function(component, event, helper){
        debugger;
        var action = component.get('c.getSurveyName');
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
               var wrap = component.get("v.dataWrapper");
               var surveyNameList = response.getReturnValue();
               surveyNameList.splice(surveyNameList.indexOf(wrap.runnerName), 1);
               component.set("v.surveyNameList",surveyNameList);
            }
        });
        $A.enqueueAction(action);
    },
    getSurveyShareTypeTemplate : function(component, event, helper){
        var action = component.get('c.getSurveyShareType');
        var objectName  = component.get("v.dataWrapper");
        
        action.setParams({
            surveyName		  : objectName.seletedSurveyName,
            shareTypeName     :  objectName.sendSurveyType
        });
       
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
               
               component.set("v.surveyShareTypeTemp",response.getReturnValue());
                
            }
        });
        $A.enqueueAction(action);
    }
})