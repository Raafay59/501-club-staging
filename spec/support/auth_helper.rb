module AuthHelper
  # Stubs ApplicationController#current_user so request specs act as a signed-in user.
  # Dashboard controllers inherit that implementation (ClubDashboardController does not override it).
  def login_as(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
end
