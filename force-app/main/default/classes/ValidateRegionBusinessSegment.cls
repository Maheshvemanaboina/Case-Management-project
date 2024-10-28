/*       
@Name                  ValidateRegionBusinessSegment
@Author                Rekha + rekha.harshit@frieslandcampina.com
@ModifiedBy            
@Version               1.0
@CreatedDate           -----
@UsedBy                Flow - Quote - Validate Region and Business Segment
@Description           Class to validate Region-Business Segment-Subsegment on quote from valid custom meta data records 
@Changes

UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========

*/
public class ValidateRegionBusinessSegment {
    
    @InvocableMethod(Label='Validate Region and Business Segment' Description='Update checkbox based on the valid match' Category='Quote')
    public static void processData(List<String> quoteId) {
        
        
        SBQQ__Quote__c quoteRecord = new SBQQ__Quote__c();        
        
        quoteRecord = [
                      SELECT
                           id,Sales_Region__c,Primary_Business_Segment__c,Primary_Sub_Segment__c,Valid_for_Approval__c
                      FROM SBQQ__Quote__c
                      WHERE id IN : quoteId
        ];
        
        if(quoteRecord.Sales_Region__c!=Null){
            quoteRecord.Valid_for_Approval__c = false;
        	for(Region_BusinessSegment_Map__mdt each : [
            		                                   SELECT
                                                       id,Region__c,Business_Segment__c,Sub_Segment__c
                                                       FROM Region_BusinessSegment_Map__mdt
            ]){
                
                if(each.Region__c == quoteRecord.Sales_Region__c &&
                   quoteRecord.Primary_Business_Segment__c!=NULL && each.Business_Segment__c == quoteRecord.Primary_Business_Segment__c
                ){
                    if(each.Sub_Segment__c==NULL || each.Sub_Segment__c == quoteRecord.Primary_Sub_Segment__c){
                    	quoteRecord.Valid_for_Approval__c = true;	   
                    }
                }
            }
            update quoteRecord;
        }
    }    
}