# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  #--- for Aquincum admin template
  config.wrappers :aquincum, :tag => 'div', :class => 'formRow', :error_class => 'error' do |b|
    #b.use :html5
    b.use :placeholder
    b.use :label, :wrap_with => { :tag => 'div', :class => 'grid3' }
    b.wrapper :tag => 'div', :class => 'grid9' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'label', :class => 'error' }
      ba.use :hint,  :wrap_with => { :tag => 'span', :class => 'note' }
    end
    b.wrapper :tag => 'div', :class => 'clear' do |ba|
    end
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :aquincum
  config.error_notification_class = 'nNote nFailure'
  config.label_text = lambda { |label, required| "<span class='req'>#{required}</span> #{label}" }
  
end
