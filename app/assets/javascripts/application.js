// This file is used as the root JS file for the govuk_publishing_components/design
// system aspects of Collections Publisher

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/lib
//= require govuk_publishing_components/components/checkboxes
//= require govuk_publishing_components/components/contextual-guidance
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/metadata
//= require govuk_publishing_components/components/reorderable-list
//= require govuk_publishing_components/components/table
//= require govuk_publishing_components/components/tabs
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
