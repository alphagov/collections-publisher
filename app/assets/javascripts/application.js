//= require_tree ./lib
//= require_tree .
//= require_self

//= require select2

GOVUK.orderedLists.init();
GOVUK.curatedLists.init();

(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  $('.js-confirm').each(function(_, button) {
    var $button = $(button);

    $button.closest('form').submit(function(event) {
      if (!confirm($button.data('confirm-text'))) {
        event.preventDefault();
      }
    });
  });

  $(document).ready(function() {
    $(".select2").select2({ allowClear: true });
  });
}());
