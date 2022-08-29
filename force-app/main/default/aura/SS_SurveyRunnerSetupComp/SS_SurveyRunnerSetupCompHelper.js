({
	createIntegrateManage : function(component, event, helper) {
		
        var updateOauthUrlAction = component.get("c.updateSurveyOAuthUrl");
        var surveyOauth = '';
        
        updateOauthUrlAction.setParams({
            surveyOauthURL :  surveyOauth
        });
		updateOauthUrlAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
               
            }
            
        });
        
        $A.enqueueAction(updateOauthUrlAction);
	},
    getDataCenterValue : function(component, event, helper){
        var getDataCenterAction = component.get("c.getDataChoosenValue");
        
        getDataCenterAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
               component.set('v.dateCenterValue',response.getReturnValue());
                 component.set("v.showLoadedSpin",false);
            }
            
        });
        
        $A.enqueueAction(getDataCenterAction);
    }
})