# frozen_string_literal: true

require "rails_helper"

RSpec.describe IdeathonEvent, type: :model do
     describe "associations" do
          it { is_expected.to belong_to(:ideathon_year) }
     end

     describe "validations" do
          subject(:event) do
               described_class.new(
                 ideathon_year: ideathon_year,
                 event_name: "Kickoff",
                 event_date: Date.current,
                 event_time: Time.zone.parse("9:00")
               )
          end

          let(:ideathon_year) do
               IdeathonYear.create!(
                 name: "Ideathon 2029",
                 start_date: 1.year.from_now,
                 end_date: 1.year.from_now + 1.day,
                 is_active: true
               )
          end

          it { is_expected.to validate_presence_of(:event_name) }
          it { is_expected.to validate_presence_of(:event_date) }
          it { is_expected.to validate_presence_of(:event_time) }
     end
end
