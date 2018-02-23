module DmCore
  module RenderHelper
    # gives the public avatar for a user
    #------------------------------------------------------------------------------
    def avatar_for(user, size=32, options = {})
      user = User.new(user_profile: UserProfile.new) if user.nil? # avatar comes from the user profile
      present(user).avatar_for(size, options)
    end

    # Used in pagination - get the current page number being displayed
    #------------------------------------------------------------------------------
    def page_number
      @page_number ||= [1, params[:page].to_i].max
    end

    # Wrapper to pull the list of countries from our table
    #------------------------------------------------------------------------------
    def ut_country_select(object, method, options = {include_blank: true}, html_options = {})
      collection = ut_country_select_collection(include_blank: false, as: options[:as])
      select(object, method, collection, options, html_options)
    end

    # Wrapper to pull the list of countries from our table
    #------------------------------------------------------------------------------
    def ut_country_select_tag(name, selected = nil, options = {include_blank: true}, html_options = {})
      collection = ut_country_select_collection(options)
      select_tag(name, options_for_select(collection, selected), html_options)
    end

    # Just return the collection for the countries
    # as: :id      return the ids of the Country objects
    # as: :code    return the 2-letter country code
    # as: :name    return the country's english name
    # (old interface passed in only a true or false to indicate include_blank)
    #------------------------------------------------------------------------------
    def ut_country_select_collection(options = {include_blank: true, as: :id})
      options = {include_blank: options, as: :id} if !options.is_a?(Hash)

      collection = (options[:include_blank] ? [[" ", ""]] : [])
      case options[:as]
      when :code
        collection += ::StateCountryConstants::PRIMARY_COUNTRIES_CODE + DmCore::Country.order('english_name').collect {|p| [ p.english_name, p.code ] }
      when :name
        collection += ::StateCountryConstants::PRIMARY_COUNTRIES_NAME + DmCore::Country.order('english_name').collect {|p| [ p.english_name, p.english_name ] }
      else
        collection += ::StateCountryConstants::PRIMARY_COUNTRIES + DmCore::Country.order('english_name').collect {|p| [ p.english_name, p.id ] }
      end
    end

    # Wrapper to pull a list of countries from our table
    # It will also call an Ajax function which changes a container with
    # an id of 'state_select_container' to a drop down with the proper states
    # for that country.
    #------------------------------------------------------------------------------
    def ut_country_select_with_states(object, method, method_state, options = {include_blank: true}, html_options = {})
      collection = ut_country_select_collection(include_blank: false, as: options[:as])
      state_object_method = "#{object.to_s}[#{method_state.to_s}]"
      html_options[:id] ||= 'country_select'
      html_options.merge!({data: {progressid: "indicator_country", objectname: state_object_method}})

      select(object, method, collection, options, html_options)
    end

    # Generates a select menu or a text field, depending on if there are states
    # associated with the chosen country.
    # => object_method: name of model 'state' field, used for the tag, such as 'student[state]'
    # => country_id: globlized id of the selected country
    # => selected_state: name of the current state selected
    #------------------------------------------------------------------------------
    def ut_state_selection(object_method, country_id = 0, selected_state = nil)
      if country_id == 0 or country_id.nil?
        select_tag(object_method, "<option value=''>Please select a country".html_safe)
      else
        selected_country = ::StateCountryConstants::COUNTRIES_WITH_STATES.find {|x| x[:id] == country_id}
        if selected_country
          select_tag(object_method, state_options_for_select(selected_state, selected_country[:code]), {include_blank: true}).html_safe
        else
          text_field_tag(object_method, selected_state)
        end
      end
    end

    #------------------------------------------------------------------------------
    def pagination(collection, options = {version: :original})
      if collection.total_entries > 1
        if options[:version] == :original
          content_tag(:div, class: 'pagination') do
            will_paginate(collection, {inner_window: 8, next_label: I18n.t('core.next_page').html_safe, previous_label: I18n.t('core.prev_page').html_safe}.merge(options))
          end
        else
          will_paginate(collection, {inner_window: 8, next_label: I18n.t('core.next_page').html_safe, previous_label: I18n.t('core.prev_page').html_safe}.merge(options))
        end
      end
    end

    # Return the name of the simple_form wrapper to use, which the theme can
    # specify.  Typically either :bs2_horizontal_form or :bs3_horizontal_form.
    #------------------------------------------------------------------------------
    def simple_form_theme_wrapper
      Account.current.theme_option(:simple_form_wrapper) || :bs2_horizontal_form
    end
  end
end
