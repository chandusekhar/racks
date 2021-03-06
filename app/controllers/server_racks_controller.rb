class ServerRacksController < ApplicationController
  cache_sweeper :server_rack_sweeper, :only => [:create, :update, :destroy]
  respond_to :iphone, :html

  before_filter :authorize
  def index
    if Datacenter.all.empty?
      redirect_to new_datacenter_path
    end
    @current_datacenter = current_datacenter
    @server_racks = current_datacenter.server_racks.paginate :page => params[:page], :per_page => 5
  end
  def show
    @server_rack = ServerRack.find(params[:id])
    respond_with @server_rack.datacenter, @server_rack do |format|
      format.html
      format.pdf do
        pdf_report = ServerRackReport.new(:page_size => "A4").to_pdf(@server_rack)
        send_data pdf_report, :filename => "#{@server_rack.name}.pdf", :type => "application/pdf"
      end
    end
  end

  def new
    @server_rack = current_datacenter.server_racks.build
  end

  def edit
    @server_rack = ServerRack.find(params[:id])
  end

  def create
    @server_rack = current_datacenter.server_racks.build(params[:server_rack])
    1.upto(params[:number_of_units].to_i) {|i|  @server_rack.units << Unit.new(:number => i)}
    @server_rack.save
    respond_with @server_rack.datacenter, @server_rack do |format|
      format.html
      format.iphone do
        if @server_rack.errors.any?
          redirect_to [:new, @server_rack.datacenter, :server_racks]
        else
          redirect_to [@server_rack.datacenter, @server_rack]
        end
      end
    end
  end

  def update
    @server_rack = ServerRack.find(params[:id])
    @server_rack.update_attributes(params[:server_rack])
    respond_with @server_rack.datacenter, @server_rack do |format|
      format.html
      format.iphone do
        if @server_rack.errors.any?
          redirect_to [@server_rack.datacenter, @server_rack, :edit]
        else
          redirect_to [@server_rack.datacenter, @server_rack]
        end
      end
    end
  end

  def destroy
    @server_rack = ServerRack.find(params[:id])
    @server_rack.destroy

    respond_with current_datacenter, :server_racks, :notice => "Server rack was successfully destroyed." do |format|
      format.html
      format.iphone {redirect_to [current_datacenter, :server_racks]}
    end
  end
end
