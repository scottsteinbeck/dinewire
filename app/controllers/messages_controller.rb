class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  
  # GET /messages
  # GET /messages.json
  def index
    @sent_messages = current_user.messages
    @recieved_messages = Message.where(recipient_id: current_user.id)
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = current_user.messages.build
    @meal = Meal.find (params[:meal_id])
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = current_user.messages.build(message_params)
      if @message.save
        @message.send_message_notification
       redirect_to @message, notice: 'Message Sent!'       
    end
  end

  def create_reply
    @message = Message.find(params[:message_id])
    @reply = @message.children.build(message_params)
    @reply.recipient_id = @message.user_id
    @reply.user = current_user
    if @reply.save
      redirect_to @message, notice: "Reply Sent!"
    end

  end

  def reply 
    @message = Message.find(params[:message_id])
    @reply = @message.children.build
  end


  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.where("id= ? AND (user_id = ? OR recipient_id = ?)",params[:id], current_user.id, current_user.id).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:subject, :body, :user_id, :recipient_id)
    end
end
