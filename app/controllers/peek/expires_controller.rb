module Peek
  class ExpiresController < ApplicationController
    before_filter :restrict_non_access

    def redis_expire
      @cache_key = CGI.unescape(params[:cache_key])

      # TODO: investigate using expire vs delete here...
      success = Rails.cache.delete @cache_key

      respond_to do |format|
        if success
          format.js { render 'success' }
        else
          format.js { render 'failure' }
        end
      end
    end

    private

    def restrict_non_access
      unless peek_enabled?
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
