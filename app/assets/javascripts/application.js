//= require components/autocomplete.js
//= require jquery-ui.sortable.min
//= require jquery.clicktoggle
//= require ./curated_lists
//= require ./ordered_lists
//= require ./publishing

//= require select2

GOVUK.orderedLists.init();
GOVUK.curatedLists.init();

(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  $(document).ready(function() {
    $(".select2").select2({ allowClear: true });
  });
}());
