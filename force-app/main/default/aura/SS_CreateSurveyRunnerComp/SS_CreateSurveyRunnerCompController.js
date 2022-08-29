({
    initobjectGetter : function(component, event, helper){
        helper.pullSurveyFromSurveySparrow(component, event, helper);
        helper.getSurveyRunnerName(component, event, helper);
        var objectaction = component.get("c.getObjectAndSurvey");
        
        objectaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.dataWrapper',response.getReturnValue());
                component.set("v.loaded",false);
                console.log(component.get('v.dataWrapper'));
            }
        });
        
        $A.enqueueAction(objectaction);
             
    },
    showLookupBox : function(component, event, helper) {
        

        var checkCmp = component.find("chkbox").get("v.checked");
       
        console.log('---------------',checkCmp);
        if(checkCmp == false){
           component.set("v.showLookUp",false); 
        }else{
            component.set("v.showLookUp",true);
        }
        
	},
    createSurveyRunner : function(component, event, helper){
        debugger;
        var validExpense = component.find('validData').reduce(function ( validSoFar, inputCmp ) {
            inputCmp.showHelpMessageIfInvalid();
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
                helper.createSurveyRunnerRecord(component, event, helper);
            }
        }
        
    },
    createSurveyRunnerLaunchFlow : function(component, event, helper){
       var validExpense = component.find('validData').reduce(function ( validSoFar, inputCmp ) {
            inputCmp.showHelpMessageIfInvalid();
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
                component.set("v.lauchFlow",true);
                helper.createSurveyRunnerRecord(component, event, helper);
            }
        }
    },
    backToRunnerList : function(component, event, helper){
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
    },
    getObjectFields : function(component, event, helper){
        component.set("v.loaded",true);
        debugger;
       
        helper.gettingSurveyLookUpFields(component, event, helper);
        helper.getSurveyVia(component, event, helper);
        helper.getRateAndCommentsFieldAction(component, event, helper);
        var fieldAction = component.get("c.getSelectedObjectFields");
        
        var objectName  = component.get("v.dataWrapper");
        fieldAction.setParams({
            sobjectName :  objectName.selectedObject
        });

        
        fieldAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
                
                var selectedSobjectFields = response.getReturnValue();
                var fieldsArray = [];
                var fieldsListArray = [];
                for(var i = 0 ; i < selectedSobjectFields.length ; i++){
                    var field = selectedSobjectFields[i];
                    fieldsListArray.push(field.fieldApiName);
                    if(field.fieldApiName == 'Id'){
                        var obj = {
                                fieldApiName : field.fieldApiName,
                                isSelected   : true,
                                disabledValue: true,
                           	    
                            }
                        fieldsArray.push(obj);
                    }else{
                        var obj = {
                                fieldApiName : field.fieldApiName,
                                isSelected   : field.isSelected,
                                disabledValue: false
                            }
                        fieldsArray.push(obj);
                    }
                    
                }
                component.set('v.fieldsNameList',fieldsArray);
                component.set("v.objectFields",fieldsListArray);
                component.set("v.loaded",false);
            }
        });
        
        $A.enqueueAction(fieldAction);
    },
    sendSurveyViaTypeFields : function(component, event, helper){
        component.set("v.loaded",true);
        
        helper.getSurveyShareTypeTemplate(component, event, helper);
        helper.getSurveyVia(component, event, helper);
        
    }
})