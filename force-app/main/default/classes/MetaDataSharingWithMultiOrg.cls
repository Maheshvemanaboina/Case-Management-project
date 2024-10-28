/* Created By : KVP- Surya Priya.S
* Name : MetaDataSharingWithMultiOrg
* Created on : 28 May 2021
* Modified on: 01 June 2021
* Description : Sharing the Metadata of Object to the COE Multi Org.
*/
public class MetaDataSharingWithMultiOrg {
    public static Map<String,List<Integer>> getMetaData(){
        List<Integer> fieldCountWithRT = new List<Integer>();
        List<String> total = new list<String>();
        Map<String,List<Integer>> dataMap = new Map<String,List<Integer>>();
        Map<String,Integer> objectwithFieldCount = new Map<String,Integer>();
        Map<String,Integer> objectwithRTCount = new Map<String,Integer>();
        List<Schema.RecordTypeInfo> RT = new List<Schema.RecordTypeInfo>();
        List<Schema.RecordTypeInfo> RTInActive = new List<Schema.RecordTypeInfo>();
        List<Integer> fieldWithRT = new List<Integer>();
        String objectName;
        Integer fieldCount;
        Integer RTCount;
        Integer RTUnusedCount;
        Map<String,Schema.RecordTypeInfo> hasRecordMap = new Map<String,Schema.RecordTypeInfo>();
        for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() )
        {
            objectName= '';
            fieldCount=0; 
            fieldCountWithRT = new List<Integer>();
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            hasRecordMap = objResult.getRecordTypeInfosByDeveloperName();
            if(!hasRecordMap.isempty() && objResult.getRecordTypeInfosById()!=null){  
                if(objResult.isSearchable() == true){
                    system.debug( 'Sobject: ' + objResult );
                    total.add(objResult.getName());
                    objectName = objResult.getName();
                    RT = objResult.getRecordTypeInfos();
                    for(Schema.RecordTypeInfo unused:RT){
                        if(!unused.isActive() && unused!=null ){
                            RTInActive.add(unused);
                        }
                    }
                    RTCount = RT.Size();
                    RTUnusedCount = RTInActive.Size();
                    
                    fieldCount = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().size();
                    fieldWithRT.add(fieldCount);
                    fieldWithRT.add(RTUnusedCount);
                    fieldCountWithRT.add(fieldCount);
                    fieldCountWithRT.add(RTUnusedCount);
                    fieldCountWithRT.add(RTCount);
                    system.debug( 'Sobject API Name: ' + objResult.getName() );
                    system.debug( 'Sobject Label Name: ' + objResult.getLabel() );
                    system.debug( 'Sobject RT Data: ' + RT );
                    system.debug( 'Sobject Recordtype count: ' + RTCount );
                    system.debug( 'Sobject UnUsedRecordtype count: ' + RTUnusedCount );
                    //System.debug('SObject Fields list'+objResult.getFields());
                    //system.debug('SObject Fields list...'+Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().size());
                    objectwithFieldCount.put(objectName,fieldCount);
                    objectwithRTCount.put(objectName,RTUnusedCount);
                    dataMap.put(objectName, fieldCountWithRT);
                }
            }
        }
        system.debug('total....'+total.size());
        system.debug('Result--'+dataMap);
        return dataMap;
        
    }
    /* 
//Method to share Object total record count
public static Integer getRecordCount(String objname){
list<AggregateResult> countofRecords = new list<AggregateResult>();
countofRecords = database.query('SELECT COUNT(id) result FROM'+ ' '+ objname);
return Integer.valueOf(countofRecords[0].get('result')) ;
}

//Method to share Object total Last usage Date
public static Date getLastUsageObj(String objname){
Map<String,Date> mapOfLastCreatedDate = new Map<String,Date>();

SObject lastCreated = database.query('select CreatedDate from '+ objname+' order by CreatedDate desc limit 1');
Schema.SObjectType sObjectType = lastCreated.getSObjectType();
System.debug('sObjectType'+sObjectType);
// mapOfLastCreatedDate.put(lastCreated,lastCreated.CreatedDate);
return Date.valueOf(lastCreated);


}*/
    
    //Method to share InActive Approval process count
    public static Map<String,Integer> getInActiveApprovalCount()
    {
        List<AggregateResult> processDefinationList = database.query('SELECT Count(Id) cnt,TableEnumOrId tableEnumOrId FROM ProcessDefinition where state = \'InActive\' Group By TableEnumOrId');
        Map<String,Integer> inActiveApprovalMap = new  Map<String,Integer>();
        for(AggregateResult listValue : processDefinationList)
        {
            inActiveApprovalMap.put(String.valueOf(listValue.get('TableEnumOrId')), Integer.valueOf(listValue.get('cnt')));
        }                         
        return inActiveApprovalMap;
    }
    
    //Method to share Active Approval process count
    public static Map<String,Integer> getActiveApprovalCount()
    {
        List<AggregateResult> processDefinationList = database.query('SELECT Count(Id) cnt,TableEnumOrId tableEnumOrId FROM ProcessDefinition where state = \'Active\' Group By TableEnumOrId');
        Map<String,Integer> ActiveApprovalMap = new  Map<String,Integer>();
        for(AggregateResult listValue : processDefinationList)
        {
            ActiveApprovalMap.put(String.valueOf(listValue.get('TableEnumOrId')), Integer.valueOf(listValue.get('cnt')));
        }                         
        return ActiveApprovalMap;
    }
    
    //Method to retrive DataSharing Wrapping MetaData list 
    public static List<DataSharingWrapper.objectMetaData>  getObjData()
    {
        Date lastUsageOfObj;
        Map<String,List<Integer>> objDataMap= MetaDataSharingWithMultiOrg.getMetaData();
        Map<String,Integer> secMap = new Map<String,Integer>();
        List<DataSharingWrapper.objectMetaData> objMetaDataDetailsList = new List<DataSharingWrapper.objectMetaData>() ;
        List<String> totalObjs = new List<String>();
        Map<String,Integer> activeApprovalMap =  getActiveApprovalCount();
        Map<String,Integer> inActiveApprovalMap =  getInActiveApprovalCount();
        // Map<String,Integer> totalRecordCount = getRecordCount();
        //Map<String,Date> lastUsageRecordDate = getLastUsageObj();
        
        for(String metaObjData :objDataMap.keyset() ){
            totalObjs.add(metaObjData);
            DataSharingWrapper.objectMetaData objMetaDataDetails = new DataSharingWrapper.objectMetaData();
            Integer feildCount ;
            Integer rtCount ;
            Integer totalRTCount;
            List<Integer>  values = objDataMap.get(metaObjData);  
            System.debug('ObjName...'+metaObjData+'..values'+values);
            feildCount =values.get(0);
            rtCount = values.get(1);
            totalRTCount = values.get(2);
            objMetaDataDetails.ObjectName = metaObjData;
            objMetaDataDetails.ObjectNumberOfFields = feildCount;
            objMetaDataDetails.ObjectUnusedRecordTypesCount = rtCount;
            objMetaDataDetails.ObjectTotalRecordTypesCount = totalRTCount;
            // objMetaDataDetails.ObjectRecordCount = getRecordCount(metaObjData);
            //objMetaDataDetails.ObjectLastUsageDate = getLastUsageObj(metaObjData);
            objMetaDataDetails.Org = UserInfo.getOrganizationId();
            objMetaDataDetails.NumberOfApprovalProcessActive = ((activeApprovalMap.get(metaObjData)!= null)?activeApprovalMap.get(metaObjData) : 0);
            objMetaDataDetails.NumberOfApprovalProcessInActive = ((inActiveApprovalMap.get(metaObjData)!= null)?inActiveApprovalMap.get(metaObjData) : 0);
            objMetaDataDetailsList.add(objMetaDataDetails);
            System.debug('Complete Data...'+objMetaDataDetailsList);
            System.debug('ObjName...'+metaObjData);
            System.debug('ObjName fields...'+feildCount);
            System.debug('ObjectUnusedRecordTypesCount...'+ rtCount);
            System.debug('metaObjData:: '+metaObjData +' objMetaDataDetails.NumberOfApprovalProcessActive...'+ objMetaDataDetails.NumberOfApprovalProcessActive);
            
        }  
        return objMetaDataDetailsList;
    }
    
}