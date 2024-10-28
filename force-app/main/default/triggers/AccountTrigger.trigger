/**
 * Created by KJM on 15/07/2019.
 */

trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    AccountTriggerHandler accTrg = new AccountTriggerHandler();
    accTrg.process();
}