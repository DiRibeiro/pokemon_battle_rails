class BattlesController < ApplicationController
  def index
  end

  def create
    # Captura os parâmetros enviados pelo formulário
    @pokemon1_name = params[:pokemon1]
    @pokemon2_name = params[:pokemon2]

    # Validação rápida: impede que prossiga se faltar algum nome
    if @pokemon1_name.blank? || @pokemon2_name.blank?
      flash.now[:alert] = "Por favor, preencha o nome dos dois Pokémon."
      return render :index, status: :unprocessable_entity
    end

    begin
      # 1. Busca os dados dos dois lutadores usando o cliente da API
      p1 = PokemonApiClient.fetch(@pokemon1_name)
      p2 = PokemonApiClient.fetch(@pokemon2_name)

      # 2. Instancia a batalha, executa e guarda o resultado na variável @battle
      @battle = PokemonBattle.new(p1, p2).execute!

      # 3. Renderiza a mesma página (index), mas agora com os dados de @battle disponíveis
      render :index

    rescue PokemonApiClient::PokemonNotFoundError => e
      # Se o Pokémon não existir na PokéAPI, captura a mensagem de erro customizada
      flash.now[:alert] = e.message
      render :index, status: :not_found

    rescue PokemonApiClient::ApiError => e
      # Se a PokéAPI estiver fora do ar ou retornar outro erro (ex: 500)
      flash.now[:alert] = "Não foi possível realizar a batalha devido a uma falha de conexão externa."
      render :index, status: :bad_gateway
    end
  end
end
