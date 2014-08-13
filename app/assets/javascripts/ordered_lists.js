(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  GOVUK.orderedLists = {
    init: function() {
      $('.curated-lists').sortable({
        stop: function(event, draggable) {
          var $droppedList = draggable.item;
          var $lists = $('.curated-lists').children();

          var startIndex = $droppedList.data('index');
          var stopIndex = $lists.index($droppedList);

          $droppedList.data('index', stopIndex);

          var indexToUpdateFrom = Math.min(startIndex, stopIndex);

          var $listsToUpdate = $lists.slice(indexToUpdateFrom);

          GOVUK.orderedLists.reindex($listsToUpdate, indexToUpdateFrom);
        }
      });
    },
    reindex: function($lists, offset) {
      $lists.each(function(index, list) {
        var $list = $(list);
        var updateURL = $list.data('update-url');
        var newIndex = offset + index;

        $list.data('index', newIndex);
        GOVUK.orderedLists.updateRow(updateURL, newIndex);
      });
    },
    updateRow: function(updateURL, index) {
      $.ajax(updateURL, {
        type: 'PUT',
        data: JSON.stringify({
          list: {
            index: index
          }
        }),
        contentType: 'application/json',
        dataType: 'json'
      });
    }
  };
}());
