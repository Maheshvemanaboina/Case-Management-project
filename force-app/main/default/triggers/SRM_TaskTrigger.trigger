/**
 * Created by mateuszwolak on 07/08/2020.
 */

trigger SRM_TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SRM_TASK)) return;

    new SRM_TaskTriggerHandler().run();
}