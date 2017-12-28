require 'date'

module JqueryDatepicker
  module FormHelper
    include ActionView::Helpers::JavaScriptHelper

    # Method that generates datepicker input field inside a form
    def datepicker(object_name, method, options = {})
      JqueryDatepicker::Tags.new(object_name, method, self, options).render
    end
  end

end

module JqueryDatepicker::FormBuilder
  def datepicker(method, options = {})
    @template.datepicker(@object_name, method, objectify_options(options))
  end

  def datetime_picker(method, options = {})
    @template.datepicker(@object_name, method, objectify_options(options), true)
  end
end

class JqueryDatepicker::Tags < ActionView::Helpers::Tags::TextField

  FORMAT_REPLACEMENTES = { "yy" => "%Y", "mm" => "%m", "dd" => "%d", "d" => "%-d", "m" => "%-m", "y" => "%y", "M" => "%b"}

  def self.default_dp_options
    {
        dateFormat: 'dd-mm-yy'
    }
  end

  # Extending ActionView::Helpers::Tags module to make Rails build the name and id
  # Just returns the options before generate the HTML in order to use the same id and name (see to_input_field_tag mehtod)
  def initialize(object_name, method, template_object, options)
    dp_options, tf_options = split_options(options)

    # default dp options
    dp_options.reverse_merge!(self.class.default_dp_options)


    # format value to match date format
    @dateFormat = dp_options[:dateFormat]

    # format dp_options holding date
    dp_options.merge!(dp_options.slice(*date_datepicker_options).transform_values {|v| format_date(v, @dateFormat)})

    # add class make_datepicker
    tf_options[:class] = (Array.wrap(tf_options[:class]) + [:make_datepicker]).join(' ')

    # transmit dp options in data field of tf options, permitting caller to overwrite values
    tf_options[:data] = {datepicker: dp_options}.deep_merge(tf_options.fetch(:data) {{}})

    super(object_name, method, template_object, tf_options)
  end

  def render
    super do |options|
      options['value'] = format_date(options['value'], @dateFormat)
    end
  end

  def available_datepicker_options
    %i[altField altFormat appendText autoSize beforeShow beforeShowDay buttonImage buttonImageOnly buttonText calculateWeek changeMonth changeYear closeText constrainInput currentText dateFormat dayNames dayNamesMin dayNamesShort defaultDate duration firstDay gotoCurrent hideIfNoPrevNext isRTL maxDate minDate monthNames monthNamesShort navigationAsDateFormat nextText numberOfMonths onChangeMonthYear onClose onSelect prevText selectOtherMonths shortYearCutoff showAnim showButtonPanel showCurrentAtPos showMonthAfterYear showOn showOptions showOtherMonths showWeek stepMonths weekHeader yearRange yearSuffix]
  end

  def date_datepicker_options
    [:defaultDate, :minDate, :maxDate]
  end

  def split_options(options)
    tf_options = options.slice!(*available_datepicker_options)
    return options, tf_options
  end

  def format_date(tb_formatted, format)
    if tb_formatted.blank?
      return nil
    end

    new_format = translate_format(format)
    case tb_formatted
    when String
      Date.parse(tb_formatted)
    else
      tb_formatted.to_date
    end.strftime(new_format)

  rescue ArgumentError
    nil # or maybe tb_formatted?
  end

  # Method that translates the datepicker date formats, defined in (http://docs.jquery.com/UI/Datepicker/formatDate)
  # to the ruby standard format (http://www.ruby-doc.org/core-1.9.3/Time.html#method-i-strftime).
  # This gem is not going to support all the options, just the most used.

  def translate_format(format)
    format.gsub(/#{FORMAT_REPLACEMENTES.keys.join("|")}/) { |match| FORMAT_REPLACEMENTES[match] }
  end

  def self.field_type
    'text'
  end

end
