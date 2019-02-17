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

require 'yaas_wrapper'

class UsersController < ApplicationController

  before_filter :admin
  skip_filter :admin, :only => [:options, :change_password, :save_changed_password]

  def index
    @users = User.where(:admin => false)
  end

  def new
    @user = User.new
    @user.bucket = YaasWrapper::default_bucket
    @user.activation_limit = YaasWrapper::default_activation_limit
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(parse_form())

    if @user.save
      flash[:notice] = _('User was successfully created.')
      redirect_to :action => 'index'
    else
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(parse_form())
      flash[:notice] = _('User was successfully updated.')
      redirect_to :action => :index
    else
      render :action => "edit"
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy

    flash[:notice] = _('User was successfully deleted.')
    redirect_to :action => 'index' 
  end

  def options
    @user = current_user
  end

  def change_password
    @user = current_user
  end

  def save_changed_password
    @user =  current_user
    old_password = params[:old_password]
    new_password = params[:new_password]
    verification = params[:new_password_validation]

    if @user.change_password(old_password, new_password, verification)
      flash[:notice] = _('Password changed')
      redirect_to :action => 'options'
    else
      render :action => "change_password"
    end
  end

  private

  def parse_form
    user = {}
    user[:name] = params[:name] if params[:name]
    user[:password] = params[:password] if !params[:password].blank?
    user[:admin] = false
    user[:email] = params[:email] if params[:email]
    user[:bucket] = params[:bucket] ? params[:bucket].to_i : YaasWrapper::default_bucket
    user[:activation_limit] = params[:activation_limit] ? params[:activation_limit].to_i : YaasWrapper::default_activation_limit
    user[:can_create_dev_keys] = params[:can_create_dev_keys] == "true" ? true : false
    user
  end

end
