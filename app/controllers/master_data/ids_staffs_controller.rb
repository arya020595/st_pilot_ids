# frozen_string_literal: true

module MasterData
  # Controller for IDS Staff listing under Master Data.
  class IdsStaffsController < ApplicationController
    def index
      authorize :ids_staff, :index?, policy_class: MasterData::IdsStaffPolicy
    end
  end
end
