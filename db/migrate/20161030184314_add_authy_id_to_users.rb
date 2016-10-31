class AddAuthyIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authy_id, :string
  end
end
