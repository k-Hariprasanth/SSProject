({
  
    gettingSurveyLookUpFields : function(component, event, helper){
        
        
        var lookupFieldAction = component.get("c.getResponseSobjectLookupField");
        var objectName  = component.get("v.dataWrapper");
        
        lookupFieldAction.setParams({
            sObjectName :  objectName.selectedObject
        });
        
        
        lookupFieldAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",false);
                component.set('v.lookUpFieldsList',response.getReturnValue());
            }
        });
        
        $A.enqueueAction(lookupFieldAction);
    },
    createSurveyRunnerRecord : function(component, event, helper){
        debugger;
        var selectedSobjectFields = component.get("v.fieldsNameList");
        var fieldsArray = [];
        
        for(var i = 0 ; i < selectedSobjectFields.length ; i++){
            var field = selectedSobjectFields[i];
            
            if(field.isSelected == true){
                fieldsArray.push(field.fieldApiName);
            }
            
        }
        
        var dataWrapperObject = component.get("v.dataWrapper");
        var createSurveyRunnerAction = component.get("c.createSurveyRunnerHandle");
        var checkCmp = component.find("chkbox").get("v.checked");
        
        createSurveyRunnerAction.setParams({
            objectWrapperRecord : dataWrapperObject,
            sobjectFieldList : fieldsArray,
            lookUpEnableCheck : checkCmp     
        });
        
        var flowLaunch = component.get("v.lauchFlow");
        createSurveyRunnerAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(flowLaunch == false){
                    component.set("v.loaded",true);
                    component.set('v.showListView', true);
                    component.set('v.showCreatePage', false);
                    
                    
                    $A.createComponent(
                        "c:SS_SurveyRunnerListViewComp",{
                        },
                        function(newCard, status, errorMessage){
                            
                            if (status === "SUCCESS") {
                                
                                component.set('v.loaded', false);
                                var body = component.get("v.body");
                                body.push(newCard);
                                component.set("v.body", body);
                                
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                            } else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                            }
                        }
                    ); 
                }else{
                    window.open(response.getReturnValue(),'_top');
                }
            }else if (state === "ERROR") {
                debugger;
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(createSurveyRunnerAction);
        
    },
    pullSurveyFromSurveySparrow : function(component, event, helper) {
        
        //Calling apex method to fetch the Survey sparrow records.
        var action = component.get('c.pullSurveysfromSurveySparrow');
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
               
                
                
            }
        });
        $A.enqueueAction(action);
    },
    getSurveyRunnerName : function(component, event, helper){
        debugger;
        var action = component.get('c.getSurveyName');
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
               
               component.set("v.surveyNameList",response.getReturnValue());
                
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
    },
    getSurveyVia : function(component, event, helper){
        var fieldAction = component.get("c.getSurveyViaTypeFields");
        
        var objectName  = component.get("v.dataWrapper");
        
        fieldAction.setParams({
            sobjectName :  objectName.selectedObject,
            viaType     :  objectName.sendSurveyType
        });

        
        fieldAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set('v.sObjectViaTypes',response.getReturnValue());
                component.set("v.loaded",false);
            }
        });
        
        $A.enqueueAction(fieldAction);
    },
    getRateAndCommentsFieldAction :  function(component, event, helper){
         var fieldAction = component.get("c.getRateAndCommentsFields");
         var objectName  = component.get("v.dataWrapper");
        
        fieldAction.setParams({
            sobjectName :  objectName.selectedObject
           
        });
        
         fieldAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var fieldsTypes = response.getReturnValue();
                component.set('v.rateObjectFields',fieldsTypes.rateYourInteractionFieldList);
                component.set('v.commentsObjectFields',fieldsTypes.additionalCommentsFieldList);
            }
        });
        
        $A.enqueueAction(fieldAction);
        
    }
    
})