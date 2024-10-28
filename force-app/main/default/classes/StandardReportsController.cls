public class StandardReportsController {

    @AuraEnabled
    public static String getReportResponse(Id reportId, String filterName, String filterValue) {
        return JSON.serialize(StandardReportUtils.getTabularReportResponse(reportId,filterName,filterValue));
    }
}