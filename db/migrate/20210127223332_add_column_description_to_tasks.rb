class AddColumnDescriptionToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :description, :string
  end
end
