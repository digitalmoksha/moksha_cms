# encoding: utf-8
# This code was pulled from the state_select gem at http://github.com/buger/state_select
#------------------------------------------------------------------------------
module ActionView::Helpers::FormOptionsHelper

  # Return select and option tags for the given object and method, using
  # state_options_for_select to generate the list of option tags.
  #------------------------------------------------------------------------------
  def state_select(object, method, country='US', options = {}, html_options = {})
    ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_state_select_tag(country, options, html_options)
  end

  # Returns a string of option tags for states in a country. Supply a state name as +selected+ to
  # have it marked as the selected option tag.
  #
  # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
  #------------------------------------------------------------------------------
  def state_options_for_select(selected = nil, country = 'US', options = {:include_blank => true, :optgroup => true})
    state_options = ""
    if country.is_a? Enumerable
      country.each do |each_country|
        #state_options += '<option value=""></option>' if options[:include_blank]
        state_options += "<optgroup label='#{self.class.const_get(each_country.upcase+'_NAME')}'>" if options[:optgroup]
        state_options += options_for_select(self.class.const_get(each_country.upcase+'_STATES'), selected) if each_country
      end
    else
      if country
        #state_options += '<option value=""></option>' if options[:include_blank]
        state_options += "<optgroup label='#{self.class.const_get(country.upcase+'_NAME')}'>" if options[:optgroup]
        state_options += options_for_select(self.class.const_get(country.upcase+'_STATES'), selected)
      end
    end
    return state_options.html_safe
  end

  private

  US_STATES                     = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "Washington D.C.", "West Virginia", "Wisconsin", "Wyoming"] unless const_defined?("US_STATES")
  IN_STATES = INDIA_STATES      = ["Andhra Pradesh",  "Arunachal Pradesh",  "Assam", "Bihar", "Chhattisgarh", "New Delhi", "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jammu and Kashmir", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Orissa""Punjab", "Rajasthan", "Sikkim", "Tamil Nadu", "Tripura", "Uttaranchal", "Uttar Pradesh", "West Bengal"] unless const_defined?("INDIA_STATES")
  CA_STATES = CANADA_STATES     = ["Alberta", "British Columbia", "Manitoba", "New Brunswick", "Newfoundland", "Northwest Territories", "Nova Scotia", "Nunavut", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "Yukon"] unless const_defined?("CANADA_STATES")
  AU_STATES = AUSTRALIA_STATES  = ["Australian Capital Territory", "New South Wales", "Northern Territory", "Queensland", "South Australia", "Tasmania", "Victoria", "Western Australia"] unless const_defined?("AUSTRALIA_STATES")
  ES_STATES = SPAIN_STATES      = [ "Alava", "Albacete", "Alicante", "Almeria", "Asturias", "Avila", "Badajoz", "Barcelona", "Burgos", "Caceres", "Cadiz", "Cantrabria", "Castellon", "Ceuta", "Ciudad Real", "Cordoba", "Cuenca", "Girona", "Granada", "Guadalajara", "Guipuzcoa", "Huelva", "Huesca", "Islas Baleares", "Jaen", "La Coruna","Leon", "Lleida", "Lugo", "Madrid", "Malaga", "Melilla", "Murcia", "Navarra", "Ourense", "Palencia", "Palmas, Las", "Pontevedra", "Rioja, La", "Salamanda",  "Santa Cruz de Tenerife", "Segovia", "Sevila", "Soria", "Tarragona", "Teruel", "Toledo", "Valencia", "Valladolid", "Vizcaya", "Zamora", "Zaragoza"] unless const_defined?("SPAIN_STATES")
  UG_STATES = UGANDA_STATES     = ["Abim", "Adjumani", "Amolatar", "Amuria", "Apac", "Arua", "Budaka", "Bugiri", "Bukwa", "Bulisa", "Bundibugyo", "Bushenyi", "Busia", "Busiki", "Butaleja", "Dokolo", "Gulu", "Hoima", "Ibanda", "Iganga", "Jinja", "Kaabong", "Kabale", "Kabarole", "Kaberamaido", "Kabingo", "Kalangala", "Kaliro", "Kampala", "Kamuli", "Kamwenge", "Kanungu", "Kapchorwa", "Kasese", "Katakwi", "Kayunga", "Kibale", "Kiboga", "Kilak", "Kiruhura", "Kisoro", "Kitgum", "Koboko", "Kotido", "Kumi", "Kyenjojo", "Lira", "Luwero", "Manafwa", "Maracha", "Masaka", "Masindi", "Mayuge", "Mbale", "Mbarara", "Mityana", "Moroto", "Moyo", "Mpigi", "Mubende", "Mukono", "Nakapiripirit", "Nakaseke", "Nakasongola", "Nebbi", "Ntungamo", "Oyam", "Pader", "Pallisa", "Rakai", "Rukungiri", "Sembabule", "Sironko", "Soroti", "Tororo", "Wakiso", "Yumbe"] unless const_defined?("UGANDA_STATES")
  FR_STATES = FRANCE_STATES     = ["Alsace","Aquitaine","Auvergne","Bourgogne","Bretagne","Centre","Champagne-Ardenne","Corse","Franche-Comte","Ile-de-France","Languedoc-Roussillon","Limousin","Lorraine","Midi-Pyrenees","Nord-Pas-de-Calais","Basse-Normandie","Haute-Normandie","Pays de la Loire","Picardie","Poitou-Charentes","Provence-Alpes-Cote d'Azur","Rhone-Alpes"] unless const_defined?("FRENCE_STATES")
  DE_STATES = GERMAN_STATES     = ["Baden-Württemberg", "Bayern", "Berlin", "Brandenburg", "Bremen", "Hamburg", "Hessen", "Mecklenburg-Vorpommern", "Niedersachsen", "Nordrhein-Westfalen", "Rheinland-Pflaz", "Saarland", "Sachsen", "Sachsen-Anhalt", "Schleswig-Holstein", "Thüringen"]  unless const_defined?("GERMAN_STATES")
  MX_STATES = MEXICO_STATES     = ['Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 'Chiapas', 'Chihuahua', 'Coahuila', 'Colima', 'Durango', 'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 'México', 'Michoacán', 'Morelos', 'Nayarit', 'Nuevo León', 'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí', 'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatán', 'Zacatecas'] unless const_defined?("MEXICO_STATES")

  US_NAME                       = 'United States'
  IN_NAME   = INDIA_NAME        = 'India'
  CA_NAME   = CANADA_NAME       = 'Canada'
  AU_NAME   = AUSTRALIA_NAME    = 'Australia'
  ES_NAME   = SPAIN_NAME        = 'Spain'
  UG_NAME   = UGANDA_NAME       = 'Uganda'
  FR_NAME   = FRANCE_NAME       = 'France'
  DE_NAME   = GERMAN_NAME       = 'Germany'
  MX_NAME   = MEXICO_NAME       = 'Mexico'
end

class ActionView::Helpers::InstanceTag

  #------------------------------------------------------------------------------
  def to_state_select_tag(country, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    value = value(object)
    selected_value = options.has_key?(:selected) ? options[:selected] : value
    content_tag("select", add_options(state_options_for_select(selected_value, country), options, value), html_options)
  end
end


class ActionView::Helpers::FormBuilder

  #------------------------------------------------------------------------------
  def state_select(method, country = 'US', options = {}, html_options = {})
    @template.state_select(@object_name, method, country, options.merge(:object => @object), html_options)
  end

end

class StateCountryConstants

  # Primary / favorite countries - pre-pended to general list of countries
  #------------------------------------------------------------------------------
  PRIMARY_COUNTRIES = [
                          ['Austria',         13],
                          ['Czech Republic',  54],
                          ['Finland',         68],
                          ['Germany',         55],
                          ['India',           101],
                          ['Japan',           109],
                          ['Switzerland',     41],
                          ['United Kingdom',  75],
                          ['United States',   223],
                          ['------------------------', '']
                      ].freeze
  PRIMARY_COUNTRIES_CODE = [
                          ['Austria',         'AT'],
                          ['Czech Republic',  'CZ'],
                          ['Finalnd',         'FI'],
                          ['Germany',         'DE'],
                          ['India',           'IN'],
                          ['Japan',           'JP'],
                          ['Switzerland',     'CH'],
                          ['United Kingdom',  'UK'],
                          ['United States',   'US'],
                          ['------------------------', '']
                      ].freeze
  PRIMARY_COUNTRIES_NAME = [
                          ['Austria',         'Austria'],
                          ['Czech Republic',  'Czech Republic'],
                          ['Finland',         'Finland'],
                          ['Germany',         'Germany'],
                          ['India',           'India'],
                          ['Japan',           'Japan'],
                          ['Switzerland',     'Switzerland'],
                          ['United Kingdom',  'United Kingdom'],
                          ['United States',   'United States'],
                          ['------------------------', '']
                      ].freeze

  # Countries with states
  #------------------------------------------------------------------------------
  COUNTRIES_WITH_STATES = [  {:code => 'US', :id => 223},
                             {:code => 'IN', :id => 101},
                             {:code => 'DE', :id => 55},
                             {:code => 'FR', :id => 73},
                             {:code => 'AU', :id => 14},
                             {:code => 'FR', :id => 73},
                             {:code => 'UG', :id => 221},
                             {:code => 'CA', :id => 36},
                             {:code => 'MX', :id => 150} ].freeze


end
