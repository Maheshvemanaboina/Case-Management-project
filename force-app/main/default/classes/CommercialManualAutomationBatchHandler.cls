/*
* @Author : Shweta 
* @Date : 26th June 2021
* @Desc : Handler class for CommercialManualAutomationBatch which updates the Commercial Manual Prices.
* @Jira : SCPQ-1026
*/
public without sharing class CommercialManualAutomationBatchHandler {
    
    // PROPERTIES //
    @testVisible
    private static Boolean throwException = false;
    
/******************************************************************************
* Author : Shweta
* Date : 26 June 2021
* Description : This method is used to shift and update the Commercial Manual Prices up by one
* Parameters : List of Commercial_Manual__c
* Return : NA
* *****************************************************************************/
    
    public static void updateCommercialManual(List<Commercial_Manual__c> comList){
        List<Commercial_Manual__c> updateComList = new List<Commercial_Manual__c>();
        If(!comList.isEmpty() && comList!=null){
           For(Commercial_Manual__c com: comList){
               Commercial_Manual__c commercial = new Commercial_Manual__c();
               commercial=com;
               
               commercial.Floor_Price_M00__c = checkFloorAndListPrice(com.Floor_Price_M01__c);
               commercial.Floor_Price_M01__c = checkFloorAndListPrice(com.Floor_Price_M02__c);
               commercial.Floor_Price_M02__c = checkFloorAndListPrice(com.Floor_Price_M03__c);
               commercial.Floor_Price_M03__c = checkFloorAndListPrice(com.Floor_Price_M04__c);
               commercial.Floor_Price_M04__c = checkFloorAndListPrice(com.Floor_Price_M05__c);
               commercial.Floor_Price_M05__c = checkFloorAndListPrice(com.Floor_Price_M06__c);
               commercial.Floor_Price_M06__c = checkFloorAndListPrice(com.Floor_Price_M07__c);
               commercial.Floor_Price_M07__c = checkFloorAndListPrice(com.Floor_Price_M08__c);
               commercial.Floor_Price_M08__c = checkFloorAndListPrice(com.Floor_Price_M09__c);
               commercial.Floor_Price_M09__c = checkFloorAndListPrice(com.Floor_Price_M10__c);
               commercial.Floor_Price_M10__c = checkFloorAndListPrice(com.Floor_Price_M11__c);
               
               commercial.List_Price_M00__c = checkFloorAndListPrice(com.List_Price_M01__c);
               commercial.List_Price_M01__c = checkFloorAndListPrice(com.List_Price_M02__c);
               commercial.List_Price_M02__c = checkFloorAndListPrice(com.List_Price_M03__c);
               commercial.List_Price_M03__c = checkFloorAndListPrice(com.List_Price_M04__c);
               commercial.List_Price_M04__c = checkFloorAndListPrice(com.List_Price_M05__c);
               commercial.List_Price_M05__c = checkFloorAndListPrice(com.List_Price_M06__c);
               commercial.List_Price_M06__c = checkFloorAndListPrice(com.List_Price_M07__c);
               commercial.List_Price_M07__c = checkFloorAndListPrice(com.List_Price_M08__c);
               commercial.List_Price_M08__c = checkFloorAndListPrice(com.List_Price_M09__c);
               commercial.List_Price_M09__c = checkFloorAndListPrice(com.List_Price_M10__c);
               commercial.List_Price_M10__c = checkFloorAndListPrice(com.List_Price_M11__c);
                    
               updateComList.add(commercial);
           } 
        }
        if(updateComList.size()>0 && !updateComList.isEmpty()){
            try{
                Database.update(updateComList);
                
                // In case of testing, throw an exception //
                if ( throwException ) throw new NullPointerException();
            }
            catch(Exception stackedError){
          
                // Log an error //
                    Boolean  isDmlException = stackedError.getTypeName() == 'System.DmlException' || stackedError.getTypeName() == 'System.EmailException';
                    String   dmlTypeName    = !isDmlException ? null : String.valueOf( stackedError.getDmlType( 0 ) );
                    String   dmlMessage     = !isDmlException ? null : stackedError.getDmlMessage( 0 );
                    String[] dmlFieldNames  = !isDmlException ? null : stackedError.getDmlFieldNames( 0 );
                    String   typeName       = stackedError.getTypeName();
                    String   message        = stackedError.getMessage();
                    DebugLog__c debugLog    = new DebugLog__c(
                        Severity__c         = 'Error',
                        Comments__c         = 'Failed while attempting to update Floor and List Prices for Commercial Manuals',
                        Message__c          = dmlMessage    != null ? dmlMessage.left( 255 ) : null,
                        Cause__c            = message       != null ? message.left( 255 ) : null,
                        TypeName__c         = dmlTypeName   != null ? dmlTypeName.left( 255 ) : typeName != null ? typeName.left( 255 ) : null,
                        Fields__c           = dmlFieldNames != null ? String.valueOf( dmlFieldNames ).left( 32768 ) : null,
                        StackTraceString__c = stackedError.getStackTraceString().left( 32768 ),
                        Record__c           = JSON.serialize( updateComList ).left( 32768 ),
                        DateTime__c         = System.now()
                    );
                    Database.insert( debugLog, false );
            }
                
        }
       
    }
    
/******************************************************************************
* Author : Shweta
* Date : 29 June 2021
* Description : This method is used to check the next value is null or not.
* Parameters : List and Floor prices at a time
* Return : Decimal
* *****************************************************************************/
    public static Decimal checkFloorAndListPrice(Decimal nextValue){
        Decimal var ;
        //Boolean flag = false;
        If(nextValue!=null)
        {
           //flag = true;
           var = nextValue;
           
        }
         return var;
    }
}