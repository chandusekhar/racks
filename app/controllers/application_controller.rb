class ApplicationController < ActionController::Base
	protect_from_forgery
	
	before_filter :get_all_datacenters, :current_datacenter
	
	
	
	protected
	def current_datacenter
		if params[:datacenter_id]
			@current_datacenter ||= Datacenter.find(params[:datacenter_id])
		elsif Datacenter.all.any?
			@current_datacenter = Datacenter.all.first
		else
			@current_datacenter = Datacenter.new
		end
		 @current_datacenter
	end
	def current_server_rack
		@current_server_rack ||= current_datacenter.server_racks.find(params[:server_rack_id])
	end
	def get_all_datacenters
		@datacenters = Datacenter.all
	end

end
