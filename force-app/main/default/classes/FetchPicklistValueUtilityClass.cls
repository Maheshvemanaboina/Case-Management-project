//This class has been written in order to use the method to fetch picklist values in test class and other
//classes to remove the hard coded values.
public without sharing class FetchPicklistValueUtilityClass {
    
    public static List<String> fetchPickListValues(Schema.SObjectField fieldName){
        List<String> pickListValues = new List<String>();
            Schema.DescribeFieldResult fldRes = fieldName.getDescribe();
            System.debug('fldRes: '+fldRes);
            for(Schema.PicklistEntry entryLabel :  fldRes.getPicklistValues()){
                if(entryLabel.isActive()){
                    pickListValues.add(entryLabel.getValue()); 
                }
            }
        
        return pickListValues;
    }
    public static Map<String,List<String>> fetchControllerDependentPicklist(Schema.SObjectField dependentPicklistName){
        Map<String,Schema.SObjectType> sObjMap = new Map<String,Schema.SObjectType>();
        Map<String,Schema.SObjectField> sObjFieldMap = new Map<String,Schema.SObjectField>();
        List<WrapPickList> dependentPicklist = new List<WrapPickList>();
        List<WrapPickList> parentPicklist = new List<WrapPickList>();
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        Map<String,List<String>> mappedPickListValue = new Map<String,List<String>>();
        Map<String,Object> mpV = new Map<String,Object>();
        WrapPickList wrapObj;
        for(Schema.PicklistEntry entry : dependentPicklistName.getDescribe().getPicklistValues()){
            if(entry.isActive()){
                wrapObj = new WrapPicklist();
                wrapObj = (WrapPicklist)JSON.deserialize(JSON.serialize(entry), WrapPicklist.class);
                dependentPicklist.add(wrapObj);
                if(!dependentPicklistValues.isEmpty() && dependentPicklistValues.containsKey(wrapObj.validFor)){
                    dependentPicklistValues.get(wrapObj.validFor).add(wrapObj.label);
                }
                else{
                    dependentPicklistValues.put(wrapObj.validFor , new List<String>{wrapObj.label});
                }
            }  
        }
        Schema.SObjectField controlField = dependentPicklistName.getDescribe().getController() !=NULL ? dependentPicklistName.getDescribe().getController() : NULL;
        if(controlField !=NULL){
            for(Schema.PicklistEntry entry : controlField.getDescribe().getPicklistValues()){
                parentPicklist.add((WrapPicklist)JSON.deserialize(JSON.serialize(entry), WrapPicklist.class));
            }
        }
        if(dependentPicklist.size() >0 && parentPicklist.size()>0){
            for(WrapPickList child : dependentPicklist){
                List<String> baseKey = child.validFor.split('');
                for(Integer index =0 ;index < parentPicklist.size();index++){
                    Object control = parentPicklist[index].label;
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                    if(control == null || (base64map.indexOf( baseKey[ bitIndex ] ) & (1 << bitShift)) == 0) 
                        continue;
                    mpV.put(child.validFor,control);
                }
            }
        }
        if(!dependentPicklistValues.isEmpty()){
            for(String validFor : dependentPicklistValues.keySet()){
                if(mpV.containsKey(validFor)){
                   mappedPickListValue.put(String.valueOf(mpV.get(validFor)) , dependentPicklistValues.get(validFor));
                }
            }
        }
        System.debug('mappedPickListValue:: '+mappedPickListValue);
        return mappedPickListValue;
    }

     public class WrapPickList{
        public Boolean active;
        public String validFor;
        public String value;
        public String defaultValue;
        public String label;
    }
    

}