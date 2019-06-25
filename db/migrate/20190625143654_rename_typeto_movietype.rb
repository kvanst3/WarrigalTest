class RenameTypetoMovietype < ActiveRecord::Migration[5.2]
  def change
    rename_column :movies, :type, :movietype
  end
end
