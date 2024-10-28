trigger ContractAmendmentNotificationTrigger on ContractNotification__e (after insert) {
    for(ContractNotification__e contRec: Trigger.new){
        system.debug('contRec----'+contRec.replayId);
    }
}