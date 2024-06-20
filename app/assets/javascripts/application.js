// This file is used as the root JS file for the govuk_publishing_components/design
// system aspects of Collections Publisher

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/components/back-link
//= require govuk_publishing_components/components/breadcrumbs
//= require govuk_publishing_components/components/checkboxes
//= require govuk_publishing_components/components/contextual-guidance
//= require govuk_publishing_components/components/date-input
//= require govuk_publishing_components/components/details
//= require govuk_publishing_components/components/document-list
//= require govuk_publishing_components/components/error-alert
//= require govuk_publishing_components/components/error-message
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/heading
//= require govuk_publishing_components/components/hint
//= require govuk_publishing_components/components/input
//= require govuk_publishing_components/components/inset-text
//= require govuk_publishing_components/components/label
//= require govuk_publishing_components/components/layout-footer
//= require govuk_publishing_components/components/layout-for-admin
//= require govuk_publishing_components/components/list
//= require govuk_publishing_components/components/metadata
//= require govuk_publishing_components/components/reorderable-list
//= require govuk_publishing_components/components/select
//= require govuk_publishing_components/components/success-alert
//= require govuk_publishing_components/components/summary-list
//= require govuk_publishing_components/components/table
//= require govuk_publishing_components/components/textarea
//= require govuk_publishing_components/analytics
//= require components/autocomplete
//= require analytics

//= require rails-ujs

// support ES5
//= require es5-polyfill/dist/polyfill.js

// support ES6 (promises, functions, etc. - see docs)
//= require core-js-bundle/index.js

// support ES6 custom elements
//= require @webcomponents/custom-elements/custom-elements.min.js

//= require components/markdown-editor.js

window.GOVUK.approveAllCookieTypes()
window.GOVUK.cookie('cookies_preferences_set', 'true', { days: 365 })
