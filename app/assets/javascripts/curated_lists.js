(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  GOVUK.curatedLists = {
    init: function() {
      var $lists = $('.curated-list');

      GOVUK.curatedLists.hideContentForms();
      GOVUK.curatedLists.hideRedundantColumns($lists);

      $lists.each(function(_, list) {
        var $list = $(list);

        if ($list.children().length > 1) {
          $list.children('.empty-list').hide();
        }

        $list.sortable({
          connectWith: '.curated-list',
          dropOnEmpty: true,
          stop: function(event, draggable) {
            if (!$(event.target).closest('section').is('#list-uncategorized-section')) {
              GOVUK.curatedLists.postSort(event, draggable);
            }

            GOVUK.publishing.unlockPublishing();
          },
          receive: GOVUK.curatedLists.postSort
        });
      });
    },
    hideContentForms: function() {
      $('form').filter('.new_list_item').hide();
    },
    hideRedundantColumns: function($lists) {
      $lists.closest('table').find('.api-url, .index, .remove').hide();
    },
    postSort: function(event, draggable) {
      var $droppedRow = draggable.item;
      var $targetList = $(event.target);
      var $sourceList = draggable.sender;
      var internalMove = ($droppedRow.data('list-id') === $targetList.data('list-id'));

      $targetList.children('.empty-list').hide();

      if ($targetList.closest('section').is('#list-uncategorized-section')) {
        GOVUK.curatedLists.deleteRow($droppedRow);
      } else {
        var $allRows = $targetList.children(':not(.empty-list)');

        var startIndex = $droppedRow.data('index');
        var stopIndex = $allRows.index($droppedRow);

        var indexToUpdateFrom;
        if ($sourceList) { // Reindexing destination list
          $droppedRow.data('list-id', $targetList.data('list-id'));
          indexToUpdateFrom = stopIndex;
        } else if (internalMove) { // Move was within same list
          indexToUpdateFrom = Math.min(startIndex, stopIndex);
        } else { // Reindexing source list
          indexToUpdateFrom = startIndex;
        }

        var $rowsToUpdate = $allRows.slice(indexToUpdateFrom);

        GOVUK.curatedLists.reindex($rowsToUpdate, indexToUpdateFrom);
      }
    },
    reindex: function($rows, offset) {
      if ($rows.length > 0) {
        $rows.first().closest('section').css('opacity', '0.5');
        var $list = $rows.first().closest('.curated-list');

        $rows.each(function(domIndex, row) {
          var $row = $(row);
          var updateURL = $row.data('update-url');
          var index = offset + domIndex;

          $row.data('index', index);

          if (updateURL) {
            GOVUK.curatedLists.updateRow(updateURL, $list, $row, index);
          } else {
            GOVUK.curatedLists.createRow($list, $row, index);
          }
        });
      } else {
        $('.curated-list').each(function(_, list) {
          if ($(list).children().not('.empty-list').length <= 0) {
            $(list).children('.empty-list').show();
          }
        });
      }
    },
    updateRow: function(updateURL, $list, $row, index) {
      $row.addClass('working');

      $.ajax(updateURL, {
        type: 'PUT',
        data: JSON.stringify({
          new_list_id: $list.data('list-id'),
          index: index
        }),
        contentType: 'application/json',
        dataType: 'json',
        success: function() {
          GOVUK.curatedLists.postReindex($list, $row);
        }
      });
    },
    createRow: function($list, $row, index) {
      $row.addClass('working');

      var $form = $list.closest('section').find('.new_list_item');
      var createURL = $form.attr('action');

      $.ajax(createURL, {
        type: 'POST',
        data: JSON.stringify({
          list_item: {
            index: index,
            title: $row.find('.title').text(),
            api_url: $row.find('.api-url').text()
          }
        }),
        contentType: 'application/json',
        dataType: 'json',
        success: function(data) {
          $row.removeClass('working');
          $row.data('update-url', data['updateURL']);
          GOVUK.curatedLists.postReindex($list);
        }
      });
    },
    deleteRow: function($row) {
      $row.addClass('working');

      var deleteURL = $row.data('update-url');

      $.ajax(deleteURL, {
        type: 'DELETE',
        contentType: 'application/json',
        dataType: 'json',
        success: function() {
          $row.removeClass('working');
        }
      });
    },
    postReindex: function($list, $row) {
      if ($row) {
        $row.removeClass('working');
      }

      if ($list.children('.working').length === 0) {
        $list.closest('section').css('opacity', '1');
      }
    },
  };
}());
