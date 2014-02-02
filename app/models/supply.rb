class Supply < ActiveRecord::Base
  has_many :recurring_uses, dependent: :destroy

  def forecast
    reset_use
    current_use    = {
      amount:   0.0,
      use_date: Date.today.strftime(LONG_ENGLISH_DATE_FORMAT)
    }
    current_date   = current_use[:use_date]
    current_amount = amount

    while current_amount > 0
      current_date    = current_use[:use_date]
      current_use     = next_use
      break if current_use.blank?
      current_amount -= current_use[:amount].to_f
    end
    current_use.blank? ? nil : current_date
  end

  private

  def reset_use
    @rows   = []
    @offset = nil
    @limit  = nil
  end

  def next_use
    @rows ||= []
    @rows   = fetch_rows if @rows.blank?
    to_json @rows.shift
  end

  def fetch_rows
    uses = active_uses
    return [] if uses.blank?

    @limit  ||= uses.count
    @offset ||= 0

    select_clause = uses.map { |use| generate_series(use) }.join ' UNION ALL '
    @rows         = ActiveRecord::Base.connection.execute(
      <<-eos
        #{select_clause}
        ORDER BY
          date, amount
        OFFSET
          #{@offset}
        LIMIT
          #{@limit}
      eos
    ).values
    @offset += @limit
    @rows
  end

  def active_uses
    recurring_uses.select { |use| use.start_date.present? && Date.today <= use.end_date }
  end

  def generate_series(use)
    start_date = use.first_start_date
    end_date   = use.end_date
    <<-eos
      SELECT
        #{use.amount} AS amount, date
      FROM
        generate_series('#{start_date}'::date, '#{end_date}'::date, interval '#{use.periodicity} days') AS date
    eos
  end

  def to_json(row)
    return if row.blank?

    use_date = Date.strptime(row[1], LONG_DATETIME_FORMAT)
    {
      amount:   row[0],
      use_date: use_date.strftime(LONG_ENGLISH_DATE_FORMAT)
    }
  end
end