/*
@Author     : Rohit Kumar
@CreatedDate: 24-05-2021
@UsedBy     : CaseTrigger
@Description: This class will autoassigned case owner if case created by the customer and also update Business segment

@History
  24-05-2021   Rohit Kumar : Created
  17-05-2021   Rohit Kumar : Included check of Delivery Number Check  
*/

public without sharing class ComplaintBusinessSegmentAndOwnerUpdate {
    
    public static void updateBusinessSegmentAndOwnerIfCreatedByCustomer(List<Case> newCaseList){
        
        Id notificationCaseRecordTypeId = schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
        List<Case> notificationCaseList = new List<Case>();
        List<Case> updateNotificationCaseList = new List<Case>();
        Set<Id> accountIdList = new Set<Id>();
        Set<String> deliveryRelatedToCase = new Set<String>();
        Map<String,String> mapDeliveryAndBusinessSegment = new Map<String,String>();
        Map<String,String> mapacountBusinessSegmentToUser = new  Map<String,String>();
        User currentUser = [SELECT id,ContactId,ProfileId FROM User WHERE id =:userinfo.getUserId()];
        QueueSObject QueueID = [Select id,Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE SobjectType = 'case' AND Queue.Type ='Queue' AND Queue.Name = 'Notification Queue' Limit 1];
        Boolean isCommunityUser = false;
        
        if(currentUser.Contactid!=null){
            isCommunityUser=true;
        }
        
        Global_Automation_Setting__c globalSetting =  Global_Automation_Setting__c.getInstance(currentUser.ProfileId);
        
        for(Case cs: newCaseList){
            
            if(cs.RecordTypeId.equals(notificationCaseRecordTypeId)){
               String deliveryNumber = cs.Delivery_Number__c;

                if(deliveryNumber.length()<10){
                    deliveryNumber='0'+cs.Delivery_Number__c;
                }
                accountIdList.add(cs.AccountId);
                deliveryRelatedToCase.add(deliveryNumber);
                notificationCaseList.add(cs);
            }
        }
                
        for(Delivery__c DL:[SELECT id,Sold_To__c,SAP_Delivery_Number__c,(SELECT id,Delivery__r.SAP_Delivery_Number__c,Sales_Order_number__r.Business_Segment__c FROM Delivery_Line_Items__r LIMIT 1) FROM Delivery__c WHERE SAP_Delivery_Number__c IN:deliveryRelatedToCase AND  Sold_To__c IN:accountIdList]){
            for(Delivery_Line_Item__c deliveryLineItem: DL.Delivery_Line_Items__r){
                if(deliveryLineItem.Sales_Order_number__r.Business_Segment__c!=null){
                    mapDeliveryAndBusinessSegment.put(DL.SAP_Delivery_Number__c,deliveryLineItem.Sales_Order_number__r.Business_Segment__c);
                }
            }
        }
        
        if(!mapDeliveryAndBusinessSegment.isEmpty() && currentUser.ContactId!=null ){
            for(AccountTeamMember accountteam:[SELECT Id,AccountId,primary__c,UserId,User.IsActive,Business_Segment__c,TeamMemberRole FROM AccountTeamMember WHERE AccountId IN: accountIdList AND primary__c = true AND Business_Segment__c IN:mapDeliveryAndBusinessSegment.values() AND TeamMemberRole='CMO' AND User.IsActive=true]){
                if(accountteam.Business_Segment__c!=null)
                    mapacountBusinessSegmentToUser.put(accountteam.accountid+accountteam.Business_Segment__c,accountteam.userId);
                
            }
        }
         
        for(Case caseRecord :notificationCaseList){
            
            Case caseRecordToUpdate = new Case();
            caseRecordToUpdate = caseRecord.clone();
            String deliveryNumber = caseRecord.Delivery_Number__c;
            
            if(deliveryNumber.length()<10){
                deliveryNumber = '0'+deliveryNumber;
            }
            caseRecordToUpdate.Delivery_Number__c = deliveryNumber;
            caseRecordToUpdate.id = caseRecord.id;
          
            
            if(!mapDeliveryAndBusinessSegment.isEmpty() && mapDeliveryAndBusinessSegment.containskey(deliveryNumber)){
                caseRecordToUpdate.Business_Segment__c = mapDeliveryAndBusinessSegment.get(deliveryNumber);
            }
            
            if(isCommunityUser && caseRecordToUpdate.Business_Segment__c!=null && !mapacountBusinessSegmentToUser.isEmpty() && mapacountBusinessSegmentToUser.containsKey(caseRecordToUpdate.AccountId+caseRecordToUpdate.Business_Segment__c)){
                caseRecordToUpdate.OwnerId = mapacountBusinessSegmentToUser.get(caseRecordToUpdate.AccountId+caseRecordToUpdate.Business_Segment__c);
            }
            else if(isCommunityUser){
                caseRecordToUpdate.OwnerId = QueueID.Queue.id;
            }
            if(caseRecordToUpdate.Business_Segment__c!=null || isCommunityUser || !deliveryNumber.equals(caseRecord.Delivery_Number__c)){
                updateNotificationCaseList.add(caseRecordToUpdate);
            }
            
        }
        
        if(isCommunityUser && !globalSetting.Skip_Validation_Rule__c && updateNotificationCaseList.size()>0){
            globalSetting.Skip_Validation_Rule__c = true;
            UPDATE globalSetting;
        }
        
        if(updateNotificationCaseList.size()>0){
            UPDATE updateNotificationCaseList; 
        }
        
        if(isCommunityUser && globalSetting.Skip_Validation_Rule__c && updateNotificationCaseList.size()>0){
            globalSetting.Skip_Validation_Rule__c = false;
            UPDATE globalSetting;
        }
    }
    
}