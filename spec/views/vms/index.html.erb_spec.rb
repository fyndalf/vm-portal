# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'

RSpec.describe 'vms/index.html.erb', type: :view do
  let(:mock_vms) do
    [v_sphere_vm_mock('my-insanely-cool-vm',
                      power_state: 'poweredOn',
                      vm_ware_tools: 'toolsOld'),
     v_sphere_vm_mock('another-vm',
                      power_state: 'poweredOff',
                      boot_time: 'Friday',
                      vm_ware_tools: 'toolsOk')]
  end

  let(:mock_vms_without_tools) do
    [v_sphere_vm_mock('yet-another-vm'),
     v_sphere_vm_mock('and-the-best-vm-there-is',
                      power_state: 'poweredOff',
                      boot_time: 'Friday')]
  end

  let(:current_user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }

  before do
    sign_in current_user
    assign(:vms, mock_vms)
    assign(:archived_vms, [])
    assign(:skip_archivation_vms, [])
    render
  end

  it 'renders the vm names' do
    mock_vms.each do |vm|
      expect(rendered).to include vm.name
    end
  end

  it 'renders the boot times' do
    expect(rendered).to include mock_vms.first.boot_time.to_s
    expect(rendered).not_to include mock_vms.second.boot_time
  end

  it 'links to vm detail pages' do
    mock_vms.each do |vm|
      expect(rendered).to have_link(vm.name)
    end
  end

  context 'when the user is a root user for the vms' do
    before do
      associate_users_with_vms(admins: [current_user], vms: mock_vms)
      render
    end

    it 'shows correct power on / off button' do
      expect(rendered).to have_css('a.btn-manage.play')
    end

    it 'demands confirmation on shutdown' do
      expect(rendered).to have_css('a.btn-manage[data-confirm="Are you sure?"]')
    end

    context 'when vmwaretools are not installed' do
      before do
        assign(:vms, mock_vms_without_tools)
      end

      it 'shows no power buttons' do
        rendered = render
        expect(rendered).not_to have_css('a.btn-manage.play')
        expect(rendered).not_to have_css('a.btn-manage.stop')
      end
    end
  end

  context 'when the user is not a root user for the vms' do
    it 'does not show any manage buttons' do
      expect(rendered).not_to have_css('a.btn-manage.play')
      expect(rendered).not_to have_css('a.btn-manage.stop')
    end
  end

  context 'when the user is a user' do
    let(:current_user) { FactoryBot.create :user }

    it 'does not link to new vm page' do
      expect(rendered).not_to have_button('New Request')
    end

    it 'does not link to requests overview page' do
      expect(rendered).not_to have_button('All Requests')
    end
  end

  context 'when the user is an employee' do
    let(:current_user) { FactoryBot.create :employee }

    it 'links to new vm page' do
      expect(rendered).to have_button('New Request')
    end

    it 'links to requests overview page' do
      expect(rendered).to have_button('All Requests')
    end
  end

  context 'when the user is an admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'shows correct power on / off button' do
      expect(rendered).to have_css('a.btn-manage.play')
    end

    it 'demands confirmation on shutdown' do
      expect(rendered).to have_css('a.btn-manage[data-confirm="Are you sure?"]')
    end

    context 'when vmwaretools are not installed' do
      before do
        assign(:vms, mock_vms_without_tools)
        render
      end

      it 'shows no power buttons' do
        rendered = render
        expect(rendered).not_to have_css('a.btn-manage.play')
        expect(rendered).not_to have_css('a.btn-manage.stop')
      end
    end

    it 'links to new vm page' do
      expect(rendered).to have_button('New Request')
    end

    it 'links to requests overview page' do
      expect(rendered).to have_button('All Requests')
    end
  end
end
