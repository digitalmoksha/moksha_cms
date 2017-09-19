class AddTeaserFlag < ActiveRecord::Migration[4.2]
  def up
    add_column    :lms_courses,   :teaser_only,     :boolean, :default => false
  end

  def down
    add_column    :lms_courses,   :teaser_only
  end
end
