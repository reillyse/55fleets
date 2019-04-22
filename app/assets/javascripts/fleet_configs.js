$(function(){

    $(".pod-config").hide();
    $(".pod-config").first().show();

    $("#new-pod-button").click(function() {
        $(".pod-config:hidden").last().show();
    }
                              );
}
       )
