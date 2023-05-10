({
	doInit : function(component, event, helper) {
		var action = component.get("c.calculateFromLightning");
        action.setParams({
             recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            
           	var state = response.getState();
            console.log(state);
            if (state === "SUCCESS"){
           		var serverResponse = response.getReturnValue();
                console.log(serverResponse);
               	alert(serverResponse);
                location.reload();
           	}
            else if (state == "ERROR") {
               	var serverError = response.getError();
                console.log(serverError);
            	alert(serverError);
            }
        });
        $A.enqueueAction(action);
	}
})