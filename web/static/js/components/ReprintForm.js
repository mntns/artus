import React from "react"
import Select from "react-select"
import channel from "../socket"

import FormContainer from "./FormContainer"

class ReprintForm extends React.Component {
  constructor() {
    super();
    this.state = {
      part: 1,
      type: undefined,
      data: undefined,
      formData: [],
      caches: [],
      activeCache: undefined
    }
  }
  handleTypeSelect(data) {
    channel.push("fields", {type: data.value})
      .receive("ok", (data) => this.setState({formData: data.fields}));
    this.setState({ type: data.value });
  }
  handleCacheSelect(data) {
    this.setState({ activeCache: data.value });
  }
  handlePartSelect(data) {
    this.setState({ part: data.value });
  }
  componentDidMount() {
    channel.push("options")
      .receive("ok", (data) => this.setState({data: data.options}));
    channel.push("caches")
      .receive("ok", (data) => this.setState({caches: data.caches}));
  }
  render() { 
    if (!this.state.data) {
      return (
          <div className="center-block">
            <i className="fa fa-spinner fa-5x fa-spin"></i>
          </div>
      )
    }

    if (this.state.caches.length == 0) {
      return (
					<div className="alert alert-warning" role="alert">
					  <strong>No working cache! </strong> 
            You have no working cache associated with your account.
            Please <a href="/caches">click here</a> to create one.
					</div>
      )
    }

    return (
        <div>
          <fieldset className="form-group">
            <label htmlFor="cacheSelect">Working Cache</label>
            <Select className="cacheSelect" name="caches" value={this.state.activeCache} options={this.state.caches} onChange={this.handleCacheSelect.bind(this)} />
          </fieldset>

          {(this.state.activeCache == undefined) ? <p>Please select a working cache.</p> :
          <div>
        
          <fieldset className="form-group">
            <label htmlFor="typeSelect">Type</label>
            <Select className="typeSelect" name="types" value={this.state.type} options={this.state.data.types} onChange={this.handleTypeSelect.bind(this)} />
          </fieldset>

          <div className="input-form-space"></div>
          
          {this.state.formData ? <FormContainer systemType={window.systemType}
                                                parentID={window.parentID}
                                                cache={this.state.activeCache} 
                                                part={3} 
          																			type={this.state.type} 
                                                data={this.state.formData} /> : <p>Please choose a type!</p>}
</div>
}
        </div>
        )
      
  }
}

export default ReprintForm;
