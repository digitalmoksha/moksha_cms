# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.button_class = 'btn btn-default'
  config.boolean_label_class = nil

  #------------------------------------------------------------------------------
  # Bootstrap 3 vertical form style
  #------------------------------------------------------------------------------
  
  config.wrappers :bs3_vertical_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'col-sm-12 control-label'

    b.wrapper tag: 'div', class: 'col-sm-12' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs3_vertical_group, tag: 'div', class: "form-group", error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'col-sm-12 control-label'
    b.wrapper tag: 'div', class: 'col-sm-12' do |input|
      input.wrapper tag: 'div', class: 'input-group' do |append|
        append.use :input
      end
      input.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      input.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs3_vertical_file_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'

    b.wrapper tag: 'div' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs3_vertical_boolean, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder

    b.wrapper tag: 'div', class: 'checkbox' do |ba|
      ba.use :label_input
    end

    b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

  config.wrappers :bs3_vertical_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label_input
    b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

  #------------------------------------------------------------------------------
  # Bootstrap 3 horizontal form style
  #------------------------------------------------------------------------------
  
  config.wrappers :bs3_horizontal_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'col-sm-2 control-label'

    b.wrapper :input_wrapper, tag: 'div', class: 'col-sm-10' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs3_horizontal_file_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'col-sm-2 control-label'

    b.wrapper tag: 'div', class: 'col-sm-10' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs3_horizontal_boolean, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder

    b.wrapper tag: 'div', class: 'col-sm-offset-2 col-sm-10' do |wr|
      wr.wrapper tag: 'div', class: 'checkbox' do |ba|
        ba.use :label_input, class: 'col-sm-10'
      end

      wr.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      wr.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs3_horizontal_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder

    b.use :label, class: 'col-sm-2 control-label'

    b.wrapper tag: 'div', class: 'col-sm-10' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs3_horizontal_group, tag: 'div', class: "form-group", error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'col-sm-2 control-label'
    b.wrapper tag: 'div', class: 'col-sm-10' do |input|
      input.wrapper tag: 'div', class: 'input-group' do |append|
        append.use :input
      end
      input.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      input.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  #------------------------------------------------------------------------------
  # Bootstrap 3 horizontal form style
  # version that allows you to specify the column sizes to use
  #------------------------------------------------------------------------------
  
  # f.input :email, label_html: {class: 'col-sm-5'}, input_wrapper_html: {class: 'col-sm-6'}
  config.wrappers :bs3_horizontal_nosize, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'

    b.wrapper :input_wrapper, tag: 'div' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  # f.input :remember_me, as: :boolean, input_wrapper_html: {class: 'col-sm-offset-4 col-sm-6'} %>
  config.wrappers :bs3_horizontal_nosize_boolean, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder

    b.wrapper :input_wrapper, tag: 'div' do |wr|
      wr.wrapper tag: 'div', class: 'checkbox' do |ba|
        ba.use :label_input
      end

      wr.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      wr.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

   
  # Wrappers for forms and inputs using the Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  # config.default_wrapper = :bs3_horizontal_form
end
