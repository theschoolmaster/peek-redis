module Peek
  class RedisExpiresController < ApplicationController
    before_action :restrict_non_access

    def expire
      success = true
      cache_keys = params[:cache_keys]

      begin
        # support for both arrays of cache keys and single string keys
        # we detect globs because SCAN when we have the full key is slow and wasteful
        # we're only using * in our app so that's all we're testing here, easy to add
        # addtional patterns if you use them
        if cache_keys.respond_to? :each
          cache_keys.flatten.each do |key|
            # test if the key contains a glob style pattern
            if key.include? '*'
              Rails.cache.delete_matched key
            else
              Rails.cache.delete key
            end
          end
        else
          if cache_keys.include? '*'
            Rails.cache.delete_matched cache_keys
          else
            Rails.cache.delete cache_keys
          end
        end
      rescue
        success = false
        flash[:error] = "Problem deleteing cache keys #{cache_keys.inspect}"
      end

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
