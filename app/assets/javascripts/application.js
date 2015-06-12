//= require jquery-ui.sortable.min
//= require jquery.clicktoggle
//= require_tree .
//= require_self

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
