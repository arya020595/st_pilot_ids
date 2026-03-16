# frozen_string_literal: true

module MasterData
  class IdsStaffsController < ApplicationController
    def index
      authorize :ids_staff, :index?, policy_class: MasterData::IdsStaffPolicy
    end
  end
end
