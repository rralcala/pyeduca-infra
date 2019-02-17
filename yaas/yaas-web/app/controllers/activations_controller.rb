# Copyright Paraguay Educa 2010, Martin Abente
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#

class ActivationsController < ApplicationController

  before_filter :admin, :only => [:destroy]

  def index
    @admin = current_user.admin
    @activations = accessible_activations.order("created_at DESC")
  end

  def new
    @activation = Activation.new
    @user = current_user
  end

  def create
    @user = current_user
    @activation = Activation.custom_new(@user, parse_form)

    if !(@activation.errors.size > 0) and @activation.save
      flash[:notice] = _("Activation has been created.")
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def download
    activation = accessible_activations.find_by_id(params[:id])

    if activation
      send_data(activation.data, :filename => activation.filename, :type => 'text/plain')
    else
      flash[:error] = _("There is not such activation.")
      redirect_to :action => "index"
    end
  end

  def download_cjson
    activation = accessible_activations.find_by_id(params[:id])

    if activation
      send_data(activation.cjson_data, :filename => activation.filename, :type => 'text/plain')
    else
      flash[:error] = _("There is not such activation.")
      redirect_to :action => "index"
    end
  end

  def destroy
    activation = accessible_activations.find_by_id(params[:id])
    
    if activation
      activation.destroy
      flash[:notice] = _('Activation was successfully deleted.')
    else
      flash[:error] = _('There is no such activation.')
    end

    redirect_to :action => 'index'
  end

  private

  #Do not touch
  def accessible_activations
    if current_user.admin
      Activation
    else
      current_user.activations
    end
  end

  def parse_form
    activation = {}

    activation[:file] = params[:file] ? params[:file] : nil
    activation[:method] = params[:method] ? params[:method] : nil
    activation[:duration] = params[:duration] ? params[:duration].to_i : nil
    activation[:comments] = params[:comments] ? params[:comments] : nil

    activation
  end

end
