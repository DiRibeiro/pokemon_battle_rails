require "test_helper"

class PokemonApiClientTest < ActiveSupport::TestCase
  # Uma estrutura simples para fingir que é uma resposta HTTP
  FakeResponse = Struct.new(:code, :body)

  def fake_json(name, hp)
    {
      name: name,
      stats: [{ base_stat: hp, stat: { name: "hp" } }]
    }.to_json
  end

  # Helper para interceptar a chamada de rede sem depender do Minitest.stub
  def stub_http_response(fake_response_or_proc)
    # Guarda o método original do Ruby
    original_method = Net::HTTP.method(:get_response)
    
    # Redefine o método na classe Net::HTTP
    Net::HTTP.define_singleton_method(:get_response) do |uri|
      if fake_response_or_proc.respond_to?(:call)
        fake_response_or_proc.call(uri)
      else
        fake_response_or_proc
      end
    end

    yield # Executa o teste de fato
  ensure
    # Garante que o método original seja restaurado, mesmo se o teste falhar
    Net::HTTP.define_singleton_method(:get_response, original_method)
  end

  test "deve buscar um pokemon com sucesso e extrair o HP corretamente" do
    response_sucesso = FakeResponse.new("200", fake_json("pikachu", 35))

    stub_http_response(response_sucesso) do
      result = PokemonApiClient.fetch("pikachu")
      
      assert_equal "Pikachu", result.name
      assert_equal 35, result.hp
    end
  end

  test "deve limpar e normalizar o nome antes de enviar para a API" do
    response_sucesso = FakeResponse.new("200", fake_json("charizard", 78))

    verificar_url = ->(uri) {
      assert_equal "https://pokeapi.co/api/v2/pokemon/charizard", uri.to_s
      response_sucesso
    }

    stub_http_response(verificar_url) do
      PokemonApiClient.fetch("  Chârizárd ")
    end
  end

  test "deve levantar erro quando o pokemon nao existe" do
    response_404 = FakeResponse.new("404", "")

    stub_http_response(response_404) do
      assert_raises(PokemonApiClient::PokemonNotFoundError) do
        PokemonApiClient.fetch("pokemon-errado")
      end
    end
  end

  test "deve retornar nil imediatamente se o nome enviado for vazio" do
    assert_nil PokemonApiClient.fetch("")
    assert_nil PokemonApiClient.fetch("   ")
  end
end