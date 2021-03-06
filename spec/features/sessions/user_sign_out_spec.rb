# frozen_string_literal: true

require 'rails_helper'

describe 'Sign Out', type: :feature do
  before do
    sign_in FactoryBot.create :user
    visit root_path
  end

  it 'has a logout button' do
    expect(page).to have_link 'Logout', href: destroy_user_session_path
  end

  it 'logs out the user' do
    click_link 'Logout'
    expect(page).not_to have_link 'Logout', href: destroy_user_session_path
    expect(page).to have_css('.alert-success')
  end
end
