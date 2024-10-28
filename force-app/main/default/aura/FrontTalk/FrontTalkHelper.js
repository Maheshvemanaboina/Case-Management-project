({
    getrespective : function(component, event, helper) {
        //var action = component.get("c.getfile");
        var r = component.get('v.recordId');
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //alert('response');
               console.log(response.getReturnValue());
                var val=response.getReturnValue();
                if(val=='Food & Beverages'){
                    component.set('v.iFrameSrc','https://fci--Test.cs89.my.salesforce.com/sfc/p/0E000000D1Hf/a/0E000000Cvye/Lb8vqG5oktm9U23BBhA.Pfjml6Tx22CBz2Tdc2XOzL0');
                
                 }else if(val=='Adult Nutrition'){
                      component.set('v.iFrameSrc','https://fci--Test.cs89.my.salesforce.com/sfc/p/0E000000D1Hf/a/0E000000Cvyo/OdYK7fAEUBfDvTntBQkMlacwGfIB2i.0cMIHmnD0V.M');

                }else if(val=='Early Life Nutrition & Cell Nutrition'){
                      component.set('v.iFrameSrc','https://fci--Test.cs89.my.salesforce.com/sfc/p/0E000000D1Hf/a/0E000000Cvyj/pM0ZkMt61YUXi2xLB3i4VlFLYDXriV5EaBqs1HdCXUY');

                }
                else if(val=='Animal Nutrition'){
                      component.set('v.iFrameSrc','https://fci--Test.cs89.my.salesforce.com/sfc/p/0E000000D1Hf/a/0E000000Cvz3/NjbGIBcnoiXKjC5NPfN7ytF2aCFYfXqRgcdyf7M03nw');

                }
                else if(val=='Milkpowder'){
                      component.set('v.iFrameSrc','https://fci--Test.cs89.my.salesforce.com/sfc/p/0E000000D1Hf/a/0E000000Cvyj/pM0ZkMt61YUXi2xLB3i4VlFLYDXriV5EaBqs1HdCXUY');

                }else if(val=='Cheese'){
                      component.set('v.iFrameSrc','https://fci--Test.cs89.my.salesforce.com/sfc/p/0E000000D1Hf/a/0E000000Cvyp/f9R26L1CTo5qT4j6t0sm6kXq0t7Xx7nrRbJCdRv6qXE');

                }else if(val=='Butter'){
                      component.set('v.iFrameSrc','https://fci--Test.cs89.my.salesforce.com/sfc/p/0E000000D1Hf/a/0E000000Cvyt/hI0ah0tUdN3u9dCe8brrNR_33ohJ0aOLapKgzFYrxWo');

                }else if(val=='Export'){
                      component.set('v.iFrameSrc','https://fci--Test.cs89.my.salesforce.com/sfc/p/0E000000D1Hf/a/0E000000Cvyy/ZaXX00jU0Zb1VV9S.D8HcqVx1b5ZZkldsqoVkYj0C_g');

                }
            }
        });
        $A.enqueueAction(action);
    }
   
    
})