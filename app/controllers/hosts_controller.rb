# frozen_string_literal: true

require 'vmapi.rb'
class HostsController < ApplicationController
  attr_reader :hosts

  def index
    @hosts = VSphere::Host.all
  end

  def new; end

  def show
    @host = VmApi.instance.get_host(params[:id])
    render(template: 'errors/not_found', status: :not_found) if @host.nil?
  end
end
