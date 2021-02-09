class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.belongs_to :project, index: true
      t.belongs_to :user, index: true
      t.string :task_name
      t.integer :performer_id
      t.date :due_date
      t.time :implementation_time
      t.timestamps
    end
  end
end
