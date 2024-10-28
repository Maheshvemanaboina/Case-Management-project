trigger ContractTrigger on Contract (before insert,before update, after insert, after update) {
    ContractTriggerHandler contractTrig = new ContractTriggerHandler();
    contractTrig.process();
}