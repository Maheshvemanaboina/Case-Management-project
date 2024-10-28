/* *******************************************************************************************************
 * Name               : SRM_CreateRiskDetailsController                                               	 *
 * Description        : SRM -  class for Creating New risk though Lighitng Componet                      *
 * Created Date       : 03-Oct-2022                                                                      *
 * Created By         : Pankaj                                                          *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Pankaj      03-Oct-202 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public class SRM_CreateRiskDetailsController {
    @AuraEnabled
    public static List<Supplier_SAP_Numbers_And_Payment_Terms__c> getSupplierDetails(String sapNumber){
        system.debug('received number '+ sapNumber);
        List<Supplier_SAP_Numbers_And_Payment_Terms__c> relatedRecs = [SELECT Id, Supplier_Hub__c,Supplier_Name__c, Vendor_Sap_Number__c FROM Supplier_SAP_Numbers_And_Payment_Terms__c where Vendor_Sap_Number__c =: sapNumber];
        if(! relatedRecs.isEmpty()){
            return relatedRecs;
        }
        return null;
    }
    @AuraEnabled
    public static List<Supplier_Location__c> getSupplierLocationDetails(String supplierId){
        system.debug('received number '+ supplierId);
        List<Supplier_Location__c> relatedRecs = [select id, Supplier_Hub__r.Supplier_Name__c, Location__r.Name from Supplier_Location__c  where Supplier_Hub__c  =: supplierId];
        if(! relatedRecs.isEmpty()){
            return relatedRecs;
        }
        return null;
    }

}