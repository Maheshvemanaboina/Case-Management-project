/*
@Author     : Rohit Kumar
@CreatedDate: 25-08-2021
@UsedBy     : CaseTriggerHandler
@Description: Validate case fields and prepopulate case fields based on some condition

@History
  25-08-2021   Rohit Kumar : Created
*/


public with sharing class CaseFieldsValidationAndUpdates {
    
    /* @Description
        Method Name : validateAndUpdateFiledsOnBeforeInsert( )

		1.Check entered complaint quantity is less then Order quantity on before insert.
        2.If delivery length is less then 10 digit ,then add extra prefix zero to delivery
          number.
        3.Update unit of measure if delivery and delivery line item is not null.

        @PARAMS
        1.caseList - new case list
	*/   
    public static void validateAndUpdateFiledsOnBeforeInsert(List<Case> caseList){

        Set<String> deliveryAndLineItemSet = new Set<String>();
        List<Case> notificationCaseList = new List<Case>();
        Id notificationCaseRecordTypeId = schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
        Set<String> deliveryNumberSet = new Set<String>();

        for(Case cs:caseList){

            if(cs.Delivery_Number__c != null && cs.RecordTypeId == notificationCaseRecordTypeId){
                if(cs.Delivery_Number__c.length()<10){
                    cs.Delivery_Number__c = '0'+cs.Delivery_Number__c;
                }
            }
            if(cs.RecordTypeId == notificationCaseRecordTypeId && cs.Delivery_Line_Item__c != null && cs.Delivery_Line_Item__c != null){
                deliveryAndLineItemSet.add(cs.Delivery_Number__c + cs.Delivery_Line_Item__c);
                deliveryNumberSet.add(cs.Delivery_Number__c);
                notificationCaseList.add(cs);
            }
        }

        if(!deliveryAndLineItemSet.isEmpty()){
            validateAndUpdateFileds(notificationCaseList,deliveryAndLineItemSet,notificationCaseRecordTypeId,deliveryNumberSet);
        }     
    }

    /* @Description
        Method Name : validateAndUpdateFiledsOnBeforeUpdate( )

		1.Check entered complaint quantity is less then Order quantity on before insert.
        2.Update unit of measure if delivery and delivery line item is not null.

        @PARAMS
        1.caseList - new case list
        2.oldCaseMap -  old case map
	*/  
    public static void validateAndUpdateFiledsOnBeforeUpdate(List<Case> newCaseList,Map<id,Case> oldCaseMap){

        Set<String> deliveryAndLineItemSet = new Set<String>();
        List<Case> notificationCaseList = new List<Case>();
        Id notificationCaseRecordTypeId = schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
        Set<String> deliveryNumberSet = new Set<String>();

        for(Case cs:newCaseList){

            if(cs.RecordTypeId == notificationCaseRecordTypeId && (cs.Complaint_Quantity__c != oldCaseMap.get(cs.id).Complaint_Quantity__c
               ||cs.Delivery_Number__c != oldCaseMap.get(cs.id).Delivery_Number__c || cs.Delivery_Line_Item__c != oldCaseMap.get(cs.id).Delivery_Line_Item__c))
            {
                 	deliveryAndLineItemSet.add(cs.Delivery_Number__c + cs.Delivery_Line_Item__c);
                    notificationCaseList.add(cs);
                	deliveryNumberSet.add(cs.Delivery_Number__c);
            }
        }

        if(!deliveryAndLineItemSet.isEmpty()){
            validateAndUpdateFileds(notificationCaseList,deliveryAndLineItemSet,notificationCaseRecordTypeId,deliveryNumberSet);
        }
        
    }

    public static void validateAndUpdateFileds(List<Case> notificationCaseList,Set<String> deliveryAndLineItemSet,Id notificationCaseRecordTypeId,Set<String> deliveryNumberSet){

        Map<String,Delivery_Line_Item__c> deliveryLineItemMap = new Map<String,Delivery_Line_Item__c>();

        if(!deliveryNumberSet.isEmpty()){
            for(Delivery_Line_Item__c deliveryItem : [SELECT SAP_Delivery_Item_Number__c,SAP_Delivery_Number__c,Order_Delivered_Quantity__c,
                                                      UOM_for_Item_Quantity__c FROM Delivery_Line_Item__c WHERE SAP_Delivery_Number__c
                                                      IN:deliveryNumberSet])
            {
                String sapDeliveryLineItem = deliveryItem.SAP_Delivery_Item_Number__c.right(6);
                
                if(deliveryAndLineItemSet.contains(deliveryItem.SAP_Delivery_Number__c+sapDeliveryLineItem)){
                        deliveryLineItemMap.put(deliveryItem.SAP_Delivery_Number__c+sapDeliveryLineItem,deliveryItem);
                }
               
             }
        }

        if(!deliveryLineItemMap.isEmpty()){
            Decimal orderQuantity;
            String unitOfMeasure;
            for(Case cs: notificationCaseList){
                if(deliveryLineItemMap.containsKey(cs.Delivery_Number__c + cs.Delivery_Line_Item__c)){
                    orderQuantity = deliveryLineItemMap.get(cs.Delivery_Number__c + cs.Delivery_Line_Item__c).Order_Delivered_Quantity__c;
                    unitOfMeasure = deliveryLineItemMap.get(cs.Delivery_Number__c + cs.Delivery_Line_Item__c).UOM_for_Item_Quantity__c;
                }

                if(cs.Complaint_Quantity__c>orderQuantity){
                    cs.Complaint_Quantity__c.addError('Please enter complaint quantity less then Order Quantity');
                }else if(cs.Complaint_Quantity__c == null && orderQuantity != null){
                    cs.Complaint_Quantity__c = orderQuantity;
                    cs.Unit_of_Measure__c = unitOfMeasure;
                }else if(cs.Complaint_Quantity__c != null){
                    cs.Unit_of_Measure__c = unitOfMeasure;
                }
               
            }

        }


    }
}