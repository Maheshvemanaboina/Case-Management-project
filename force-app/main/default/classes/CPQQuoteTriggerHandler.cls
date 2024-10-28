/*------------------------------------------------------------  
Author:       João Almeida
Company:      Cognizant
Description:  handles CPQ quote trigger actions
Test Class: CPQQuoteTriggerHandlerTest

History
2023-03-20    João Almeida    Created class
2023-03-23    João Almeida    changed the class to extends the generic LinkTriggerHandler
2023-04-27    João Almeida    Added new methods for before update handling and after update handling
------------------------------------------------------------*/
public without sharing class CPQQuoteTriggerHandler extends LinkTriggerHandler {
    private List<SBQQ__Quote__c> newRecords;
    private Map<Id, SBQQ__Quote__c> newMap;
    private Map<Id, SBQQ__Quote__c> oldMap;
    private CPQQuoteTriggerHandlerLogic triggerLogic;

    public CPQQuoteTriggerHandler() {
        this.newRecords = (List<SBQQ__Quote__c>) Trigger.new;
        this.newMap = (Map<Id, SBQQ__Quote__c>) Trigger.newMap;
        this.oldMap = (Map<Id, SBQQ__Quote__c>) Trigger.oldMap;
        this.triggerLogic = new CPQQuoteTriggerHandlerLogic();
    }

    /*
	   @Description: call methods before insert
	 */
	public override void beforeInsert(){
        //add methods before insert
    }
    
    /*
	@Description: call methods after insert
	 */
	public override void afterInsert(){
        //add methods after insert
    }

	/*
	   @Description: call methods before update
	 */
	public override void beforeUpdate(){
        //add methods before update
        this.triggerLogic.setOldTriggeredRecords(this.oldMap);
        this.triggerLogic.setNewTriggeredRecords(this.newRecords);
        this.triggerLogic.handleQuoteMandatoryFieldsValidation();
        this.triggerLogic.handleBeforeUpdateActions();
	}
	/*
	   @Description: call methods after update
	 */
	public override void afterUpdate(){
        //add methods after update
        this.triggerLogic.setOldTriggeredRecords(this.oldMap);
        this.triggerLogic.setNewTriggeredRecords(this.newRecords);
        this.triggerLogic.handleAfterUpdateActions();
	}

	/*
	   @Description: call methods before delete
	 */
	public override void beforeDelete(){
        //add methods before delete
		
	}

	/*
	   @Description: call methods after delete
	 */
	public override void afterDelete(){
        //add methods after delete
		
	}

	/*
	   @Description: call methods after undelete
	 */
	public override void afterUndelete(){
        //add methods after undelete
		
	}
}