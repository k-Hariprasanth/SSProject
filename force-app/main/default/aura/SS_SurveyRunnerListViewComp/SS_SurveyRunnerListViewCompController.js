({
	doInit : function(component, event, helper) {
		component.set('v.columns', [
            {fieldName: 'Name', type: 'text'},
            {fieldName: 'SS_Object_Name__c', type: 'text'},
            { type: 'button', typeAttributes: { label: 'Edit', variant:'brand-outline'}}
        ]);

        //Calling apex method to fetch the Survey sparrow records.
        var action = component.get('c.getSparrowTriggerRecords');

        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //Storing the reponse from server side to an attribute.
               component.set('v.loaded', false);
                component.set('v.data', response.getReturnValue());               
            }
        });

        $A.enqueueAction(action);
	},
    editSurveyRunner : function(component, event, helper){
        var b=event.getSource('').get('v.value');
        
        component.set('v.showListView', false);
        component.set('v.showCreatePage', true);
       
        $A.createComponent(
            "c:SS_EditSurveyRunnerComp",{
                surveyRunnerId : b
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
    createSurveyRunner : function(component, event, helper){
        
        component.set('v.showListView', false);
        component.set('v.showCreatePage', true);
       
        $A.createComponent(
            "c:SS_CreateSurveyRunnerComp",{
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
    deleteSurveyRunner : function(component, event, helper){
        var surveyrunnerId = event.getSource('').get('v.value');
        component.set("v.surveyRunnerId",surveyrunnerId);
        component.set("v.showDeleteBox",true);
    },
    handleCancelDelete : function(component, event, helper){
        component.set("v.showDeleteBox",false);
    },
    handleConfirmDelete : function(component, event, helper){
        component.set("v.loaded",true);
        component.set("v.showDeleteBox",false);
        var surveyrunnerId = component.get("v.surveyRunnerId");
        var deleteRunnerAction = component.get("c.deleteRunnerHandler");
        
        deleteRunnerAction.setParams({
            surveyRunnerId :  surveyrunnerId
        });
        
        deleteRunnerAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                location.reload();
            }
        });
        
        $A.enqueueAction(deleteRunnerAction);
    }
})