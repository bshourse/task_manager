class AddColumnDeletedAtToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :deleted_at, :datetime
  end
end
