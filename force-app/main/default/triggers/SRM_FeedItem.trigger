/* *******************************************************************************************************
 * Name               : SRM_FeedItem                                                                     *
 * Description        : Trigger for FeedItem                                                             *
 * Created By         : WAEG Pawel Kaca                                                                  *
 * Created Date       : 07/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG Pawel Kaca                   07/09/2020          Initial version                      *
 ******************************************************************************************************* */
trigger SRM_FeedItem on FeedItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_FEEDITEM)) return;

    new SRM_FeedItemTriggerHandler().run();
}