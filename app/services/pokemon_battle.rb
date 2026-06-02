class PokemonBattle
  # Criei leitores (getters) para que o Controller possa acessar esses dados depois
  attr_reader :pokemon1, :pokemon2, :winner, :loser, :result_message

  def initialize(pokemon1, pokemon2)
    @pokemon1 = pokemon1
    @pokemon2 = pokemon2
    @winner = nil
    @loser = nil
    @result_message = ""
  end

  def execute!
    if pokemon1.hp > pokemon2.hp
      @winner = pokemon1
      @loser = pokemon2
      @result_message = "#{pokemon1.name} venceu com #{pokemon1.hp} HP contra #{pokemon2.hp} HP de #{pokemon2.name}!"
    elsif pokemon2.hp > pokemon1.hp
      @winner = pokemon2
      @loser = pokemon1
      @result_message = "#{pokemon2.name} venceu com #{pokemon2.hp} HP contra #{pokemon1.hp} HP de #{pokemon1.name}!"
    else
      @result_message = "Empate! Ambos os Pokémon possuem #{pokemon1.hp} HP."
    end

    self
  end

  def draw?
    @winner.nil?    
  end
end
