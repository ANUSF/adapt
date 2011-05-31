# Copyright (c) 2010 ANU

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Verboten
  def self.included(base)
    base.class_eval do
      class_inheritable_accessor :permission_settings
      self.permission_settings = {}

      extend Verboten::ClassMethods
      include Verboten::InstanceMethods

      before_filter :authorize
    end
  end

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
          options = self.class.permission_settings[action_name.to_sym] ||
            { :if => false }
          allowed = case options[:if]
                    when nil    then true
                    when Proc   then self.instance_eval(&options[:if])
                    when Symbol then self.send(options[:if])
                    else             options[:if]
                    end
        end
      rescue => ex
        flash_error "Error in authorization test: #{ex}"
      else
        if allowed.is_a? String
          message = allowed
          allowed = false
        else
          message = options[:message] || "Access denied."
        end
        unless allowed
          Rails.logger.error "Denied access to #{current_user || 'guest'}: " +
            "'#{message}'"
          flash_error(message)
        end
      end
    end

    protected
    def flash_error(message)
      flash.now[:error] = message
      render :text => '', :layout => true
    end
  end
end
