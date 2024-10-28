//helper class to populate the supplier reference for following objects.
public without sharing class PopulateSupplierReference {
    public static Map<String, String> ObjectVsSupplierFieldMap = new Map<String, String>{
        'Supplier_Team__c' => 'Supplier_Hub__c',
            'Meeting_Notes__c' => 'Supplier_Hub_Number__c',
            'Meeting_Structure__c' => 'Supplier_Hub_Number__c',
            'Contingency_Plan__c' => 'Supplier_Hub__c',
            'Supplier_Contract__c' => 'Supplier_Hub__c',
            'Supplier_Project__c' => 'Supplier__c',
            'Supplier_Location__c' => 'Supplier_Hub__c',
            'Joint_Business_Plan__c' => 'Supplier_Hub__c',
            'Complaints__c' => 'Supplier__c',
            'Supplier_KPI__c' => 'Supplier_Hub__c',
            'Supplier_Rating__c' => 'Supplier_Hub__c',
            'Supplier_Hub__c' => 'Id',
            'Claim__c'=>'Supplier__c'};
    //method popualtes the supplier Id before insert and update event.    
    public static void populateSupplier(List<Task> newList){
        Id currentUserProfileId = UserInfo.getProfileId();
		Id userId = userinfo.getUserId();
		String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;
                system.debug('profile name '+ profileName);
                if(profileName == '' || profileName == ''){
                    
                }
        Map<String, List<Task>> whatIdsVsTaskRecords = new Map<String, List<Task>>();
        Set<Id> relatedWhatIds = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        Map<Id, sObject> relatedObjMap = new Map<Id, sObject>();
        Id supplierRecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        for(Task objTask: newList){
            if(objTask.WhatId != NULL && objTask.RecordTypeId == supplierRecordTypeId && (profileName != '' || profileName != '')){
                String sObjName = objTask.WhatId.getSObjectType().getDescribe().getName();                
                if(objTask.WhatId != NULL && whatIdsVsTaskRecords.containsKey(sObjName)){
                    whatIdsVsTaskRecords.get(sObjName).add(objTask);
                }else{
                    whatIdsVsTaskRecords.put(sObjName, new List<Task>{objTask});                
                }
            }
            if(trigger.isBefore && trigger.isUpdate && objTask.RecordTypeId == supplierRecordTypeId){
                if(objTask.WhatId == null){
                    objTask.Supplier__c = null;
                }
            }
        }
        if(! whatIdsVsTaskRecords.isEmpty()){
            for(String sobjectName : whatIdsVsTaskRecords.KeySet()){
                for(Task objTask: whatIdsVsTaskRecords.get(sobjectName)){                    
                    relatedWhatIds.add(objTask.WhatId);
                }
                if(relatedWhatIds != NULL){
                    //query added in for loop because, this needs to run for all the sObjects in context Max-10 objs.
                    Set<String> relatedObjectName = new Set<String>();
                    relatedObjectName = ObjectVsSupplierFieldMap.keySet();
                    if(relatedObjectName.contains(sobjectName)){
                        List<sObject> relatedRecords = gerRelatedTo(sobjectName, ObjectVsSupplierFieldMap.get(sobjectName), relatedWhatIds);
                        if(relatedRecords != NULL){
                            for(sObject objRec: relatedRecords){
                                relatedObjMap.put(objRec.Id, objRec);
                            }
                        }
                    }                    
                }
                
                if(relatedObjMap != NULL && ! relatedObjMap.isEmpty()){
                    for(Task objTask: newList){
                        String sObjectNme = objTask.WhatId.getSObjectType().getDescribe().getName();
                        String fieldName = ObjectVsSupplierFieldMap.get(sObjectNme);
                        sObject relatedParentRecord = relatedObjMap.get(objTask.WhatId);
                        Object SupplierId = relatedParentRecord.get(fieldName);
                        objTask.Supplier__c = String.valueOf(SupplierId);
                        system.debug('objTask.Supplier__c '+ objTask.Supplier__c);
                    }
                }
            }
        }
    }
    //method queries the related whatid records to get the related supplier on Task object
    public static List<sObject> gerRelatedTo(String objName, String relatedLookupFiledName, Set<Id> whatIds){
        if(objName == 'Supplier_Hub__c'){
            String query = 'SELECT Id ';
            query = query + ' FROM ' + objName + ' WHERE Id IN:  whatIds';
            return Database.query(query);
        }else{
            String query = 'SELECT Id, ';
            query = query + relatedLookupFiledName;
            query = query + ' FROM ' + objName + ' WHERE Id IN:  whatIds';
            system.debug('query '+ query);
            return Database.query(query);
        }        
    }
    public static void populateSupplierforPartners(List<Task> newList){
        Id currentUserProfileId = UserInfo.getProfileId();
        Id userId = userinfo.getUserId();
        String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;
        system.debug('profile name '+ profileName);
        if(profileName == 'SRM Partner Community User' || profileName == 'SRM Partner Community Login User'){
            List<User> objUser = [SELECT Id, ContactId from User where id =: userinfo.getUserId()];
            if(! objUser.isEmpty()){
                Contact objContact = [SELECT Id, AccountId FROM Contact WHERE Id =: objUser[0].contactId LIMIT 1];
                if(objContact != NULL){
                    Supplier_Hub__c supplierId = [SELECT Id from Supplier_Hub__c where Supplier_Account__c  =: objContact.AccountId];
                    for(Task objTask: newList){
                        if(profileName == 'SRM Partner Community User' || profileName == 'SRM Partner Community Login User'){
                            objTask.WhatId = supplierId.Id;
                        }
                    }
                }
            }
        }        
    }
    //method used to pupulate the value element, comment and location on task
    public static void popualteRatingRelatedFields(List<Task> newTasks){
        Set<Id> relatedToIds = new Set<Id>();
        Map<Id, Task> relatedToVsTaskMap = new Map<Id, Task>();
        Map<Id, Supplier_Rating__c> relatedRatings = new Map<Id, Supplier_Rating__c>();
        for(Task objTask: newTasks){
            if(objTask.WhatId != NULL){
                String sObjName = objTask.WhatId.getSObjectType().getDescribe().getName();
                system.debug('sObjName '+ sObjName);
                if(sObjName == 'Supplier_Rating__c' ){
                    relatedToIds.add(objTask.WhatId);
                    relatedToVsTaskMap.put(objTask.WhatId, objTask);
                }
            }
        }
        if(relatedToIds != null){
			relatedRatings = new Map<Id, Supplier_Rating__c>([SELECT id , Value_Element__r.Name, Comment__c, Location__r.Name from Supplier_Rating__c WHERE Id IN: relatedToIds ]);
        }
        if(! relatedToVsTaskMap.isEmpty()){
            for(Task objTaskInContext: relatedToVsTaskMap.values()){
                objTaskInContext.Value_Element__c = relatedRatings.get(objTaskInContext.whatId).Value_Element__r.Name;
                 objTaskInContext.Associated_Location__c = relatedRatings.get(objTaskInContext.whatId).Location__r.Name;
                 //objTaskInContext.Rating_Comments__c = relatedRatings.get(objTaskInContext.whatId).Comment__c;
            }
        }
    }
    
}