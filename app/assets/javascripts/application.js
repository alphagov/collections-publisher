//= require_tree ./lib
//= require_tree .
//= require_self

GOVUK.orderedLists.init();
GOVUK.curatedLists.init();

(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  $('.js-confirm').closest('form').submit(function(event) {
    if (!confirm('Are you sure you want to delete this list and all its content?')) {
      event.preventDefault();
    }
  });
}());
