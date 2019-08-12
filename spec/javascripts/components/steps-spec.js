/* eslint-env jasmine, jquery */
/* global GOVUK loadFixtures */

describe('Step by step publisher component', function () {
  'use strict'

  var container
  var stepByStepRows

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML = loadFixtures('overview-table.html')

    document.body.appendChild(container)
    stepByStepRows = $('.step-by-step-list__table .govuk-table__row')
    GOVUK.stepByStepPublisher.init()
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  describe('#bindOverviewTableFilter', function () {
    it('should display all step by steps by default', function () {
      expectAllRowsToBeVisible()
    })

    it('should display results where the title matches the search term', function () {
      searchFor('fish')
      expectOnlyVisibleRowToBe('js-test__row-id--fish')
    })

    it('should display results where the slug matches the search term', function () {
      searchFor('special')
      expectOnlyVisibleRowToBe('js-test__row-id--marriage')
    })
  })

  function searchFor (searchTerm) {
    $('#filterTableInput').val(searchTerm).trigger('keyup')
  }

  function expectAllRowsToBeVisible () {
    expect(stepByStepRows.length).toEqual(3)
    stepByStepRows.each(function () {
      expect($(this)).toBeVisible()
    })
  }

  function expectOnlyVisibleRowToBe (rowId) {
    stepByStepRows.each(function () {
      var row = $(this)
      if (row.attr('id') === rowId) {
        expect(row).toBeVisible()
      } else {
        expect(row).toBeHidden()
      }
    })
  }
})
