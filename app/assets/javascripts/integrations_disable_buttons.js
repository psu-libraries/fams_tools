$(document).on('click', '#courses :submit', function () {
    var buttons = $('#courses :submit').not($(this));
    buttons.removeAttr('data-disable-with');
    buttons.attr('disabled', true);
});
$(document).on('click', '#congrant :submit', function () {
    var buttons = $('#congrant :submit').not($(this));
    buttons.removeAttr('data-disable-with');
    buttons.attr('disabled', true);
});
$(document).on('click', '#gpa :submit', function () {
    var buttons = $('#gpa :submit').not($(this));
    buttons.removeAttr('data-disable-with');
    buttons.attr('disabled', true);
});
$(document).on('click', '#publications :submit', function () {
    var buttons = $('#publications :submit').not($(this));
    buttons.removeAttr('data-disable-with');
    buttons.attr('disabled', true);
});
$(document).on('click', '#personal_contacts :submit', function () {
    var buttons = $('#personal_contacts :submit').not($(this));
    buttons.removeAttr('data-disable-with');
    buttons.attr('disabled', true);
});
$(document).on('click', '#cv_publications :submit', function () {
    var buttons = $('#cv_publications :submit').not($(this));
    buttons.removeAttr('data-disable-with');
    buttons.attr('disabled', true);
});
$(document).on('click', '#cv_presentations :submit', function () {
    var buttons = $('#cv_presentations :submit').not($(this));
    buttons.removeAttr('data-disable-with');
    buttons.attr('disabled', true);
});