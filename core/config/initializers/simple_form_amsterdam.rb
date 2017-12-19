# # Use this setup block to configure all options available in SimpleForm.
# SimpleForm.setup do |config|
#   config.wrappers :toggle, :tag => 'div', :class => "form-horizontal control-group", :error_class => 'error' do |b|
#     b.use :html5
#     b.use :placeholder
#     b.use :label
#     b.wrapper :tag => 'div', :class => 'controls on_off' do |ba|
#       ba.use :input, :wrap_with => { :tag => 'div', :class => 'checkbox inline' }
#       ba.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
#       ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
#     end
#     # b.wrapper :tag => 'div', :class => 'controls on_off' do |input|
#     #   input.wrapper :tag => 'div', :class => 'checkbox inline' do |append|
#     #     append.use :input
#     #   end
#     #   input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
#     #   input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
#     # end
#   end
#
#   config.wrappers :vertical, :tag => 'div', :class => 'control-group', :error_class => 'error' do |b|
#     b.use :html5
#     b.use :placeholder
#     b.use :label
#     b.wrapper :tag => 'div', :class => 'controls' do |ba|
#       ba.use :input
#       ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
#       ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
#     end
#   end
# end
