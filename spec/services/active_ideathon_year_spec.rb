require "rails_helper"

RSpec.describe ActiveIdeathonYear do
  describe ".call" do
    it "returns the active year when present" do
      active = Ideathon.create!(
        year: 2026,
        theme: "Active",
        is_active: true,
        start_date: Date.new(2026, 2, 1),
        end_date: Date.new(2026, 2, 2)
      )
      Ideathon.create!(
        year: 2025,
        theme: "Older",
        is_active: false,
        start_date: Date.new(2025, 2, 1),
        end_date: Date.new(2025, 2, 2)
      )

      expect(described_class.call).to eq(active)
    end

    it "falls back to latest year when no active year exists" do
      older = Ideathon.create!(
        year: 2024,
        theme: "Old",
        is_active: false,
        start_date: Date.new(2024, 2, 1),
        end_date: Date.new(2024, 2, 2)
      )
      latest = Ideathon.create!(
        year: 2025,
        theme: "Latest",
        is_active: false,
        start_date: Date.new(2025, 2, 1),
        end_date: Date.new(2025, 2, 2)
      )

      expect(described_class.call).to eq(latest)
      expect(described_class.call).not_to eq(older)
    end

    it "returns nil when no rows exist and create_if_missing is false" do
      expect(described_class.call).to be_nil
    end

    it "creates a default active year when requested and none exists" do
      expect {
        @result = described_class.call(create_if_missing: true)
      }.to change(Ideathon, :count).by(1)

      expect(@result).to be_present
      expect(@result.is_active).to eq(true)
      expect(@result.year).to eq(Time.zone.today.year)
    end

    it "returns the matching year when concurrent create hits unique constraint" do
      today_year = Time.zone.today.year
      existing = Ideathon.create!(
        year: today_year,
        theme: "Existing",
        is_active: false,
        start_date: Date.new(today_year, 2, 1),
        end_date: Date.new(today_year, 2, 2)
      )

      allow(Ideathon).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordNotUnique)

      result = described_class.send(:create_default_year!)
      expect(result).to eq(existing)
    end

    it "falls back to existing active year when uniqueness conflict is on active flag" do
      active = Ideathon.create!(
        year: Time.zone.today.year - 1,
        theme: "Already Active",
        is_active: true,
        start_date: Date.new(Time.zone.today.year - 1, 2, 1),
        end_date: Date.new(Time.zone.today.year - 1, 2, 2)
      )

      allow(Ideathon).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordNotUnique)

      result = described_class.send(:create_default_year!)
      expect(result).to eq(active)
    end
  end
end
