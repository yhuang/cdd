require 'spec_helper'

describe Supply do
  before :all do
    Timecop.freeze FIXED_TIME
  end

  after :all do
    Timecop.return
  end

  subject { FactoryGirl.create(:supply) }

  it { should respond_to(:name) }
  it { should respond_to(:amount) }
  it { should respond_to(:recurring_uses) }

  let(:non_depleted_reagent) do
    acetic_acid = create(:supply, name: 'Acetic Acid', amount: 100.0)
    acetic_acid.recurring_uses.create(amount: 9.0, periodicity: 7, start_date: 1.month.ago, end_date: 1.year.from_now)
    acetic_acid.recurring_uses.create(amount: 3.0, periodicity: 1, start_date: 2.weeks.ago)
    acetic_acid
  end

  let(:depleted_reagent) do
    ethanol = create(:supply, name: 'Ethanol', amount: 0.0)
    ethanol.recurring_uses.create(amount: 5.0, periodicity: 1, start_date: 2.weeks.ago)
    ethanol
  end

  let(:terminated_reagent) do
    toluene = create(:supply, name: 'Toluene', amount: 50.0)
    toluene.recurring_uses.create(amount: 5.0, periodicity: 1, start_date: 1.year.ago, end_date: 6.months.ago)
    toluene
  end

  let(:unused_reagent) do
    ascorbic_acid = create(:supply, name: 'Ascorbic Acid', amount: 50.0)
    ascorbic_acid.recurring_uses.create(amount: 5.0, periodicity: 1)
    ascorbic_acid
  end

  describe '#forecast' do
    context 'for non-depleted reagent' do
      it 'returns the correct date when a reagent will run out' do
        expect(non_depleted_reagent.forecast).to eq 'Sunday, February 23, 2014'
      end
    end

    context 'for depleted reagent' do
      it "returns today's date" do
        expect(depleted_reagent.forecast).to eq(FIXED_DATE)
      end
    end

    context 'for terminated reagent' do
      it 'returns nil' do
        expect(terminated_reagent.forecast).to be_nil
      end
    end

    context 'for unused reagent' do
      it 'returns nil' do
        expect(unused_reagent.forecast).to be_nil
      end
    end
  end

  describe '#destroy' do
    it 'does not orphan related recurring use' do
      supply_id = unused_reagent.id
      unused_reagent.destroy
      expect(RecurringUse.where(supply_id: supply_id).first).to be_nil
    end
  end
end