class UsersController < ApplicationController
  ABC = 1
  DE = 2
  # POST /users/login
  def login
    user_name = params[:user_name]
    pass = params[:pass]
    user = (User.where :user_name => user_name).first
    if user and user.auth
      session[:auth_key] = user.id
      session[:admin] = true if user.admin
      redirect_to :action => 'index' unless user.admin
      redirect_to admin_index_path if user.admin
    else
      flash[:notice] = 'Usuario no autorizado'
      redirect_to :action => 'index' 
    end
  end

  # GET /users/logout
  def logout
    reset_session
    redirect_to :action => 'index'
  end

  def check_session
    if session[:auth_key]
      u = User.find session[:auth_key]
      resp = {reject: u.reject}
      render :json => resp
    else
      render :json => {msg: 'Not authorized'}
    end
  end

  def thankyou
    if session[:auth_key]
      reset_session
    else
      redirect_to root_url
    end
  end

  # GET /users
  # GET /users.json
  def index
    if session[:auth_key] and session[:admin]
      redirect_to admin_index_path
    elsif session[:auth_key]
      u = User.find session[:auth_key]
      redirect_to matching_word_function_path if u.function_auth
      redirect_to matching_word_structure_path if u.structure_auth
      redirect_to matching_word_behavior_path if u.behavior_auth
      redirect_to matching_word_phrases_path if u.phrase_auth
    else
      render :login
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "Usuario #{@user.user_name} creado." }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    if session[:admin]
      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to @user, notice: 'User was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    else 
      # Permissions error
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    if session[:admin]
      @user.destroy

      respond_to do |format|
        format.html { redirect_to users_url }
        format.json { head :no_content }
      end
    else
      # Permissions error
    end
  end
end
