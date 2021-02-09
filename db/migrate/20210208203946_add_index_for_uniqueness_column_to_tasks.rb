class AddIndexForUniquenessColumnToTasks < ActiveRecord::Migration[6.0]
  def change
    add_index :tasks, :task_name, unique: true
  end
end
