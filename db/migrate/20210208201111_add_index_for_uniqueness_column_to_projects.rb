class AddIndexForUniquenessColumnToProjects < ActiveRecord::Migration[6.0]
  def change
    add_index :projects, :project_name, unique: true
  end
end
