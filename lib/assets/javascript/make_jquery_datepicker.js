jQuery(function () {
    jQuery(document).on('focus', '.make_datepicker:not(.hasDatepicker)', function () {
        // make datepicker
        var elem = jQuery(this);
        elem.datepicker(elem.data('datepicker')); // FormHelper puts the options there in JSON format
    });
});