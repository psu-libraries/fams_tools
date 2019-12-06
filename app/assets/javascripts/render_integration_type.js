$(window).on('load',function () {
    var integrationType = $( "#label_integration_type" ).val();
    $("#integration_container").load("ai_integration/render_integrator", {integration_type:integrationType});
});

$(document).on('change', '#label_integration_type', function(evt){
    evt.preventDefault();
    evt.stopPropagation();

    var integrationType = $( "#label_integration_type" ).val();
    $("#integration_container").load("ai_integration/render_integrator", {integration_type:integrationType});
});
