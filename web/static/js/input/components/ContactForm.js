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
        element={{id: "cache", label: "Working Cache"}}
        component={SelectInput}
      />
      <hr />
    </div>
  )
}

const renderTypeBlock = ({part, dispatch, options}) => {
  return (
    <div>
      <Field 
        name="part"
        options={options.parts}
        element={{id: "part", label: "Section of Bibliography"}}
        component={SelectInput}
      />
      {part != undefined ?
      <Field 
        name="type"
        options={options.types}
        element={{id: "type", label: "Type"}}
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
  const workingCache = selector(state, 'cache');
  const part = selector(state, 'part');
  const type = selector(state, 'type');

  // TODO: Add logic for default cache

  let initialCache = {
    cache: (state.formDefinitions.cacheCount == 1) ? state.formDefinitions.caches[0] : workingCache
  }

  if (window.entryID) {
    initialCache = state.editEntry.entry;
  }

  return {
    workingCache,
    part,
    type,
    initialValues: initialCache
  }
})(ContactForm)

export default ContactForm
