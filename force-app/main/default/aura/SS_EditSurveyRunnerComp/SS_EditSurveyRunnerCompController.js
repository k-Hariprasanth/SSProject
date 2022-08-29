({
    initobjectGetter : function(component, event, helper) {
	    debugger;
        
        var recordaction = component.get("c.getSurveyRunnerRecord");
        var recordId = component.get("v.surveyRunnerId");
        recordaction.setParams({
            surveyRunnerId :  recordId
        });

        recordaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.dataWrapper',response.getReturnValue());
                component.set("v.loaded",false);
                var wrapperdata = component.get('v.dataWrapper');
                component.set("v.sObjectViaFields",wrapperdata.shareTypeObjectFields);
                component.set("v.surveyShareTypeTemp",wrapperdata.surveyShareTypeList);
                component.find("chkbox").set("v.checked",wrapperdata.isEnabledLookup);
                component.set("v.showLookUp",wrapperdata.isEnabledLookup);
                debugger;
                var oldselectedSobjectFields = wrapperdata.selectedFieldWrapper;
                var fieldsArray = [];
                
                for(var i = 0 ; i < oldselectedSobjectFields.length ; i++){
                    var field = oldselectedSobjectFields[i];
                    
                    if(field.isSelected == true){
                        fieldsArray.push(field.fieldApiName);
                    }
                    
                }
                component.set("v.oldObjectFieldList",fieldsArray);
                helper.getSurveyRunnerName(component, event, helper);
                
            }
        });
        
        $A.enqueueAction(recordaction); 
    },
    backToRunnerList : function(component, event, helper){
        component.set("v.loaded",true);
        component.set('v.showListView', true);
        component.set('v.showEditPage', false);
       
        
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
    },
    sendSurveyViaTypeFields : function(component, event, helper){
        component.set("v.loaded",true);
        helper.getSurveyShareTypeTemplate(component, event, helper);
        var fieldAction = component.get("c.getSurveyViaTypeFields");
        
        var objectName  = component.get("v.dataWrapper");
        
        fieldAction.setParams({
            sobjectName :  objectName.selectedObject,
            viaType     :  objectName.sendSurveyType
        });

        
        fieldAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                console.log(response.getReturnValue());
                component.set("v.sObjectViaFields",response.getReturnValue());
                component.set("v.loaded",false);
            }
        });
        
        $A.enqueueAction(fieldAction);
    },
    showLookupBox : function(component, event, helper){
        var checkCmp = component.find("chkbox").get("v.checked");
       
        console.log('---------------',checkCmp);
        if(checkCmp == false){
           component.set("v.showLookUp",false); 
        }else{
            component.set("v.showLookUp",true);
        }
    },
    updateSurveyRunner  : function(component, event, helper){
        component.set("v.loaded",true); 
        var validExpense = component.find('validData').reduce(function ( validSoFar, inputCmp ) {
            inputCmp.showHelpMessageIfInvalid();
            component.set("v.loaded",false);
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(validExpense){
            
            component.set("v.loaded",true);
            var surveyRunnerNameList = component.get("v.surveyNameList");
            var wrap = component.get("v.dataWrapper");
            
            var isFound = false;
            
            if(surveyRunnerNameList.includes(wrap.runnerName)){
                isFound = true;
            }
            
            
            if(isFound){
                component.set("v.loaded",false);
                alert("Duplicate Found SurveyRunner Name \' "+wrap.runnerName+"\'");
                return;
            }else{
                helper.updateSurveyRunnerRecord(component, event, helper);
            }
        }
    }
})