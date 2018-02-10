import "phoenix_html"

// Imports jQuery and assign to window 
import jQuery from "jquery";
window.$ = window.jQuery = jQuery;

// Imports popper.js and Bootstrap
import popper from "popper.js";
import "bootstrap";

import R from "ramda";

// Imports React
import React from "react"
import ReactDOM from "react-dom"

// Imports components
import InputForm from "./components/InputForm"
import ReviewForm from "./components/ReviewForm"
import ReprintForm from "./components/ReprintForm"
import ChildForm from "./components/ChildForm"
import ReviewEditForm from "./components/ReviewEditForm"
import EditForm from "./components/EditForm"


// Admin components
import TagContainer from "./admin/TagContainer"
import AbbreviationContainer from "./admin/AbbreviationContainer"

// Enables tooltips globally 
$(function () {
  $('[data-toggle="tooltip"]').tooltip()
});


// TODO: React UI for badges

// Workaround for newlines in text areas
var textAreas = document.getElementsByTagName('textarea');
Array.prototype.forEach.call(textAreas, function(elem) {
    elem.placeholder = elem.placeholder.replace(/\\n/g, '\n');
});

// if (systemTpye)
//   ReactDOm FormCOntainer
//

if (document.getElementById("reactTag")) {
  ReactDOM.render(<TagContainer />, document.getElementById("reactTag"));
}
if (document.getElementById("reactAbbreviation")) {
  ReactDOM.render(<AbbreviationContainer />, document.getElementById("reactAbbreviation"));
}


// Invokes ReactDOM render calls based on injected systemType
switch(window.systemType) {
  case 0:
    ReactDOM.render(
        <InputForm />,
        document.getElementById("input-form")
        )
      break;
  case 1:
    ReactDOM.render(
        <ReviewForm />,
        document.getElementById("review-form")
        )
      break;
  case 2:
    ReactDOM.render(
        <ReprintForm />,
        document.getElementById("reprint-form")
        )
      break;
  case 3:
    ReactDOM.render(
        <ChildForm />,
        document.getElementById("child-form")
        );
      break;
  case 4:
    ReactDOM.render(
        <ReviewEditForm />,
        document.getElementById("review-edit-form")
        )
      break;
  case 5:
    ReactDOM.render(
        <EditForm />,
        document.getElementById("edit-form")
        );
    break;
  case 42:
    ReactDOM.render(
        <AdvancedSearch />,
        document.getElementById("advanced")
        )
      break;
}
