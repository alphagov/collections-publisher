class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :uid
      t.string :organisation_slug
      t.string :permissions
      t.boolean :remotely_signed_out, default: false
    end
  end
end
