/*       
@Name           - TriggerHandler
@Author         - Krzysztof Magdowski | Email - krzysztof.magdowski@waeg.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 15-07-2019
@UsedBy         - All TriggerHandler Classes for objects
@Description    - 1. Extended by all trigger handler classes.
                  2. This has 6 virtual methods that has to be overriden by the class extending it to use it.
                  3. 6 virtual methods are:
                    a. processBeforeInsert
                    b. processAfterInsert
                    c. processBeforeUpdate
                    d. processAfterUpdate
                    e. processBeforeDelete
                    f. processAfterDelete
                  4. Any Trigger handler class can override any of the above methods and can write the logic inside it.
                  5. For Example: overriding "processBeforeInsert" will run the trigger in before insert context.
                  6. It makes use of a custom metadata type called "Trigger_Setting__mdt" (Trigger Setting) to control activation and deactivation of a trigger

@Changes
UserId              | Author-Email                          | Date          | Comment
====================|=======================================|===============|=========
0054H000005dHBKQA2  | krzysztof.magdowski@waeg.com          | 15-07-2019    | Created Class
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 04-02-2020    | Updated line 83 to use MasterLabel in SOQL instead of Name field 
*/

public without sharing virtual class TriggerHandler {

    @TestVisible private static Boolean skipTrigger = false; // used to skip the running trigger in test class if not required to run everytime

    /* @Description
        Method Name : process()

        1. This is the main method that checks if a trigger is active in custom metadata (Trigger Setting).
        2. Checks the context and fires the appropriate overriden method.
    */

    public void process() {
        if (!isTriggerActive()) {
            return;
        }

        if(trigger.isBefore) {
            if (trigger.isInsert) {
                processBeforeInsert(); // virtual method
            }
            if (trigger.isUpdate) {
                processBeforeUpdate(); // virtual method
            }
            if (trigger.isDelete) {
                processBeforeDelete(); // virtual method
            }
        }

        if(trigger.isAfter) {
            if (trigger.isInsert) {
                processAfterInsert(); // virtual method
            }
            if (trigger.isUpdate) {
                processAfterUpdate(); // virtual method
            }
            if (trigger.isDelete) {
                processAfterDelete(); // virtual method
            }
             if (trigger.isUndelete) {
                processAfterUnDelete(); // virtual method
            }
        }
    }

    /* @Description
        1. These are the 6 virtual methods which will be overriden by triggerhandler classes
    */

    public virtual void processBeforeInsert(){}
    public virtual void processBeforeUpdate(){}
    public virtual void processBeforeDelete(){}
    public virtual void processAfterInsert(){}
    public virtual void processAfterUpdate(){}
    public virtual void processAfterDelete(){}
    public virtual void processAfterUnDelete(){}

    /* @Description
        Method Name: isTriggerActive()
        1. Checks if an Trigger is active on based on the record created in the trigger setting custom metadata for that Object
        2. if no record is present in custom metadata for that object, by default trigger is treated as active

        @return BOOLEAN
                1. returns true if "Active__c" is true in the trigger setting
                2. returns false if "Active__c" is false in the trigger setting
    */

    private Boolean isTriggerActive() {
        if (skipTrigger) {
            return false;
        }

        String objName;
        if (trigger.isDelete) {
            objName = trigger.old.get(0).getSObjectType().getDescribe().localName;
        } else {
            objName = trigger.new.get(0).getSObjectType().getDescribe().localName;
        }

        List<Trigger_Setting__mdt> trgSetting = [
                SELECT Id, Active__c
                FROM Trigger_Setting__mdt
                WHERE MasterLabel = :objName
        ];

        if (trgSetting.isEmpty()) {
            return true;
        }

        return trgSetting.get(0).Active__c;
    }
}