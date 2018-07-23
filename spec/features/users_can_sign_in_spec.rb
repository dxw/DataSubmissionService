require 'rails_helper'

RSpec.feature 'Signing in as a user' do
  scenario 'Signing in successfully' do
    mock_sso_with(email: 'email@example.com')
    mock_tasks_endpoint!
    mock_task_with_framework_endpoint!

    visit '/tasks'

    click_on 'Sign in'

    expect(page).to have_flash_message 'You are now signed in'
  end

  scenario 'Signing out' do
    mock_sso_with(email: 'email@example.com')
    mock_tasks_endpoint!
    mock_task_with_framework_endpoint!

    visit '/tasks'
    click_on 'Sign in'
    click_on 'Sign out'

    expect(page).to have_flash_message 'You are now signed out'
  end
end
