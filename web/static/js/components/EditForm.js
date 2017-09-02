import React from "react"
import update from "react-addons-update";
import Select from "react-select"
import channel from "../socket"

import FormContainer from "./FormContainer"

class EditForm extends React.Component {
  constructor() {
    super();
    this.state = {
      part: 1,
      type: undefined,
      data: undefined,
      formData: [],
      caches: [],
      activeCache: window.workingCacheID,
      entry: undefined
    }
  }
  handleTypeSelect(type) {
    channel.push("fields", {type: type})
      .receive("ok", (data) => this.setState({formData: data.fields}));
    this.setState({ type: type });
  }
  handleCacheSelect(data) {
    this.setState({ activeCache: data.value });
  }
  handlePartSelect(data) {
    this.setState({ part: data.value });
  }
  replaceNils(i) {
    if (i == null) {
      return "";
    } else {
      return i;
    }
  }
  traverseEntry(entry) {
    this.setState({entry: Object.keys(entry).reduce((newObj, key) => {
      newObj[key] = this.replaceNils(entry[key]);
      return newObj;
    }, {})});
    this.setState({activeCache: entry.cache_id});
    this.setState({part: entry.part});
    this.handleTypeSelect(entry.type);
    //this.setState({entry: update(this.state.entry, {$apply: function({k, v}) {if (v == null) { return ""; }}})});
  }
  componentDidMount() {
    channel.push("options")
      .receive("ok", (data) => this.setState({data: data.options}));
    channel.push("caches")
      .receive("ok", (data) => this.setState({caches: data.caches}));
    channel.push("saved_entry", {id: window.entryID})
      .receive("ok", (data) => this.traverseEntry(data.entry));
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
            Please <a href="/caches/new">click here</a> to create one.
					</div>
      )
    }

    return (
        <div>
          <fieldset className="form-group" disabled={true}>
            <label htmlFor="cacheSelect">Working Cache</label>
            <Select className="cacheSelect disabled" name="caches" value={this.state.activeCache} options={this.state.caches} disabled={true} />
          </fieldset>

          {(this.state.activeCache == undefined) ? <p>Please select a working cache.</p> :
          <div>
          <fieldset className="form-group">
            <label htmlFor="partSelect">Section of Bibliography</label>
            <Select className="partSelect disabled" name="parts" value={this.state.part} options={this.state.data.parts} disabled={true} />
          </fieldset>
        
          <fieldset className="form-group">
            <label htmlFor="typeSelect">Type</label>
            <Select className="typeSelect disabled" name="types" value={this.state.type} options={this.state.data.types} disabled={true} />
          </fieldset>

          <div className="input-form-space"></div>
          
          {this.state.formData ? <FormContainer systemType={window.systemType}
                                                cache={this.state.activeCache} 
                                                part={this.state.part} 
                                                eEntry={this.state.entry}
          																			type={this.state.type} 
                                                data={this.state.formData}/> : <p>Please choose a type!</p>}
</div>
}
        </div>
        )
      
  }
}

export default EditForm;
