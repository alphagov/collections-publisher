(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};
  var $ = window.jQuery;

  GOVUK.curatedLists = {
    init: function() {
      GOVUK.curatedLists.redrawUncategorizedList();
      GOVUK.curatedLists.activateRemoveButtons();
      GOVUK.curatedLists.showEmptyLabels();

      $('#all-list-items tr').draggable({
        connectToSortable: '.drag-and-droppable',
        helper: 'clone',
        placeholder: 'droppable-placeholder'
      });

      $('.drag-and-droppable').sortable({
        connectWith: '.drag-and-droppable',
        items: 'tr.item',
        dropOnEmpty: true,
        placeholder: 'droppable-placeholder',
        update: function(event, _draggable) {
          var $targetList = $(event.target);
          GOVUK.curatedLists.reindexList($targetList);
        }
      });

      $('tr.untagged .button_to').tooltip({
        title: "This item is no longer tagged with this tag, so it is no " +
        "longer visible to the user. You can safely remove it."
      })
    },
    reindexList: function($list) {
      var $rows = $list.children(':not(.empty-list)');

      $rows.each(function(domIndex, row) {
        var $row = $(row);

        // The item might have a new list ID.
        $row.data({ 'list-id': $list.data('list-id') });

        var updateURL = $row.data('update-url');

        if (updateURL) {
          GOVUK.curatedLists.updateRow(updateURL, $list, $row, domIndex);
        } else {
          GOVUK.curatedLists.createRow($list, $row, domIndex);
        }
      });

      GOVUK.curatedLists.showEmptyLabels();
      GOVUK.curatedLists.redrawUncategorizedList();
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
          $row.removeClass('working');
          GOVUK.publishing.unlockPublishing();
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
            title: $row.data('title'),
            api_url: $row.data('api-url')
          }
        }),
        contentType: 'application/json',
        dataType: 'json',
        success: function(data) {
          $row.removeClass('working');
          $row.data({ 'update-url': data['updateURL'] });
          GOVUK.publishing.unlockPublishing();
        }
      });
    },
    deleteRow: function($row) {
      $row.addClass('working');

      var deleteURL = $row.data('update-url');

      if (!deleteURL) {
        return;
      }

      $.ajax(deleteURL, {
        type: 'DELETE',
        contentType: 'application/json',
        dataType: 'json',
        success: function() {
          $row.removeClass('working');
          $row.remove();
          GOVUK.curatedLists.redrawUncategorizedList();
          GOVUK.publishing.unlockPublishing();
        }
      });
    },
    activateRemoveButtons: function () {
      $('.curated-list').on('click', '.remove-button', function (e) {
        e.preventDefault();
        var $row = $(e.currentTarget).parent().parent().parent('tr');
        GOVUK.curatedLists.deleteRow($row);
        GOVUK.curatedLists.showEmptyLabels();
        return false;
      })
    },
    showEmptyLabels: function () {
      $('.curated-list').each(function(_, list) {
        if ($(list).children().not('.empty-list').length <= 0) {
          $(list).children('.empty-list').show();
        } else {
          $(list).children('.empty-list').hide();
        }
      });
    },
    redrawUncategorizedList: function () {
      $('.is-curated').removeClass('is-curated');
      $(".drag-and-droppable tr").each(function() {
        var url = $(this).data('api-url')
        $("[data-api-url='" + url + "']").addClass('is-curated');
      })
    }
  };
}());
