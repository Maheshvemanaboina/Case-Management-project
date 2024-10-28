/**
 * Created by KJM on 28/05/2019.
 */

public with sharing class UploadCSVUtility {

    public static Integer getValueIndex(Map<Integer, String> searchingMap, String searchValue) {
        for (Integer index : searchingMap.keySet()) {
            if (searchingMap.get(index) == searchValue){
                return index;
            }
        }

        return null;
    }
}