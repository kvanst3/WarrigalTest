class AddTypeToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :type, :string
  end
end
