class Supply < ActiveRecord::Migration
  def change
    create_table :supplies do |t|
      t.string :name
      t.float  :amount
    end
  end
end
