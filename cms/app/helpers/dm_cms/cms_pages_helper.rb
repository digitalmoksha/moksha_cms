module DmCms::CmsPagesHelper

  #------------------------------------------------------------------------------
  def nested_tree(tree)
    tree.map do |item, sub_items|
      render(:partial => 'tree', :locals => {:item => item, :sub_items => sub_items})
    end.join.html_safe
  end

  #------------------------------------------------------------------------------
  def nested_tree_sidebar(tree)
    tree.map do |item, sub_items|
      render(:partial => 'tree_sidebar', :locals => {:item => item, :sub_items => sub_items})
    end.join.html_safe
  end

  # Return a list of templates defined in the theme.yml and it's parent theme.
  # The child templates should override any parent templates
  #------------------------------------------------------------------------------
  def template_menu_list
    theme = current_account.theme_data
    unless theme.empty?
      templates = (current_account.theme_data(parent: true)['templates'] || {}).merge(theme['templates'] || {})
      [['Inherit from parent', '']] + templates.collect {|key, value| [value['name'], key] }
    else
      nil
    end
  end

  #------------------------------------------------------------------------------
  def template_name(search_for)
    template_item = template_menu_list.detect {|x| x[1] == search_for}
    template_item ? template_item[0] : ''
  end

end
