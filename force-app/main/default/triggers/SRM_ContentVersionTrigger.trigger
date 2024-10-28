/* *******************************************************************************************************
 * Name               : SRM_ContentVersionTrigger                                                            *
 * Description        : Trigger for ContentVersion                                                       *
 * Created Date       : 19-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       19-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
trigger SRM_ContentVersionTrigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SRM_CONTENT_VERSION)) return;

    new SRM_ContentVersionTriggerHandler().run();
}