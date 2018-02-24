import React, { Component, PropTypes } from 'react';
import { connect } from 'react-redux';
import { fetchEntry, fetchCaches, fetchOptions, fetchFields, submitForm } from '../actions';
import ContactForm from "../components/ContactForm"

class AsyncApp extends Component {
  constructor(props) {
    super(props);
    // this.handleChange = this.handleChange.bind(this);
    // this.handleRefreshClick = this.handleRefreshClick.bind(this);
  }
  componentDidMount() {
    // Forces scrollbar to appear
    $("body").css("overflow-y", "scroll");
    
    // Fetches caches and options
    const { dispatch } = this.props;
    dispatch(fetchCaches());
    dispatch(fetchOptions());

    // Fetches entry if edit view
    if (window.entryID) {
      dispatch(fetchEntry(window.entryID));
    }
  }
  
  submitCallback(path) {
    window.location.href = path + "#success";
  }
  render () {
    const { dispatch, fetching, cacheCount, caches, options, fields } = this.props;
    
    if (fetching) {
      return (
          <div className="center-block">
            <i className="fa fa-spinner fa-5x fa-spin"></i>
          </div>
      )
    }


    return (
      <div> 
        <ContactForm onSubmit={(v) => dispatch(submitForm(v, this.submitCallback))} {...this.props} />
      </div>
    );
  }
}

// AsyncApp.propTypes = {
//   selectedReddit: PropTypes.string.isRequired,
//   posts: PropTypes.array.isRequired,
//   isFetching: PropTypes.bool.isRequired,
//   lastUpdated: PropTypes.number,
//   dispatch: PropTypes.func.isRequired
// };

function mapStateToProps(state) {
  const { fetching, abbreviations, cacheCount, caches, options, fields  } = state.formDefinitions;
  const { cfetching, completion } = state.autoComplete;
  let nProps = {
    completion: completion,
    fetching: fetching || cfetching,
    cacheCount: cacheCount,
    caches: caches,
    options: options,
    abbreviations: abbreviations,
    fields: fields
  }
  return nProps;
}

export default connect(mapStateToProps)(AsyncApp);
