/*
  Show a confirm dialogue before continuing:
  <a href="#" data-module="confirm" data-message="Are you sure?">Delete this</a>
*/
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function(Modules) {
  "use strict";

  Modules.Confirm = function() {
    this.start = function(element) {
      element.on('click', confirm);

      function confirm(evt) {
        var message = element.data('message');
        if (! window.confirm(message)) {
          evt.preventDefault();
        }
      }
    };
  };

})(window.GOVUK.Modules);
