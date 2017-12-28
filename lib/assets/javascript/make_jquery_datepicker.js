jQuery(function () {
    jQuery(document).on('focus', '.make_datepicker:not(.hasDatepicker)', function () { // datepicker from options stored in data
        // get options from data field
        var elem = jQuery(this);
        var dp_options = elem.data('datepicker'); // FormHelper puts the options there in JSON format

        // some options expect functional values, so let's replace the textual values with their evaluation (the evaluated value must be a function)
        var as_functions = [ // according to jQuery datepicker API documentation
            'beforeShow',
            'beforeShowDay',
            'calculateWeek',
            'onChangeMonthYear',
            'onClose',
            'onSelect'
        ];
        as_functions.forEach(function (function_name) {
            if (dp_options[function_name]) {
                dp_options[function_name] = eval(dp_options[function_name].toString());
            }
        });

        // make datepicker
        elem.datepicker(dp_options);
    });
});