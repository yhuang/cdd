class RecurringUse < ActiveRecord::Migration
  def change
    create_table :recurring_uses do |t|
      t.integer   :supply_id
      t.integer   :periodicity
      t.float     :amount
      t.date      :start_date
      t.date      :end_date
    end
  end
end
