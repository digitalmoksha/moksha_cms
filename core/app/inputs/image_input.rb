# frozen_string_literal: true

class ImageInput < SimpleForm::Inputs::FileInput
  def input(wrapper_options)
    # :preview_version is a custom attribute from :input_html hash, so you can pick custom sizes
    version = input_html_options.delete(:preview_version)
    out     = String.new

    # append file input. it will work accordingly with the simple_form wrappers
    (out << @builder.file_field(attribute_name, input_html_options)).html_safe

    # check if there's an uploaded file (eg: edit mode or form not saved)
    if object.send("#{attribute_name}?")
      out << template.image_tag(object.send(attribute_name).tap {|o| break o.send(version) if version}.send('url'))
    end

    out
  end
end
