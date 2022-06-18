class AgentsController < ApplicationController
  before_filter :authorize
  before_action :is_admin, only: [:report]
  before_action :set_agent, only: [:show, :edit, :update, :destroy, :enable]

  # GET /agents
  # GET /agents.json
  def index
    @agents = Agent.with_custom_fields
    @report = AgentReport.new
  end

  # GET /agents/1
  # GET /agents/1.json
  def show
  end

  # GET /agents/new
  def new
    @agent = Agent.new
  end

  # GET /agents/1/edit
  def edit
  end

  # POST /agents
  # POST /agents.json
  def create
    @agent = Agent.new(agent_params)

    respond_to do |format|
      if @agent.save
        format.html { redirect_to @agent, notice: 'Agent was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agent }
      else
        format.html { render action: 'new' }
        format.json { render json: @agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agents/1
  # PATCH/PUT /agents/1.json
  def update
    respond_to do |format|
      if @agent.update(agent_params)
        format.html { redirect_to @agent, notice: 'Agent was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agents/1
  # DELETE /agents/1.json
  def destroy
    @agent.set_deleted
    respond_to do |format|
      format.html { redirect_to agents_url, notice: "Agent was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def enable
    @agent.set_enabled
    respond_to do |format|
      format.html { redirect_to agents_url, notice: "Agent was successfully enabled." }
      format.json { head :no_content }
    end
  end

  def report
    @report = AgentReport.new(report_params)
    generate_report(@report)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_agent
    @agent = Agent.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def agent_params
    params.require(:agent).permit(:name, :address, :reference, :credit_term, :notes,
                                  custom_fields_attributes: [:id, :field_key, :field_name, :field_value, :_destroy])
  end

  def report_params
    params.require(:agent_report).permit(:format)
  end
end
