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
  end
end
