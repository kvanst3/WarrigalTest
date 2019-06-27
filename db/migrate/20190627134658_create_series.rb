class CreateSeries < ActiveRecord::Migration[5.2]
  def change
    create_table :series do |t|
      t.integer :season
      t.integer :episode
      t.string :title
      t.string :magnet
      t.string :subtitle

      t.timestamps
    end
  end
end
