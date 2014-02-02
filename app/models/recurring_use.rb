class RecurringUse < ActiveRecord::Base
  belongs_to :supply

  def first_start_date
    return nil if [periodicity, start_date].any?(&:blank?)
    return start_date if Date.today <= start_date
    start_date + periodicity * cycles
  end

  def end_date
    read_attribute(:end_date).presence || 100.years.from_now.to_date
  end

  private

  def cycles
    days       = (Date.today - start_date).to_i
    remainder  = days % periodicity
    quotient   = days / periodicity
    remainder.zero? ? quotient : quotient + 1
  end
end