(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  GOVUK.orderedLists = {
    init: function() {
      var $listContainer = $('.curated-lists');

      $listContainer.sortable({
        stop: function(event, draggable) {
          var $lists = $listContainer.children();
          var $droppedList = draggable.item;
          var startIndex = $droppedList.data('index');
          var stopIndex = $lists.index($droppedList);

          $droppedList.data('index', stopIndex);

          var indexToUpdateFrom = Math.min(startIndex, stopIndex);
          var $listsToUpdate = $lists.slice(indexToUpdateFrom);

          GOVUK.orderedLists.reindex($listsToUpdate, indexToUpdateFrom);
        }
      });

      var $lists = $listContainer.children();
      $lists.hover(
        function() { $(this).addClass('subtle-highlight'); },
        function() { $lists.removeClass('subtle-highlight'); }
      );
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
