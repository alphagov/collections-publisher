/* eslint-env jasmine, jquery */
/* global GOVUK loadFixtures */

describe('Step by step publisher component', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML = loadFixtures('overview-table.html')

    document.body.appendChild(container)
    GOVUK.stepByStepPublisher.init()
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  describe('#bindOverviewTableFilter', function () {
    it('should display all step by steps by default', function () {
      var stepByStepRows = $('.step-by-step-list__table .govuk-table__row')
      expectAllRowsToBeVisible(stepByStepRows)
    })
  })

  function expectAllRowsToBeVisible (stepByStepRows) {
    expect(stepByStepRows.length).toEqual(3)
    stepByStepRows.each(function () {
      expect($(this)).toBeVisible()
    })
  }
})
