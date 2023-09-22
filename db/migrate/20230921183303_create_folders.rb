class CreateFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :folders do |t|
      t.string :name

      t.timestamps
    end
    add_reference :folders, :parent, foreign_key: { to_table: :folders, on_delete: :cascade }
  end
end
