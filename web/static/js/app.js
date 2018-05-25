import "phoenix_html"

// Imports jQuery and assign to window 
import jQuery from "jquery";
window.$ = window.jQuery = jQuery;

// Imports popper.js and Bootstrap
import popper from "popper.js";
import "bootstrap";

// Imports React
import React from "react"
import ReactDOM from "react-dom"

// Imports admin React modules
import TagContainer from "./admin/TagContainer"
import AbbreviationContainer from "./admin/AbbreviationContainer"

// Imports input form React module
import Root from "./input/containers/Root"

// Imports search bar module
import SearchBar from "./search/SearchBar"

// Enables tooltips globally 
$(function () {
  $('[data-toggle="tooltip"]').tooltip()
});

// Workaround for newlines in text areas
var textAreas = document.getElementsByTagName('textarea');
Array.prototype.forEach.call(textAreas, function(elem) {
    elem.placeholder = elem.placeholder.replace(/\\n/g, '\n');
});

// Renders tag module
if (document.getElementById("reactTag")) {
  ReactDOM.render(<TagContainer />, document.getElementById("reactTag"));
}

// Renders abbreviation module 
if (document.getElementById("reactAbbreviation")) {
  ReactDOM.render(<AbbreviationContainer />, document.getElementById("reactAbbreviation"));
}

// Renders input module
if (document.getElementById("reactInput")) {
  ReactDOM.render(<Root />, document.getElementById("reactInput"));
}

// Renders search widget
if (document.getElementById("reactSearchBar")) {
  ReactDOM.render(<SearchBar />, document.getElementById("reactSearchBar"));
}
