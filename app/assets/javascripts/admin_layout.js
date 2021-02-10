//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/all_components

//= require jquery-ui.sortable.min
//= require jquery_ujs

// support ES5
//= require es5-polyfill/dist/polyfill.js

// support ES6 (promises, functions, etc. - see docs)
//= require core-js-bundle/index.js

// support ES6 custom elements
//= require @webcomponents/custom-elements/custom-elements.min.js

//= require components/markdown-editor.js
//= require components/reorderable-list.js
//= require sections.js

$(document).ready(function () {
  GOVUK.sectionPublisher.init()
})
