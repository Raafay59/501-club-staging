require "rails_helper"

RSpec.describe ActivityLogMessage do
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: "Tech") }

  describe ".for_sponsors_partner" do
    let(:record) { SponsorsPartner.new(year: 2025, name: "Acme", is_sponsor: true) }

    it "describes added" do
      expect(described_class.for_sponsors_partner(record, :added)).to eq("Sponsor 'Acme' was added")
    end

    it "builds structured metadata for sponsors" do
      expect(described_class.entry_for(record, :added)).to include(
        content_type: "sponsors",
        item_name: "Acme",
        message: "Sponsor 'Acme' was added"
      )
    end

    it "uses Partner when not a sponsor" do
      record.is_sponsor = false
      expect(described_class.for_sponsors_partner(record, :removed)).to eq("Partner 'Acme' was removed")
    end

    it "describes logo-only edit as photo-related" do
      saved = { "logo_url" => [ "a", "b" ] }
      expect(described_class.for_sponsors_partner(record, :edited, saved_changes: saved))
        .to eq("Logo for sponsor 'Acme' was updated")
    end
  end

  describe ".for_ideathon" do
    let(:ideathon) { Ideathon.new(year: 2026, theme: "Future") }

    it "describes ideathon added" do
      expect(described_class.for_ideathon(ideathon, :added)).to eq("Ideathon 2026 was added")
    end

    it "describes ideathon removed" do
      expect(described_class.for_ideathon(ideathon, :removed)).to eq("Ideathon 2026 was removed")
    end
  end

  describe ".import_entry_for" do
    it "builds summary metadata for imports" do
      expect(described_class.import_entry_for(Faq, 2)).to include(
        content_type: "faqs",
        item_name: "2 FAQs",
        message: "Imported 2 FAQs"
      )
    end
  end

  describe ".for_mentors_judge" do
    let(:judge) { MentorsJudge.new(year: 2025, name: "Jane", is_judge: true) }

    it "describes judge added" do
      expect(described_class.for_mentors_judge(judge, :added)).to eq("Judge 'Jane' was added")
    end

    it "describes photo-only edit" do
      saved = { "photo_url" => [ nil, "http://x" ] }
      expect(described_class.for_mentors_judge(judge, :edited, saved_changes: saved))
        .to eq("Photo for judge 'Jane' was updated")
    end
  end
end
