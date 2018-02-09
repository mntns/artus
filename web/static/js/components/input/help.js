import React from "react"
import ReactDOM from "react-dom"
import channel from "../../socket"

function createMarkup(data) {
  return {__html: data};
}

class HelpModal extends React.Component {
  constructor() {
    super();
    this.state = {
      data: {title: "Loading title...", body: "Loading body..."}
    }
  }
  componentWillMount() {
    channel.push("modal", {id: this.props.id})
      .receive("ok", (data) => this.setState({data: data}))
  }
  componentDidMount() {
    let modalDOMNode = ReactDOM.findDOMNode(this);
    
    $(modalDOMNode).modal('show');
    $(modalDOMNode).on('hidden.bs.modal', this.props.handleHide);
  }
  render() {
      return (
          <div className="modal fade" tabIndex="-1" role="dialog" aria-hidden="true">
            <div className="modal-dialog" role="document">
              <div className="modal-content">
                <div className="modal-header">
               <button type="button" className="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
          </button>
          <h4 className="modal-title">{this.state.data.title}</h4>
          </div>
          <div className="modal-body" dangerouslySetInnerHTML={createMarkup(this.state.data.body)}></div>
          </div>
          </div>
          </div>
          );
  }
}

class HelpButton extends React.Component {
  constructor() {
    super();
    this.state = {
      show: false
    }
  }
  handleShowModal() {
    this.setState({show: true});
  }
  handleHideModal() {
    this.setState({show: false});
  }
  render() {
    return (
        <span className="float-right">
          {this.state.show ? <HelpModal id={this.props.id} handleHide={this.handleHideModal.bind(this)} /> : ""}     
          <i className="fa fa-info-circle fa-lg fa-fw" aria-hidden="true" onClick={this.handleShowModal.bind(this)}></i>
        </span>
        );
  }
}

export default HelpButton;
