/**
 * Created by KJM on 14/08/2019.
 */

({
    handleSearchClick : function(component, event, helper) {
    helper.searchForResult(component, event, helper);
    },

    handleListItemClick: function(component, event, helper) {
      var ent = event.currentTarget;
      var elUrl = ent.getAttribute('data-url');

      if (ent.getAttribute('data-isFile') === "false") {
           helper.navigateToUrl(component, event, helper, elUrl);
      } else {
           helper.showIframe(component, event, helper, elUrl);
      }
    },

    handleOnFocusSearchText: function(component, event, helper) {
      helper.searchForResult(component, event, helper);
    },

    handleOnBlurSearchText: function(component, event, helper) {
      helper.hideSearchResult(component, event, helper);
    },
});