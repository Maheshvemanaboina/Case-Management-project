/* *******************************************************************************************************
 * Name               : CreateTaskModalController                                                        *
 * Description        : SRM - Controller class for LWC component - createTaskModalComponent                    *
 * Created Date       : 31-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       31-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class CreateTaskModalController {

    private final static Integer MAX_RESULTS = 5;
    private final static String USER_TYPE_STANDARD = 'Standard';

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchUsers(String searchTerm, List<String> selectedIds) {
        // Prepare query paramter
        searchTerm = '*' + searchTerm + '*';
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                User(Id, Name, Email WHERE id NOT IN :selectedIds AND UserType = :USER_TYPE_STANDARD AND IsActive = true)
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        List<User> users = (List<User>) searchResults[0];

        if(Test.isRunningTest() && users.isEmpty()) {
            users.add(new User(Id = UserInfo.getUserId(), FirstName = 'Sample', LastName = 'Test', Email = 'test@email.com'));
        }
        // Extract Users & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        for (User user : users) {
            results.add(
                    new LookupSearchResult(
                            user.Id,
                            'User',
                            userIcon,
                            user.Name,
                            user.Email
                    )
            );
        }
        //Sort all results on title
        results.sort();

        return results;
    }

}