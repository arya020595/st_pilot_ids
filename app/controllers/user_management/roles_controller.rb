# frozen_string_literal: true

module UserManagement
  class RolesController < ApplicationController
    before_action :set_role, only: %i[show edit update destroy confirm_delete]

    def index
      authorize Role, policy_class: UserManagement::RolePolicy

      @q = policy_scope(Role, policy_scope_class: UserManagement::RolePolicy::Scope)
            .order(id: :desc)
            .ransack(params[:q])
      @pagy, @roles = pagy(@q.result)
    end

    def show
      authorize @role, policy_class: UserManagement::RolePolicy
    end

    def new
      @role = Role.new
      authorize @role, policy_class: UserManagement::RolePolicy
    end

    def create
      @role = Role.new(role_params)
      authorize @role, policy_class: UserManagement::RolePolicy

      if @role.save
        respond_to do |format|
          format.turbo_stream { flash.now[:notice] = 'Role was successfully created.' }
          format.html { redirect_to user_management_roles_path, notice: 'Role was successfully created.' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace('modal', partial: 'form', locals: { role: @role })
          end
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      authorize @role, policy_class: UserManagement::RolePolicy
    end

    def update
      authorize @role, policy_class: UserManagement::RolePolicy

      if @role.update(role_params)
        respond_to do |format|
          format.turbo_stream { flash.now[:notice] = 'Role was successfully updated.' }
          format.html { redirect_to user_management_roles_path, notice: 'Role was successfully updated.' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace('modal', partial: 'form', locals: { role: @role })
          end
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def confirm_delete
      authorize @role, policy_class: UserManagement::RolePolicy

      if turbo_frame_request?
        render layout: false
      else
        redirect_to user_management_roles_path
      end
    end

    def destroy
      authorize @role, policy_class: UserManagement::RolePolicy

      @role.destroy
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = 'Role was successfully deleted.' }
        format.html { redirect_to user_management_roles_path, notice: 'Role was successfully deleted.' }
      end
    end

    private

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(
        :name,
        permission_ids: []
      )
    end
  end
end
