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
            if (!draggable.sender && !$(event.target).closest('section').is('#list-uncategorized-section')) {
              GOVUK.curatedLists.postSort(event, draggable);
            }
          },
          receive: GOVUK.curatedLists.postSort
        });
      });
    },
    hideContentForms: function() {
      $('form').filter('.new_content').hide();
    },
    hideRedundantColumns: function($lists) {
      $lists.closest('table').find('.index, .remove').hide();
    },
    postSort: function(event, draggable) {
      var $droppedRow = draggable.item;
      var $targetList = $(event.target);
      var $sourceList = draggable.sender;

      $targetList.children('.empty-list').hide();

      if ($targetList.closest('section').is('#list-uncategorized-section')) {
        GOVUK.curatedLists.deleteRow($droppedRow);
      } else {
        GOVUK.curatedLists.reindex($targetList);
      }
    },
    reindex: function($list, $sourceList) {
      var $listChildren = $list.children('tr').not('.empty-list');

      if ($listChildren.length > 0) {
        $list.closest('section').css('opacity', '0.5');

        $listChildren.each(function(index, row) {
          var $row = $(row);
          var updateURL = $row.data('update-url');

          if (updateURL) {
            GOVUK.curatedLists.updateRow(updateURL, $list, $row, index);
          } else {
            GOVUK.curatedLists.createRow($list, $row, index);
          }
        });
      } else {
        $list.children('.empty-list').show();
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

      var $form = $list.closest('section').find('.new_content');
      var createURL = $form.attr('action');

      $.ajax(createURL, {
        type: 'POST',
        data: JSON.stringify({
          content: {
            index: index,
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
