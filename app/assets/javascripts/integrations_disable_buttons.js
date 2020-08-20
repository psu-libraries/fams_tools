$(document).on('click', ':submit', function () {
    var buttons = $(':submit').not($(this));
    buttons.removeAttr('data-disable-with');
    buttons.attr('disabled', true);
});
