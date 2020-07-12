var App = React.createClass({
  propTypes: {
    initialState: PropTypes.object
  },
  componentDidMount: function() {},
  componentWillMount: function() {
    this.setState(this.props.initialState);
    setInterval(this.fetchState, 2000);
  },
  fetchState: function() {
    $.ajax("/apps/" + this.props.initialState.id, {
      method: "GET",
      dataType: "json",
      context: this
    }).done(function(data) {
      this.setState(data);
      console.log(data);
      console.log("updated");
    });
  },
  handleClick: function() {
    console.log("click");
  },
  render: function() {
    return (
      <table>
        <thead>
          <tr>
            <th> </th>
            <th>LAUNCHED </th>
            <th> PODS</th>
            <th> MACHINES </th>
            <th> RUNNING </th>
          </tr>
        </thead>
        <tbody>
          {this.state.fleets.map(function(fleet, i) {
            return (
              <Fleet
                key={fleet.id}
                update={fleet.updated_at}
                initialState={fleet}
              />
            );
          })}
        </tbody>
      </table>
    );
  }
});
