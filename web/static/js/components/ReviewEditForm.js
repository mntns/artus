import React from "react"
import Select from "react-select"
import channel from "../socket"

import FormContainer from "./FormContainer"

class ReviewEditForm extends React.Component {
  constructor() {
    super();
    this.state = {
      part: 1,
      type: undefined,
      data: undefined,
      formData: [],
      caches: [],
      activeCache: window.workingCacheID
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
  handleEntryLoad(data) {
    console.log("entry load");
    channel.push("fields", {type: data.entry.type})
      .receive("ok", (data) => this.setState({formData: data.fields}));
    this.setState({existingEntry: data.entry});
    console.log("entry loaded;");
  }
  componentDidMount() {
    channel.push("options")
      .receive("ok", (data) => this.setState({data: data.options}));
    channel.push("caches")
      .receive("ok", (data) => this.setState({caches: data.caches}));
    channel.push("cached_entry", {id: window.entryID})
      .receive("ok", (data) => this.handleEntryLoad(data));
  }
  render() { 
    if (!this.state.data && !this.state.existingEntry) {
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
            Please <a href="/caches/new">click here</a> to create one.
					</div>
      )
    }

    return (
        <div>
          <fieldset className="form-group">
            <label htmlFor="cacheSelect">Working Cache</label>
            <Select className="cacheSelect" name="caches" value={this.state.existingEntry.cache} options={this.state.caches} onChange={this.handleCacheSelect.bind(this)} />
          </fieldset>

          {(this.state.existingEntry.cache == undefined) ? <p>Please select a working cache.</p> :
          <div>
          <fieldset className="form-group">
            <label htmlFor="partSelect">Section of Bibliography</label>
            <Select className="partSelect" name="parts" value={this.state.existingEntry.part} options={this.state.data.parts} onChange={this.handlePartSelect.bind(this)} />
          </fieldset>
        
          <fieldset className="form-group">
            <label htmlFor="typeSelect">Type</label>
            <Select className="typeSelect" name="types" value={this.state.existingEntry.type} options={this.state.data.types} onChange={this.handleTypeSelect.bind(this)} />
          </fieldset>

          <div className="input-form-space"></div>
          
          {this.state.existingEntry ? <FormContainer systemType={window.systemType}
                                                cache={this.state.existingEntry.cache} 
                                                part={this.state.existingEntry.part} 
          																			type={this.state.existingEntry.type}
                                                data={this.state.formData}
                                                eEntry={this.state.existingEntry} /> : <p>Please choose a type!</p>}
</div>
}
        </div>
        )
      
  }
}

export default ReviewEditForm;
