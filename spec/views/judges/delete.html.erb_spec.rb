require 'rails_helper'

RSpec.describe "judges/delete.html.erb", type: :view do
  let(:judge) do
    Judge.create!(
      judge_name: "MyString",
      judge_title: "MyString",
      judge_bio: "MyText",
      ideathon: 2026
    )
  end

  before do
    assign(:judge, judge)
  end

  it "displays judge name" do
    render
    expect(rendered).to include("Delete MyString")
  end

  it "displays confirmation message" do
    render
    expect(rendered).to include("Are you sure you want to delete this judge? This action cannot be undone.")
  end

  it "has a delete button" do
    render
    expect(rendered).to have_button('Delete')
  end

  it "has a cancel link" do
    assign(:judge, judge)
    render
    expect(rendered).to have_link('Cancel', href: judges_path)
  end
end
