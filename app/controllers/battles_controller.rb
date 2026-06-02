class BattlesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def index
  end

  def create
    @pokemon1_name = params[:pokemon1]
    @pokemon2_name = params[:pokemon2]

    if @pokemon1_name.blank? || @pokemon2_name.blank?
      return respond_with_error(
        "Por favor, preencha o nome dos dois Pokémon.",
        :unprocessable_entity
      )
    end

    p1 = PokemonApiClient.fetch(@pokemon1_name)
    p2 = PokemonApiClient.fetch(@pokemon2_name)

    @battle = PokemonBattle.new(p1, p2).execute!

    respond_to do |format|
      format.html { render :index }
      format.json do
        render json: {
          pokemon1: {
            name: p1.name,
            hp: p1.hp,
            sprite: p1.sprite
          },
          pokemon2: {
            name: p2.name,
            hp: p2.hp,
            sprite: p2.sprite
          },
          winner: @battle.winner ? {
            name: @battle.winner.name,
            hp: @battle.winner.hp,
            sprite: @battle.winner.sprite
          } : nil,
          draw: @battle.draw?,
          result_message: @battle.result_message
        }, status: :ok
      end
    end
  rescue PokemonApiClient::PokemonNotFoundError => e
    respond_with_error(e.message, :not_found)
  rescue PokemonApiClient::ApiError
    respond_with_error(
      "Não foi possível realizar a batalha devido a uma falha de conexão externa.",
      :bad_gateway
    )
  end

  private

  def respond_with_error(message, status)
    respond_to do |format|
      format.html do
        flash.now[:alert] = message
        render :index, status: status
      end

      format.json do
        render json: { error: message }, status: status
      end
    end
  end
end