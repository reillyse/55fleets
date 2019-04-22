$(function (){

    $(".terminal-log").each(
	function(index,value) {
            console.log(this);
	    var interval = 10;
            $("#" + value.id).data("last_log_timestamp","0");
	    function getLogs(machine_id) {
                console.log("calling getLogs with machine_id == " + machine_id)
                    var element = $("#" + machine_id);
	        var m_id = element.data("machine_id");
                console.log("m_id == " + m_id)
	            element.data("last_log_timestamp");

		$.ajax({

		    url: "log_entries/"+ m_id +"/next_log/" +   element.data("last_log_timestamp") + "/timestamp",
		    type: "GET",
		    dataType: "html",
		    success: function (data) {
			if(data.length > 0){
			    element.append(data);
			    element.append("<div class='clearer'></div>");
			    if (element.is(":hover") == false) {
			        element.animate({ scrollTop: element[0].scrollHeight}, 40);
			    }
			    //var height = element.height();
			    //element.animate({scrollTop: height}, 500);
			    interval = 20;
			} else {
			    interval = 2000;
			}
		    },
		    error: function (xhr, status) {
			console.log("Sorry, there was a problem!");
		    },
		    complete: function (xhr, status) {
			var t = setTimeout(function() {getLogs(machine_id)}, interval);


		    }
		});
	    }
            console.log("this.id == " + value.id);
	    setTimeout(function() {getLogs(value.id)}, interval);
	});
});



