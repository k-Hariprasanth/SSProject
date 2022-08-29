({
    getIsConnect : function(component, event, helper) {
        helper.createIntegrateManage(component, event, helper);
        var getIsSurveyConnect = component.get("c.isSurveyConnect");
        
        getIsSurveyConnect.setCallback(this, function(response) {
            
            var state = response.getState();
           
            if (state === "SUCCESS") {
                if(response.getReturnValue() == true){
                    component.set("v.showConnectSurvey",false);
                    component.set("v.showDisConnectSurvey",true);
                  helper.getDataCenterValue(component, event, helper);
                }else{
                     component.set("v.showLoadedSpin",false);
                    component.set("v.showConnectSurvey",true);
                    component.set("v.showDisConnectSurvey",false);
                }  
            }
            
        });
        
        $A.enqueueAction(getIsSurveyConnect);
    },
    connectToSurvey : function(component, event, helper) {
        component.set("v.showLoadedSpin",true);
        
        var updateOauthUrlAction = component.get("c.updateSurveyOAuthUrl");
        var surveyOauth = component.get("v.surveyURL");
        
        updateOauthUrlAction.setParams({
            surveyOauthURL :  surveyOauth
        });

        updateOauthUrlAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                let urlString = window.location.href;
                console.log(urlString);
                urlString = urlString.substring(0, urlString.indexOf('.com')+4);
                
                window.open(urlString+"/apex/SSPR__SS_SurveySparrowOAuthPage","_top"); 
            }
            
        });
        
        $A.enqueueAction(updateOauthUrlAction);
    },
    handleConfirmDialogCancel : function(component, event, helper){
        component.set("v.showConfirmDisconnect",false);
        
    },
    DisconnectToSurvey : function(component, event, helper){
        component.set("v.showConfirmDisconnect",true);
    },
    conformDisconnectSurvey  : function(component, event, helper){
        component.set("v.showLoadedSpin",true);
        var disConnectSurveyAction = component.get("c.disConnectSurvey");
        
        disConnectSurveyAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                location.reload();
            }
            
        });
        
        $A.enqueueAction(disConnectSurveyAction);
    }
    
})