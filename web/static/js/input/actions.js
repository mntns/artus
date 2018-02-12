import channel from "../socket"

export const REQUEST_CACHES = 'REQUEST_CACHES'
export const RECEIVE_CACHES = 'RECEIVE_CACHES'
export const REQUEST_OPTIONS = 'REQUEST_OPTIONS'
export const RECEIVE_OPTIONS = 'RECEIVE_OPTIONS'
export const REQUEST_FIELDS = 'REQUEST_FIELDS'
export const RECEIVE_FIELDS = 'RECEIVE_FIELDS'
export const REQUEST_ABBREVIATIONS = 'REQUEST_ABBREVIATIONS'
export const RECEIVE_ABBREVIATIONS = 'RECEIVE_ABBREVIATIONS'

export const REQUEST_FORM_SUBMIT = 'REQUEST_FORM_SUBMIT'
export const RECEIVE_FORM_SUBMIT = 'RECEIVE_FORM_SUBMIT'

export const REQUEST_AUTOCOMPLETE = 'REQUEST_AUTOCOMPLETE'
export const RECEIVE_AUTOCOMPLETE = 'RECEIVE_AUTOCOMPLETE'

function requestCaches() {
  return {
    type: REQUEST_CACHES
  }
}

function receiveCaches(data) {
  return {
    type: RECEIVE_CACHES,
    caches: data.caches
  }
}

export function fetchCaches() {
  return dispatch => {
    dispatch(requestCaches());
    return channel.push("caches")
      .receive("ok", (data) => dispatch(receiveCaches(data)))
  }
}

function requestOptions() {
  return {
    type: REQUEST_OPTIONS
  } 
}

function receiveOptions(data) {
  return {
    type: RECEIVE_OPTIONS,
    options: data.options
  }
}

export function fetchOptions() {
  return dispatch => {
    dispatch(requestOptions());
    return channel.push("options")
      .receive("ok", (data) => dispatch(receiveOptions(data)))
  }
}

function requestFields(field_type) {
  return {
    type: REQUEST_FIELDS,
    field_type
  }
}

function receiveFields(field_type, data) {
  return {
    type: RECEIVE_FIELDS,
    field_type,
    fields: data.fields
  }
}

export function fetchFields(field_type) {
  return dispatch => {
    dispatch(requestFields(field_type));

    if (field_type == "z") {
      dispatch(fetchAbbreviations());
    }

    return channel.push("fields", {type: field_type})
      .receive("ok", (data) => dispatch(receiveFields(field_type, data)))
  }
}

function requestAbbreviations() {
  return {
    type: REQUEST_ABBREVIATIONS
  }
}

function receiveAbbreviations(data) {
  return {
    type: RECEIVE_ABBREVIATIONS,
    abbreviations: data.abbreviations
  }
}

export function fetchAbbreviations() {
  return dispatch => {
    dispatch(requestAbbreviations());
    return channel.push("abbreviations")
      .receive("ok", (data) => dispatch(receiveAbbreviations(data)))
  }
}

function requestFormSubmit() {
  return {
    type: REQUEST_FORM_SUBMIT
  }
}

function receiveFormSubmit(data) {
  return {
    type: RECEIVE_FORM_SUBMIT,
    id: data.id
  }
}

export function submitForm(formData) {
  return dispatch => {
    dispatch(requestFormSubmit());
    return channel.push("submit", {data: formData})
                  .receive("ok", (data) => dispatch(receiveFormSubmit(data)))
  }
}

function requestAutoComplete() {
  return {
    type: REQUEST_AUTOCOMPLETE
  }
}

function receiveAutoComplete(data, callback) {
  callback(data.abbreviation);
  return {
    type: RECEIVE_AUTOCOMPLETE,
    completion: data.abbreviation
  }
}

export function getAutoComplete(abbreviation_id, callback) {
  return dispatch => {
    dispatch(requestAutoComplete());
    return channel.push("abbreviations", {id: abbreviation_id})
                .receive("ok", (data) => dispatch(receiveAutoComplete(data, callback)))
  }
}