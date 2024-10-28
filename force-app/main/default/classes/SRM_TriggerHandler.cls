/* *******************************************************************************************************
 * Name               : SRM_TriggerHandler                                                                   *
 * Description        : SRM - Generic handler for triggers                                                     *
 * Created Date       : 06-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
//RFC already had class named SRM_TriggerHandler, so had to change name - when developing managed package change it to SRM_TriggerHandler.cls
public virtual without sharing class SRM_TriggerHandler {

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    private String triggerName;
    private static Map<String, SRM_Trigger_Controller__mdt> triggerName2TriggerControllerMap;

    @TestVisible
    private static User currentUser;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
        currentUser = [SELECT Disable_All_Triggers__c, Disable_Listed_Triggers__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        triggerName2TriggerControllerMap = new Map<String, SRM_Trigger_Controller__mdt>();
        for(SRM_Trigger_Controller__mdt stc : [SELECT SRM_Disable_Trigger__c, SRM_Trigger_Name__c FROM SRM_Trigger_Controller__mdt]) {
            triggerName2TriggerControllerMap.put(stc.SRM_Trigger_Name__c, stc);
        }
    }

    // constructor
    public SRM_TriggerHandler() {
        this.setTriggerContext();
    }
    // constructor with trigger name passed on
    public SRM_TriggerHandler(String triggerName) {
        this();
        this.triggerName = triggerName;
    }

    public static Boolean isTriggerEnabled(String triggerName) {
        Boolean result = true;
        if (currentUser.Disable_All_Triggers__c == true) {
            result = false;
        } else if (String.isNotEmpty(currentUser.Disable_Listed_Triggers__c) && currentUser.Disable_Listed_Triggers__c.contains(triggerName)) {
            result = false;
        } else if (!triggerName2TriggerControllerMap.isEmpty() && triggerName2TriggerControllerMap.containsKey(triggerName) && triggerName2TriggerControllerMap.get(triggerName).SRM_Disable_Trigger__c) {
            result = false;
        }

        return result;
    }

    /***************************************
     * public instance methods
     ***************************************/

    // main method that will be called during execution
    public void run() {

        if(!validateRun()) return;

        addToLoopCount();

        // dispatch to the correct handler method
        if(this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        } else if(this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        } else if(this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        } else if(this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        } else if(this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
        } else if(this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        } else if(this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }

    }

    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!SRM_TriggerHandler.loopCountMap.containsKey(handlerName)) {
            SRM_TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            SRM_TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    /***************************************
     * public static methods
     ***************************************/

    public static void bypass(String handlerName) {
        SRM_TriggerHandler.bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName) {
        SRM_TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    public static Boolean isBypassed(String handlerName) {
        return SRM_TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    public static void clearAllBypasses() {
        SRM_TriggerHandler.bypassedHandlers.clear();
    }

    /***************************************
     * private instancemethods
     ***************************************/

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')){
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(SRM_TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = SRM_TriggerHandler.loopCountMap.get(handlerName).increment();
            if(exceeded) {
                Integer max = SRM_TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if(!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        if(SRM_TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }

    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    /***************************************
     * context methods
     ***************************************/

    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}

    /***************************************
     * inner classes
     ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            if(this.max < 0) return false;
            if(this.count > this.max) {
                return true;
            }
            return false;
        }

        public Integer getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

    // exception class
    public class TriggerHandlerException extends Exception {}

}