class ChangeColumnTypeStatus < ActiveRecord::Migration[6.0]
  def up
    change_column :tasks, :status, :integer
    add_index :tasks, :status
  end

  def down
    change_column :tasks, :status, :string
  end
end
