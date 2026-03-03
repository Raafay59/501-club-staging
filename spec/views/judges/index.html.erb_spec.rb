require 'rails_helper'

RSpec.describe "judges/index.html.erb", type: :view do
  describe "GET /judges" do
    it "renders a list of judges" do
      assign(:judges, [
        Judge.create!(
          judge_name: "John Doe",
          judge_title: "Senior Judge",
          judge_bio: "An experienced judge.",
          ideathon: 2026
        ),
        Judge.create!(
          judge_name: "Jane Smith",
          judge_title: "Associate Judge",
          judge_bio: "A knowledgeable judge.",
          ideathon: 2026
        )
      ])
      render
      expect(rendered).to match(/John Doe/)
      expect(rendered).to match(/Jane Smith/)
    end
  end
end
