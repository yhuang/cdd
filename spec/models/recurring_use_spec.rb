require 'spec_helper'

describe RecurringUse do
  before :all do
    Timecop.freeze FIXED_TIME

    FIXED_FUTURE_START_DATE = 1.week.from_now.to_date
    FIXED_PAST_START_DATE   = 3.days.ago.to_date
    FIXED_END_DATE          = 5.weeks.ago.to_date
  end

  after :all do
    Timecop.return
  end

  subject { FactoryGirl.create(:recurring_use) }

  it { should respond_to(:amount) }
  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:supply) }

  let(:use_with_undefined_dates) do
    ethanol = create(:supply, name: 'Ethanol', amount: 0.0)
    create(:recurring_use, supply: ethanol, amount: 5.0, periodicity: 1)
  end

  let(:use_with_future_start_date) do
    ethanol = create(:supply, name: 'Ethanol', amount: 0.0)
    create(:recurring_use, supply: ethanol, amount: 5.0, periodicity: 1, start_date: FIXED_FUTURE_START_DATE)
  end

  let(:use_with_past_start_date) do
    ethanol = create(:supply, name: 'Ethanol', amount: 0.0)
    create(:recurring_use, supply: ethanol, amount: 5.0, periodicity: 7, start_date: FIXED_PAST_START_DATE)
  end

  let(:use_with_no_periodicity) do
    ethanol = create(:supply, name: 'Ethanol', amount: 0.0)
    create(:recurring_use, supply: ethanol, amount: 5.0, start_date: FIXED_PAST_START_DATE)
  end

  describe '#first_start_date' do
    context 'with undefined start date' do
      it 'returns nil' do
        expect(use_with_undefined_dates.first_start_date).to be_nil
      end
    end

    context 'with start date in the future' do
      it 'returns that future start date' do
        expect(use_with_future_start_date.first_start_date).to eq(FIXED_FUTURE_START_DATE)
      end
    end

    context 'with start date in the past' do
      it 'returns first start date' do
        expect(use_with_past_start_date.first_start_date).to eq(4.days.from_now.to_date)
      end
    end

    context 'with no periodicity' do
      it 'returns nil' do
        expect(use_with_no_periodicity.first_start_date).to be_nil
      end
    end
  end

  describe '#end_date' do
    let(:use_with_defined_end_date) do
      ethanol = create(:supply, name: 'Ethanol', amount: 0.0)
      create(:recurring_use, supply: ethanol, amount: 5.0, periodicity: 1, end_date: FIXED_END_DATE)
    end

    context 'with defined termination date' do
      it 'returns the termination date' do
        expect(use_with_defined_end_date.end_date).to eq(FIXED_END_DATE)
      end
    end

    context 'with undefined termination date' do
      it 'returns a date 100 years from now' do
        expect(use_with_undefined_dates.end_date).to eq(100.years.from_now.to_date)
      end
    end
  end
end