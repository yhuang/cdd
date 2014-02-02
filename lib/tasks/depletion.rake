desc "Forecast When Chemicals Will be Depleted"

namespace :depletion do
  task load_samples: :environment do
    Supply.destroy_all

    acetic_acid = Supply.create(name: 'Acetic Acid', amount: 100.0)
    acetic_acid.recurring_uses.create(amount: 9.0, periodicity: 7, start_date: 1.month.ago, end_date: 1.year.from_now)
    acetic_acid.recurring_uses.create(amount: 3.0, periodicity: 1, start_date: 2.weeks.ago)

    ethanol = Supply.create(name: 'Ethanol', amount: 0.0)
    ethanol.recurring_uses.create(amount: 5.0, periodicity: 1, start_date: 2.weeks.ago)

    toluene = Supply.create(name: 'Toluene', amount: 50.0)
    toluene.recurring_uses.create(amount: 5.0, periodicity: 1, start_date: 1.year.ago, end_date: 6.months.ago)

    ascorbic_acid = Supply.create(name: 'Ascorbic Acid', amount: 50.0)
    ascorbic_acid.recurring_uses.create(amount: 5.0, periodicity: 1)
  end

  task forecast: :environment do
    Supply.all.each do |s|
      forecast = s.forecast
      message  = forecast.blank? ? "will not run out" : "will run out on #{forecast}"
      puts "#{s.name} #{message}"
    end
  end
end