({
	init : function(component){
      var output = component.find("input1value").get("v.varinput1value");
       console.log(output);
      component.set("v.varinput1value", output );  
    },
    
    keyCheck : function(component, event, helper){
    if (event.which == 13){
        var input1value = component.find("input1value");
        if(!input1value.checkValidity() == false) {
        var navigate = component.get('v.navigateFlow');
     	navigate("NEXT");
        }
    }
    }    
    
})