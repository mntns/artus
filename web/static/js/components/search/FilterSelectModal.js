import React from "react"
import ReactDOM from "react-dom"
import Select from "react-select"
import channel from "../../socket"

import FilterList from "./FilterList"

class FilterSelectModal extends React.Component {
  constructor() {
    super();
    this.state = {
    }
  }
  componentDidMount() {
    $(ReactDOM.findDOMNode(this)).modal('show');
    $(ReactDOM.findDOMNode(this)).on('hidden.bs.modal', this.props.handleHideModal);
  }
  render() { 
    return (
        <div className="modal fade">
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 className="modal-title">Add filter</h4>
              </div>
            <div className="modal-body">
              <p>Please choose the corresponding attribute.</p>
              <FilterList />
            </div>
            <div className="modal-footer"></div>
            </div>
          </div>
        </div>
        )
  }
  propTypes: {
    handleHideModal: React.PropTypes.func.isRequired
  }
}

export default FilterSelectModal;

