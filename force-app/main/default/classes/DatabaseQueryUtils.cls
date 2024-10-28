/**
 * Created by krzys on 03/04/2019.
 */

public with sharing class DatabaseQueryUtils {

    public static String buildMultiSelectCondition(Map<String, List<String>> fieldAndValues, Boolean includeWhere) {
        String query = includeWhere ? ' WHERE ' : ' ';
        for (String objField : fieldAndValues.keySet()) {
            query += objField + ' INCLUDES ' + '(';

            for (String fieldValue : fieldAndValues.get(objField)) {
                query += '\'' + fieldValue + '\',';
            }

            query = query.removeEnd(',');
            query += ')';

            query += ' AND ';
        }

        query = query.removeEnd(' AND ');
        return query;
    }
}