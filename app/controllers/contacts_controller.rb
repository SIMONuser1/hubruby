require "json"
require "open-uri"

class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)
    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
        posthubspot
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def posthubspot
    hs_context = { hutk: cookies[:hubspotutk],
                              ipAddress: request.remote_ip,
                              pageUrl: request.url,
                              pageName: "rubyform"
                  }.to_json

    payload = URI.escape("email=#{@contact[:email]}&firstname=#{@contact[:first_name]}&lastname=#{@contact[:last_name]}&hs_context=#{hs_context}")
    endpoint = "https://forms.hubspot.com/uploads/form/v2/4873121/7fd44f2f-7e78-4c10-9f24-591fc6775d11"

    begin
      uri = URI.parse(endpoint)
      header = header = {'Content-Type': 'application/x-www-form-urlencoded'}
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = payload.to_json
      response = http.request(request)
      response_output = "response #{response.body}"
    rescue => e
      response_output = "failed: #{e}"
    end

  end
  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:firstname, :lastname, :email)
    end
end
