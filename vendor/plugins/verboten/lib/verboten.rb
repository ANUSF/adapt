module Verboten
  module ClassMethods
    def permit(*args, &code)
      options = args.last.is_a?(Hash) ? args.pop : {}
      if block_given?
        options[:if] = code
      else
        case options[:if]
        when :logged_in  then options[:message] ||= "Must be logged in."
        when :logged_out then options[:message] ||= "Must be logged out."
        end
      end
      args.each { |name| self.permission_settings[name.to_sym] = options }
    end

    def before_authorization_filter(*args)
      before_filter *args
      skip_before_filter :authorize
      before_filter :authorize
    end
  end

  module InstanceMethods
    def logged_in
      not logged_out
    end

    def logged_out
      current_user.nil?
    end

    def authorize
      begin
        if self.respond_to? :permitted
          allowed = self.send :permitted, action_name, params
          options = {}
        else
          options = self.class.permission_settings[action_name.to_sym] || {}
          allowed = case options[:if]
                    when nil    then true
                    when Proc   then options[:if].call(self)
                    when Symbol then self.send(options[:if])
                    else             options[:if]
                    end
        end
        unless allowed
          flash.now[:error] = options[:message] || "Access denied."
          render :template => 'layouts/empty'
        end
      rescue
        flash.now[:error] = "Error in authorization check."
        render :template => 'layouts/empty'
      end
    end
  end
end

class ActionController::Base
  def self.forbid_everything
    class_inheritable_accessor :permission_settings
    self.permission_settings = {}

    extend Verboten::ClassMethods
    include Verboten::InstanceMethods
  end
end
