# Redmine - project management software
# Copyright (C) 2006-2016  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class CustomFieldEnumerationsController < ApplicationController
  layout 'admin'

  before_action :require_admin
  before_action :find_custom_field
  before_action :find_enumeration, :only => :destroy

  helper :custom_fields

  def index
    @values = @custom_field.enumerations.order(:position)
  end

  def create
    @value = @custom_field.enumerations.build
    @value.safe_attributes = params[:custom_field_enumeration]
    @value.save
    respond_to do |format|
      format.html { redirect_to custom_field_enumerations_path(@custom_field) }
      format.js
    end
  end

  def update_each
    saved = CustomFieldEnumeration.update_each(@custom_field, params[:custom_field_enumerations]) do |enumeration, enumeration_attributes|
      enumeration.safe_attributes = enumeration_attributes
    end
    if saved
      flash[:notice] = l(:notice_successful_update)
    end
    redirect_to :action => 'index'
  end

  def destroy
    reassign_to = @custom_field.enumerations.find_by_id(params[:reassign_to_id])
    if reassign_to.nil? && @value.in_use?
      @enumerations = @custom_field.enumerations - [@value]
      render :action => 'destroy'
      return
    end
    @value.destroy(reassign_to)
    redirect_to custom_field_enumerations_path(@custom_field)
  end

  private

  def find_custom_field
    @custom_field = CustomField.find(params[:custom_field_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_enumeration
    @value = @custom_field.enumerations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
