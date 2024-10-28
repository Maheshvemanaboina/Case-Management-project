public without sharing class StandardReportUtils {
    public Static TabularReportResponse getTabularReportResponse(Id reportId, String filterName, String filterValue) {
        TabularReportResponse trr = new TabularReportResponse();
        List<fieldDef> reportFields = new List<fieldDef>(); 
        List<List<fieldData>> fieldDataList = new List<List<fieldData>>();  
    
        //get the report result
        Reports.ReportMetadata reportMd = applyFilters(reportId, filterName, filterValue);
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, reportMd, true);
    
        //get the metadata
        Reports.ReportMetadata reportMetadata = results.getReportMetadata();
    
        //get a string array of the field names
        List<String> fieldNames = reportMetadata.getDetailColumns();
    
        //get the extended metadata
        Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();
    
        //get the map of the column names to their name and label
        Map<String, Reports.DetailColumn> detailColumnMap = reportExtendedMetadata.getDetailColumnInfo();
    
        //loop over the detailColumnMap and get the name, label, and data type
        for (String fieldName: fieldNames) {
            Reports.DetailColumn detailColumn = detailColumnMap.get(fieldName);
            fieldDef fd = new fieldDef();
            fd.fieldName = detailColumn.getName(); 
            fd.fieldLabel = detailColumn.getLabel();
            fd.dataType = detailColumn.getDataType().name();
            reportFields.add(fd);
        }
    
        // Get the fact map from the report results
        system.debug(results.getFactMap());
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');     
    
        List<Reports.ReportDetailRow> reportDetailRowList = factDetails.getRows();
    
        //loop over the rows
        for (Reports.ReportDetailRow reportDetailRow: reportDetailRowList) {
            Integer cellCounter = 0;
            List<fieldData> fieldDataRow = new List<fieldData>();
            //loop over the cells in the row
            for (Reports.ReportDataCell reportDataCell: reportDetailRow.getDataCells()) {
                fieldData fd = new fieldData();
                fd.fieldValue =reportDataCell.getValue();// parseColumnValue(reportDataCell.getValue());
                fd.fieldLabel = (String)reportDataCell.getLabel();
                fd.dataType = reportFields[cellCounter].dataType;
                cellCounter++;
                fieldDataRow.add(fd);
            }
    
            //add the row to the list
            fieldDataList.add(fieldDataRow);
        }
    
        trr.reportFields = reportFields;
        trr.fieldDataList = fieldDataList;
        return trr;
    }

    public static Reports.ReportMetadata applyFilters(Id reportId, String filterName, String filterValue) {
        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();

        
        system.debug('filters: '+reportMd.getReportFilters());
        Boolean filterFound = false;
        for (Reports.ReportFilter filter : reportMd.getReportFilters()) {
            String filterColumn = filter.getColumn();
            system.debug('filter:');
            system.debug(filterColumn);
            system.debug(filter.getFilterType());
            system.debug(filter.getOperator());
            if (filterColumn == filterName) {
                filterFound = true;
                filter.setValue(filterValue);
            }
        }
        if (!filterFound) {
            List<Reports.ReportFilter> reportFilters = reportMd.getReportFilters();
            Reports.ReportFilter filter = new Reports.ReportFilter();
            filter.setColumn(filterName);
            filter.setOperator('equals');
            filter.setValue(filterValue);
            reportFilters.add(filter);
            reportMd.setReportFilters(reportFilters);//?fv0=a2D3L000000VY0pUAG
        }
        // Override filter and run report
        // Reports.ReportFilter filter = reportMd.getReportFilters()[0];
        // filter.setValue('2013-11-01');
        return reportMd;
    }

    private static String parseColumnValue(Object columnValueObject) {
        String columnValue = '';
        try {
            Datetime datetimeValue = (Datetime)columnValueObject;
            columnValue = datetimeValue.toString();
        }
        catch(Exception ex) {
            columnValue = (String)columnValueObject;
        }
        return columnValue;
    }

    public class TabularReportResponse {
        public List<fieldDef> reportFields {get; set;}
        public List<List<fieldData>> fieldDataList {get; set;}
        public tabularReportResponse(){}
    }
    
    public class fieldDef {
        public String fieldName {get; set;}
        public String fieldLabel {get; set;}
        public String dataType {get; set;}
        public fieldDef(){}
    }
    
    public class fieldData {
        public Object fieldValue {get; set;}
        public String fieldLabel {get; set;}
        public String dataType  {get; set;}
        public Boolean isHyperLink {get; set;}          
        public fieldData(){isHyperLink=false;}
    }
}