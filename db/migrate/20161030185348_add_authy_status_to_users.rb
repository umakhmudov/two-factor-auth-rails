class AddAuthyStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authy_status, :string
  end
end
