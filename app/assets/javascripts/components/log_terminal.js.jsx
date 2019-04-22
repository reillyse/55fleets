var LogTerminal = React.createClass({

    propTypes: {
        machineID: React.PropTypes.number.isRequired
    },
    switchOnLogs: function() {
        console.log("swithcing on loggin");
        $.ajax({
            method: "PUT",
            url: "machines/" + this.props.machineID + "/log",
            dataType: "json",
            complete: function () {console.log("switched on logging")},
            error: function (message) {console.log("error");
                console.log(message)
            }

        })

    },

    componentWillMount: function() {
        this.setState(this.props);
        this.setState({logs: new Array(), lastLogTimestamp: 0, fetchingLogs: true});

        if (this.props.fetchingLogs)
        setTimeout(this.fetchLogs,0);

    },

    stopFetchingLogs: function () {
        console.log("Stop fetching logs");
        this.setState({fetchingLogs: false});

    },

    startFetchingLogs: function() {
        console.log("Start fetching logs");
        this.switchOnLogs();

        if (this.state.fetchingLogs) {
            return true;
        }


        this.setState({fetchingLogs: true});
    },

    scrollDiv: function (element) {
        element = $(element).parent();
	if (element.is(":hover") == false) {
	    element.animate({ scrollTop: element[0].scrollHeight}, 100);
	}
    },


    fetchLogs: function () {
        console.log("Fetching LOGS");
        $.ajax({

	    url: "fleets/log_entries/"+ this.props.machineID + "/next_log/" +   this.state.lastLogTimestamp + "/timestamp",
	    type: "GET",
	    dataType: "json",
            context: this,
            success: function (data) {

                console.log(data);

                this.state.logs = this.state.logs.concat(data);
                if (data.length > 0) {
                    this.setState({lastLogTimestamp: data[data.length -1].log_line});
                }

                this.forceUpdate();

            },
            error: function (data) {
                console.log("Error");
                console.log(data);

            },
            complete: function (data) {
                console.log("checking fetching logs");

                if (this.state.fetchingLogs) {
                    var interval = 2000;
                    if (data.responseText =="") {
                        console.log("No data slowing down");
                        interval = 5000;
                    } else {
                        console.log("Got data speeding up");
                        interval = 500;

                    }

                    var intervalID = setTimeout(this.fetchLogs,interval);



                } else {
                    console.log("Not fetching logs any more");
                }
            }
        })

    },
    componentDidUpdate: function(prevProps, prevState){
        if (this.myTerminal != null) {
            this.scrollDiv(this.myTerminal);
        }
    },

    render: function () {
        return (
            <div  ref={(ref) => this.myTerminal = ref} >
                {this.state.logs.length > 0  ? this.state.logs[0].stdout : ""}
                {this.state.logs.map(function (line,i) {
                     return (<div key={i._id} className="logline">
                <span className="timestamp">
                    {moment(line.created_at).format("DD/MM/YY H:mm:ss ")}
                </span>
                <span className="stdout">
                    {line.stdout}
                </span>
                <span className="stderr">
                    {line.stderr}
                </span>
                     </div>)

                 })}
            </div>
        )
    }
})
