(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}
  var $ = window.jQuery

  GOVUK.publishing = {
    unlockPublishing: function () {
      $('.publish').attr('disabled', false)
    }
  }
}())
