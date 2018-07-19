// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  GOVUK.stepByStepPublisher = {
    init: function() {
      this.addReorderButtons();
      this.bindReorderButtonClicks();
      this.initialiseDragAndDrop();
    },

    addReorderButtons: function() {
      var $reorderItems = $('.js-reorder');

      if ($reorderItems.length) {
        var $up = $('<button/>');
        $up.addClass('btn btn-default js-up');
        $up.html('<span class="glyphicon glyphicon-arrow-up" aria-hidden="true"></span> Up');
        $up.attr('data-direction', 'up');

        var $down = $('<button/>');
        $down.addClass('btn btn-default js-down');
        $down.html('<span class="glyphicon glyphicon-arrow-down" aria-hidden="true"></span> Down');
        $down.attr('data-direction', 'down');

        $reorderItems.each(function() {
          var $controls = $(this).find('.js-order-controls');
          $up.clone().appendTo($controls);
          $down.clone().appendTo($controls);
        });
      }
    },

    bindReorderButtonClicks: function() {
      $('.js-up, .js-down').on('click', function() {
        var $parent = $(this).closest('.js-reorder');
        var direction = $(this).attr('data-direction');

        if (direction === 'up') {
          var $previous = $parent.prev('.js-reorder');
          $parent.insertBefore($previous);
        }
        else {
          var $next = $parent.next('.js-reorder');
          $parent.insertAfter($next);
        }

        GOVUK.stepByStepPublisher.setOrder();
      });
    },

    setOrder: function() {
      var $orderVal = $('#step_order_save');
      var order = [];

      $('.js-reorder').each(function(i) {
        order.push({ id: $(this).data('id'), position: i + 1 });
      });

      $orderVal.val(JSON.stringify(order));
    },

    // initialises jQuery sortable on the #js-reorder-group element
    // this code allows the steps to reorder via drag and drop
    initialiseDragAndDrop: function() {
      $('#js-reorder-group').sortable({
        placeholder: "js-reorder-ui-state-highlight",
        update: function(){
          GOVUK.stepByStepPublisher.setOrder();
        }
      });

      // adds disable selection 
      // so that user does not accidently select text 
      // while trying to do drag and drop 
      $('#js-reorder-group').disableSelection();
    }
  };
}());
