class AddPagesRankedModel < ActiveRecord::Migration[4.2]
  def up
    add_column    :cms_pages,         :row_order,   :integer
    rename_column :cms_contentitems,  :position,  :row_order

    #--- because of some duplications in the position column, need to 
    #    create a more unique position value.  So add up the positions
    total = 0
    CmsPage.unscoped.order(:ancestry, :position).each do |page|
      total = total + page.position
      Account.current = Account.find(page.account_id)
      page.update_attributes :row_order => total
    end
    remove_column :cms_pages,        :position
  end
  
  def down
    remove_column :cms_pages,         :row_order
    add_columnn   :cms_pages,         :position, :integer
    rename_column :cms_contentitems,  :row_order, :position
  end
end
