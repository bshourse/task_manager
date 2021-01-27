class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.belongs_to :user, index: true
      t.string :project_name
      t.timestamps
    end
  end
end
