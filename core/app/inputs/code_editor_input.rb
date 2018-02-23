# Uses the CodeMirror editor
#------------------------------------------------------------------------------
class CodeEditorInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options)
    options[:mode] = (options[:mode] || 'markdown').downcase
    editor_mode = case options[:mode]
                  when 'textile'
                    :htmlmixed  # no textile mode available
                  when 'markdown'
                    :markdown
                  when 'html'
                    :htmlmixed
                  else
                    :markdown
    end

    input_html_options['codemirror-editor']   = ""
    input_html_options['data-mode']           = editor_mode
    input_html_options['data-theme']          = options[:theme] || :default

    editor_id = "codemirror_container_#{rand(1000)}"
    out  = ''
    out << "<div class='cm_toolbar'>"
    out << "  <a class='cm_cmd_bold_#{options[:mode]}' href='javascript:void(0);' data-editor='\##{editor_id}'><i class='fa fa-bold'></i></a>"
    out << "  <a class='cm_cmd_italic_#{options[:mode]}' href='javascript:void(0);' data-editor='\##{editor_id}'><i class='fa fa-italic'></i></a>"
    out << "  <a class='cm_cmd_link_#{options[:mode]}' href='javascript:void(0);' data-editor='\##{editor_id}'><i class='fa fa-link'></i></a>"
    out << "  <a class='cm_cmd_fullscreen' title='Fullscreen (Esc exits)' href='javascript:void(0);' data-editor='\##{editor_id}'><i class='fa fa-expand'></i></a>"
    out << "</div>"
    out << "<div id='#{editor_id}' #{"class='CodeMirror-autoheight'" if options[:autoheight]}>"
    (out << @builder.text_area(attribute_name, input_html_options)).html_safe
    out << "</div>"
  end
end

# def input(wrapper_options)
#   # :preview_version is a custom attribute from :input_html hash, so you can pick custom sizes
#   version = input_html_options.delete(:preview_version)
#   out = '' # the output string we're going to build
#
#   # append file input. it will work accordingly with your simple_form wrappers
#   (out << @builder.file_field(attribute_name, input_html_options)).html_safe
#
#   # check if there's an uploaded file (eg: edit mode or form not saved)
#   if object.send("#{attribute_name}?")
#     # append preview image to output
#     out << template.image_tag(object.send(attribute_name).tap {|o| break o.send(version) if version}.send('url'))
#   end
#   return out
# end
