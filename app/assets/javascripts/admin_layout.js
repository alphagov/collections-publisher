//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/all_components

//= require jquery-ui.sortable.min
//= require jquery_ujs

//= require ace-builds/src/ace
//= require ace-builds/src/mode-yaml

// support ES5
//= require es5-polyfill/dist/polyfill.js

// support ES6 (promises, functions, etc. - see docs)
//= require core-js-bundle/index.js

// support ES6 custom elements
//= require @webcomponents/custom-elements/custom-elements.min.js

//= require components/markdown-editor.js

var editor = ace.edit("editor");

var YamlMode = ace.require("ace/mode/yaml").Mode;
editor.session.setMode(new YamlMode());
