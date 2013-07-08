module DmCore
  module RenderHelper
    
    # gives the public avatar for a user
    #------------------------------------------------------------------------------
    def avatar_for(user, size=32)
      case 
      when size <= 35
        avatar = user.user_profile.public_avatar_url(:sq35)
      when size <= 100
        avatar = user.user_profile.public_avatar_url(:sq100)
      when size <= 200
        avatar = user.user_profile.public_avatar_url(:sq200)
      else
        avatar = user.user_profile.public_avatar_url
      end
      # image_tag('dm_core/user.gif', width: size, height: size, class: 'image')
      image_tag(avatar, width: size, height: size, class: 'image')
    end

    # Used in pagination - get the current page number being displayed
    #------------------------------------------------------------------------------
    def page_number
      @page_number ||= [1, params[:page].to_i].max
    end
    
    # Wrapper to pull the list of countries from our table
    #------------------------------------------------------------------------------
    def ut_country_select(object, method, options = {:include_blank => true}, html_options = {})    
      collection = ut_country_select_collection(false)
      select(object, method, collection, options, html_options)
    end

    # Wrapper to pull the list of countries from our table
    #------------------------------------------------------------------------------
    def ut_country_select_tag(name, selected = nil, options = {:include_blank => true}, html_options = {})
      collection = ut_country_select_collection(options[:include_blank])
      select_tag(name, options_for_select(collection, selected.to_i), html_options)
    end

    # Just return the collection for the countries
    #------------------------------------------------------------------------------
    def ut_country_select_collection(include_blank = true)
      collection = (include_blank ? [[" ", ""]] : [])
      collection += ::StateCountryConstants::PRIMARY_COUNTRIES + DmCore::Country.find(:all, :order => 'english_name').collect {|p| [ p.english_name, p.id ] }    
    end

    # Wrapper to pull a list of countries from our table
    # It will also call an Ajax function which changes a container with
    # an id of 'state_select_container' to a drop down with the proper states
    # for that country.
    #------------------------------------------------------------------------------
    def ut_country_select_with_states(object, method, method_state, options = {:include_blank => true}, html_options = {})    
      collection = ::StateCountryConstants::PRIMARY_COUNTRIES + DmCore::Country.find(:all, :order => 'english_name').collect {|p| [ p.english_name, p.id ] }
      state_object_method = "#{object.to_s}[#{method_state.to_s}]"
      html_options[:id] ||= 'country_select'
      html_options.merge!({:data => {:progressid => "indicator_country", :objectname => state_object_method}})

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
          select_tag(object_method, state_options_for_select(selected_state, selected_country[:code]), {:include_blank => true}).html_safe
        else
          text_field_tag(object_method, selected_state)
        end
      end
    end
    
    #------------------------------------------------------------------------------
    def pagination(collection)
      if collection.total_entries > 1
        "<div class='pagination'>".html_safe  + 
        will_paginate(collection, :inner_window => 8, :next_label => I18n.t('core.next_page').html_safe, :previous_label => I18n.t('core.prev_page').html_safe) +
        "</div>".html_safe
      end
    end
    
  end
end
