class BlacklistController < ApplicationController

  before_filter :admin

  def index
    @admin = current_user.admin
    @blacklists = Blacklist.all
  end

  def new
    @blacklist = Blacklist.new
  end

  def edit
    @blacklist = Blacklist.find(params[:id])
  end

  def create
    @blacklist = Blacklist.new(parse_form())

    if @blacklist.save
      flash[:notice] = _('Blacklisted laptop was successfully created.')
      redirect_to :action => 'index'
    else
      render :action => "new"
    end
  end

  def update
    @blacklist = Blacklist.find(params[:id])

    if @blacklist.update_attributes(parse_form())
      flash[:notice] = _('Blacklisted laptop was successfully updated.')
      redirect_to :action => :index
    else
      render :action => "edit"
    end
  end

  def destroy
    blacklist = Blacklist.find(params[:id])
    blacklist.destroy

    flash[:notice] = _('Blacklisted laptop was successfully deleted.')
    redirect_to :action => 'index'
  end

  private

  def parse_form
    blacklist = {}
    
    blacklist[:serial_number] = params[:serial_number] if params[:serial_number]
    blacklist[:reason] = params[:reason] if params[:reason]
    
    blacklist 
  end
  
end
