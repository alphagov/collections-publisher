//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/all_components

GOVUK.orderedLists.init();
GOVUK.curatedLists.init();
GOVUK.stepByStepPublisher.init();

(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  $(document).ready(function() {
    $(".select2").select2({ allowClear: true });
  });
}());
