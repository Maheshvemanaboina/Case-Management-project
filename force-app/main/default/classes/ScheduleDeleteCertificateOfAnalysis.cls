/*************************************************************************************************************************************
 Created By:   Rohit Kumar
 Created Date: 28/10/2020
 Description : This class will delete all COA, which are fetched from the SAP,by scheduling DeleteCertificateOfAnalysisFromSFDCBatch,
               in every 30 days
***************************************************************************************************************************************/

global without sharing class ScheduleDeleteCertificateOfAnalysis implements Schedulable {
    
    global void execute(SchedulableContext sc){
    DeleteCertificateOfAnalysisFromSFDCBatch deleteCoA =new DeleteCertificateOfAnalysisFromSFDCBatch();
      database.executebatch(deleteCoA,200);
    }

}