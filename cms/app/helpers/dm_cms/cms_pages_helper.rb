module DmCms::CmsPagesHelper

  #------------------------------------------------------------------------------
  def nested_tree(tree)  
    tree.map do |item, sub_items|
      render(:partial => 'tree', :locals => {:item => item}) + (sub_items.blank? ? '' : content_tag(:ul, nested_tree(sub_items), :class => "nested_tree"))
    end.join.html_safe  
  end
  
end
