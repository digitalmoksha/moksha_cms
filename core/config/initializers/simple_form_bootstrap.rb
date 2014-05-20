# Configured for use with Bootstrap 2
#------------------------------------------------------------------------------

SimpleForm.setup do |config|
  config.wrappers :bs2_horizontal_form, tag: 'div', class: 'form-horizontal control-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'
    b.wrapper tag: 'div', class: 'controls' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  #--- same as ::bs2_horizontal_form wrapper, but here for backward compatability
  config.wrappers :bootstrap2, tag: 'div', class: 'form-horizontal control-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'
    b.wrapper tag: 'div', class: 'controls' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs2_vertical_form, tag: 'div', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end

  config.wrappers :bs2_prepend, tag: 'div', class: "form-horizontal control-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end

  config.wrappers :bs2_append, tag: 'div', class: "form-horizontal control-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-append' do |append|
        append.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end

  config.wrappers :bs2_prepend_append, tag: 'div', class: "form-horizontal control-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-prepend input-append' do |append|
        append.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end

  config.wrappers :bs2_inline_checkbox, tag: 'div', class: 'form-horizontal control-group', error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper tag: 'div', class: 'controls' do |ba|
      ba.use :label_input, wrap_with: { class: 'checkbox inline' }
      ba.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end
  end
end
