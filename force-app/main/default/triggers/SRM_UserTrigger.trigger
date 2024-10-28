/**
 * Created by mateuszwolak on 21/08/2020.
 */

trigger SRM_UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SRM_USER_TRIGGER)) return;

    new SRM_UserTriggerHandler().run();
}