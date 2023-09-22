class Folder < ApplicationRecord
  belongs_to :parent, class_name: 'Folder', optional: true
  has_many :children, class_name: 'Folder', foreign_key: 'parent_id'
  has_many_attached :documents, dependent: :destroy_async

  def self.fetch_all_subfolders(folder, subfolders = [])
    direct_children = Folder.where(parent_id: folder.id)
    return subfolders if direct_children.empty?

    direct_children.each do |child|
      subfolders << child
      fetch_all_subfolders(child, subfolders)
    end
    subfolders
  end

  def self.fetch_all_subfolders_sql(folder)
    query = <<-SQL
      WITH RECURSIVE subfolders AS (
        SELECT id, name, parent_id
        FROM folders
        WHERE parent_id = :folder_id
        UNION ALL
        SELECT f.id, f.name, f.parent_id
        FROM folders f
        INNER JOIN subfolders s ON f.parent_id = s.id
      )
      SELECT * FROM subfolders;
    SQL

    Folder.find_by_sql([query, { folder_id: folder.id }])
  end
end
