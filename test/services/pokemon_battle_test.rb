require "test_helper"
# Força o carregamento se o zeitwerk/autoload ainda não mapeou a pasta customizada
require_relative "../../app/services/pokemon_api_client"
require_relative "../../app/services/pokemon_battle"

class PokemonBattleTest < ActiveSupport::TestCase
  setup do
    @bulbasaur = PokemonApiClient::PokemonData.new("Bulbasaur", 45)
    @charmander = PokemonApiClient::PokemonData.new("Charmander", 39)
    @equal_bulbasaur = PokemonApiClient::PokemonData.new("Bulbasaur Clone", 45)
  end

  test "deve dar vitória para o Pokémon com maior HP" do
    battle = PokemonBattle.new(@bulbasaur, @charmander).execute!
    assert_equal @bulbasaur, battle.winner
    assert_includes battle.result_message, "Bulbasaur venceu"
  end

  test "deve dar vitória mesmo se o segundo Pokémon for o mais forte" do
    battle = PokemonBattle.new(@charmander, @bulbasaur).execute!
    assert_equal @bulbasaur, battle.winner
  end

  test "deve resultar em empate quando os HPs forem iguais" do
    battle = PokemonBattle.new(@bulbasaur, @equal_bulbasaur).execute!
    assert_nil battle.winner
    assert_predicate battle, :draw?
  end
end