import "phoenix_html"

let jQuery = require('jquery');
window.$ = window.jQuery = jQuery;

import popper from "popper.js";
import "bootstrap";

//import socket from "./socket"
//import Select from "react-select"

import React from "react"
import ReactDOM from "react-dom"

import InputForm from "./components/InputForm"
import ReviewForm from "./components/ReviewForm"
import ReprintForm from "./components/ReprintForm"
import ChildForm from "./components/ChildForm"
import ReviewEditForm from "./components/ReviewEditForm"
import EditForm from "./components/EditForm"

import AdvancedSearch from "./components/search/AdvancedSearch"

// Enables tether
$(function () {
  $('[data-toggle="tooltip"]').tooltip()
});

// TODO: why only tag deletion? 
$('#tagDeleteModal').on('show.bs.modal', function (event) {
  var button = $(event.relatedTarget); // Button that triggered the modal
  var tagID = button.data('tag-id'); // Extract info from data-* attributes
  var modal = $(this);
  modal.find('.modal-body #tagToDelete').text(tagID);
  modal.find('.modal-footer #deleteButton').attr("href", "/admin/tags/" + tagID + "/delete")
});


// Aims to fix newlines in text areas
var textAreas = document.getElementsByTagName('textarea');
Array.prototype.forEach.call(textAreas, function(elem) {
    elem.placeholder = elem.placeholder.replace(/\\n/g, '\n');
});

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
