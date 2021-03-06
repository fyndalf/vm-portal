# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArchivationRequest, type: :model do
  let(:archivation_request) do
    ArchivationRequest.create name: 'VM'
  end

  it 'cannot be executed before 3 days' do
    expect(archivation_request.can_be_executed?).to eq false
  end

  it 'can be executed after 3 days' do
    three_days = 60 * 60 * 24 * 3
    archivation_request.created_at -= three_days
    expect(archivation_request.can_be_executed?).to eq true
  end
end
