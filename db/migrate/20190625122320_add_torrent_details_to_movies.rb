class AddTorrentDetailsToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :seed, :int
    add_column :movies, :peer, :int
    add_column :movies, :filesize, :string
    add_column :movies, :provider, :string
  end
end
