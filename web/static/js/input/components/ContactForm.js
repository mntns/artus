import React from 'react'
import { connect } from 'react-redux';
import { Field, FieldArray, reduxForm, formValueSelector } from 'redux-form'
import { getAutoComplete, fetchFields, submitForm} from "../actions"
import FormElement from "./FormElement"
import { SubmitButton } from "./Helpers"
import { SelectInput } from "./Inputs"
import R from "ramda"

const handleAutoComplete = (v, dispatch, change) => {
  dispatch(getAutoComplete(v, ((c) => {
    change("ser_title", c.title);
    change("publ_pub_house", c.publisher);
    change("publ_pub_place", c.place);
    change("biblio_issn", c.issn);
  })))
}

const renderMembers = ({ change, dispatch, fields, abbreviations, meta: { touched, error, submitFailed  }  }) => {
	return( <div>
		{fields.map((member, index) =>
			<Field
        name={member.id}
				label={member.label}
        options={member.id == "ser_code" ? abbreviations : []}
        onChange={member.id == "ser_code" ? (v) => handleAutoComplete(v.id, dispatch, change) : null}
        key={index}
        element={member}
				component={FormElement}
			/>
		)}
	</div>)
}

const renderCacheBlock = (caches, cacheCount) => {
  if (cacheCount == 0)
    return (
      <div className="alert alert-warning" role="alert">
        <strong>No Working Cache! </strong> 
        You have no Working Cache associated with your account.
        Please <a href="/caches/new">click here</a> to create one.
      </div>
    )
  
  return (
    <div>
      <Field 
        name="cache"
        options={caches}
        element={{required: true, id: "cache", label: "Working Cache", disabled: (window.inputType == "edit")}}
        component={SelectInput}
      />
      <hr />
    </div>
  )
}

const renderTypeBlock = ({type, part, dispatch, options}) => {
  return (
    <div>
      <Field 
        name="part"
        options={options.parts}
        element={{required: true, id: "part", label: "Section of Bibliography", disabled: (window.inputType == "edit")}}
        component={SelectInput}
      />
      {part != undefined ?
      <Field 
        name="type"
        options={options.types}
        element={{required: true, id: "type", label: "Type", disabled: (window.inputType == "edit" || window.inputType == "article" || window.inputType == "review")}}
        onChange={(e) => dispatch(fetchFields(e.value))}
        component={SelectInput}
      />
      : null}
      <hr />
    </div>
  )
}

const renderFieldBlock = (props) => (
  <div className="mb-5">
    <FieldArray {...props} name="members" component={renderMembers}/>
    <SubmitButton isEdit={window.entryID ? true : false} />
  </div>
)

const renderFormContainer = (props) => (
  <div>
    {renderTypeBlock(props)}
    {props.type != undefined ? renderFieldBlock(props) : null}
  </div>
)

let ContactForm = props => {
	const { workingCache, dispatch, handleSubmit, cacheCount, caches, options, fields  } = props

	return (
    <form onSubmit={handleSubmit} >
      {renderCacheBlock(caches, cacheCount)}
      {(workingCache != undefined) ? renderFormContainer(props) : null}
		</form>
	)
}

ContactForm = reduxForm({
	form: 'input',
  enableReinitialize: true
})(ContactForm)

const selector = formValueSelector('input')
ContactForm = connect(state => {
  // Selects cache, part and type
  const workingCache = selector(state, 'cache');
  const part = selector(state, 'part');
  const type = selector(state, 'type');

  let initialValues = {};
  let cache = R.ifElse(R.equals(1), R.always(state.formDefinitions.caches[0]), R.always(workingCache));

  // Sets cache
  initialValues = R.assoc('cache', cache(state.formDefinitions.cacheCount), initialValues);

  // Merges data of editEntry
  if (window.inputType == "edit" && window.entryID) {
    initialValues = R.merge(initialValues, state.editEntry.entry);

    if (state.editEntry.entry.reviewer) {
      initialValues = R.assoc('type', {value: "r", label: "Review"}, initialValues);
    }
  }

  // Set type to a for article
  if (window.inputType == "article" && state.formDefinitions.options.types && window.entryID) {
    initialValues = R.merge(initialValues, state.editEntry.entry);
    initialValues = R.assoc('type', R.head(state.formDefinitions.options.types), initialValues);
  }

  if (window.inputType == "review" && state.formDefinitions.options.types && window.entryID) {
    initialValues = R.assoc('type', {value: "r", label: "Review"}, initialValues);
  }

  return {
    workingCache,
    part,
    type,
    initialValues: initialValues
  }
})(ContactForm)

export default ContactForm
