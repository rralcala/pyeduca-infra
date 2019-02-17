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

class ApplicationController < ActionController::Base
  include FastGettext::Translation

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :authenticate
  before_filter :set_gettext_locale

  def authenticate

    if !session[:user_id]
      redirect_to :controller => "sessions", :action => "new"
      session[:return] = request.fullpath if !session[:return]
      return false
    end

    true
  end

  def admin
    if !current_user.admin
      redirect_to :controller => "users", :action => "options"
      return false
    end

    true
  end

  def current_user
    User.find_by_id(session[:user_id])
  end

  def redirect_to_return
    return_path = session[:return] 

    if return_path
      session[:return] = nil
      redirect_to return_path
    else
      redirect_to :controller => 'users', :action => 'options'
    end
  end

end
