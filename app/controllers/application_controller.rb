class ApplicationController < ActionController::Base
  protect_from_forgery
  
 private
  def token
    cookies[:token] ? cookies[:token] : rand(2468**10).to_s(32)
  end
  
  def current_order
    cookies[:token] = { value: token, expires: 1.hour.from_now }
    @current_order ||= Order.cart_by(token) || Order.create!(token: token)

    unless session[:first_time]
      @current_order.touch
      session[:first_time] = true
    end

    @current_order
  end
  helper_method :current_order

  def render_form_error_for object
    error = 
      {
        id: object.id,
        model: controller_name.singularize, 
        errors: object.errors 
      }
    render json: error , status: :unprocessable_entity
  end

  def render_box_error_for object, text = nil
    error = { noty: text ? text : object.errors }
    render json: error, status: :unprocessable_entity
  end
end
