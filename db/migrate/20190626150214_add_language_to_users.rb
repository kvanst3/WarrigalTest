class AddLanguageToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :language, :string, default: 'EN'
  end
end
