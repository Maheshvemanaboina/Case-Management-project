/**
 * Created by KJM on 26/08/2019.
 */

@isTest
public class TileAutoCreationPageControllerTest {

    @isTest
    static void shouldCreateOrderAndDeliveryStructure() {
        TestUtility.createInitialTestAccountsAndUsers();

        String commercialCustomer = 'invalidCommercialCustomer';
        String customLocations = 'invalidCustomerLocation';
        String year = '20188';
        String communityName = 'invalidCommunityName';

        TileAutoCreationPageController.ResponseWrapper wrapper;
        wrapper = TileAutoCreationPageController.runOrderAndDeliveryScriptOption(commercialCustomer, customLocations, year, communityName);

        System.assertEquals(false, wrapper.Success);
        System.assertEquals('Cannot find Commercial Customer: invalidCommercialCustomer', wrapper.ErrorMessage);

        commercialCustomer = 'IMCD holding';
        wrapper = TileAutoCreationPageController.runOrderAndDeliveryScriptOption(commercialCustomer, customLocations, year, communityName);
        System.assertEquals(false, wrapper.Success);
        System.assertEquals('Cannot find Customer Location: invalidCustomerLocation', wrapper.ErrorMessage);

        customLocations = 'IMCD italy spa';
        wrapper = TileAutoCreationPageController.runOrderAndDeliveryScriptOption(commercialCustomer, customLocations, year, communityName);
        System.assertEquals(false, wrapper.Success);
        System.assertEquals('Cannot process with year: 20188', wrapper.ErrorMessage);

        year = '2019';
        wrapper = TileAutoCreationPageController.runOrderAndDeliveryScriptOption(commercialCustomer, customLocations, year, communityName);
        System.assertEquals(false, wrapper.Success);
        System.assertEquals('Cannot find Community Name: invalidCommunityName', wrapper.ErrorMessage);

        communityName = 'FCI distributor community';
        Test.startTest();

        wrapper = TileAutoCreationPageController.runOrderAndDeliveryScriptOption(commercialCustomer, customLocations, year, communityName);

        Test.stopTest();

        System.assertEquals(true, wrapper.Success);
        System.assertEquals(null, wrapper.ErrorMessage);


    }
}