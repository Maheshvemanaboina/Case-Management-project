/*      
@Name                  CaseSharingRecalculation
@Author                ?
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               1.1
@CreatedDate           ??-??-????
@UsedBy                Called directly from the anonymous window when needed by the Admin
@Description           Batch class to recalculate the case sharing for partner users of all the partner record type cases
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 01.02.2021 | Adjusted the CaseSharingUtility methods call
*/
global without sharing class CaseSharingRecalculation implements Database.Batchable<SObject> {
    
    /* @Description

    Get all cases to recalculate the sharing
    
    @param bc - Batch parameter

    @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        String Query = 'Select Id from Case';
        return Database.getQueryLocator(Query);
    }

    /* @Description

    Delete the existing case sharing records and recalculate the sharing
    
    @param bc - Batch parameter
    @param caseList - List of cases to consider

    @return void
    */
    global void execute(Database.BatchableContext bc, List<Case> caseList){
        Set<Id> usersIds = (new Map<Id, User>(UserUtility.getAllCommunityUsers())).keySet();

        Set<Id> casesIds = (new Map<Id, Case>(caselist)).keySet();

        CaseSharingUtility.deleteAllCasesRelatedSharing(usersIds, casesIds);
        CaseSharingUtility.createSharingForCase(casesIds);        
    }

    /* @Description

    Send an email on finish

    @param bc - Batch parameter

    @return void
    */
    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('Case Sharing Recalculation Batch', bc);
    }
}