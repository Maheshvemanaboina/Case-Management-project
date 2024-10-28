/**
 * Created by KJM on 21/05/2019.
 */

public with sharing class QueryUtility {

    public static String buildMultiSelectCondition(Map<String, List<String>> fieldAndValues, Boolean includeWhere) {
        String query = includeWhere ? ' WHERE ' : ' ';
        for (String objField : fieldAndValues.keySet()) {
            query += objField + ' INCLUDES ' + '(';

            for (String fieldValue : fieldAndValues.get(objField)) {
                query += '\'' + fieldValue + '\',';
            }

            query = query.removeEnd(',');
            query += ')';

            query += Constants.QUERY_AND;
        }

        query = query.removeEnd(Constants.QUERY_AND);
        return query;
    }

    public static String buildMultiSelectINCLUDEConditionWithEmptyCondition(Map<String, List<String>> fieldAndValues, Boolean includeWhere) {
        String query = includeWhere ? ' WHERE ' : ' ';
        for (String objField : fieldAndValues.keySet()) {
            query += ' ( ' + objField + ' = \'\' ' + Constants.QUERY_OR + objField + ' INCLUDES ' + '(';

            for (String fieldValue : fieldAndValues.get(objField)) {
                query += '\'' + fieldValue + '\',';
            }

            query = query.removeEnd(',');
            query += '))';

            query += Constants.QUERY_AND;
        }

        query = query.removeEnd(Constants.QUERY_AND);
        return query;
    }

    public static String buildMultiSelectINConditionWithEmptyCondition(Map<String, List<String>> fieldAndValues, Boolean includeWhere) {
        String query = includeWhere ? ' WHERE ' : ' ';
        for (String objField : fieldAndValues.keySet()) {
            query += ' ( ' + objField + ' = \'\' ' + Constants.QUERY_OR + objField + ' IN ' + '(';

            for (String fieldValue : fieldAndValues.get(objField)) {
                query += '\'' + fieldValue + '\',';
            }

            query = query.removeEnd(',');
            query += '))';

            query += Constants.QUERY_AND;
        }

        query = query.removeEnd(Constants.QUERY_AND);
        return query;
    }

    public static String buildINCondition(Map<String, List<String>> fieldAndValues, Boolean includeWhere, Boolean includeNotIN) {
        String query = includeWhere ? ' WHERE ' : ' ';
        for (String objField : fieldAndValues.keySet()) {
            query += ' ' + objField + ( includeNotIN ? ' NOT IN ' : ' IN ' ) + '(';

            for (String fieldValue : fieldAndValues.get(objField)) {
                query += '\'' + fieldValue + '\',';
            }

            query = query.removeEnd(',');
            query += ')';

            query += Constants.QUERY_AND;
        }

        query = query.removeEnd(Constants.QUERY_AND);
        return query;
    }
}