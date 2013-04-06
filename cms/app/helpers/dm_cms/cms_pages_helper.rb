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
  
  #------------------------------------------------------------------------------
  def template_menu_list
    theme = current_account.theme_data
    if theme
      [['Inherit from parent', '']] + theme['templates'].collect {|key, value| [value['name'], key] }
    else
      nil
    end
  end
  
end
