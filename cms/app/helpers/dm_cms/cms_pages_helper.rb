module DmCms::CmsPagesHelper

  #------------------------------------------------------------------------------
  def nested_tree(tree)  
    tree.map do |item, sub_items|
      render(:partial => 'tree', :locals => {:item => item, :sub_items => sub_items})
    end.join.html_safe  
  end
  
end
