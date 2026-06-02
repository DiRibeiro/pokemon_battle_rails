require 'net/http'
require 'json'

class PokemonApiClient
  # Exceções customizadas para o Controller saber exatamente o que falhou
  class PokemonNotFoundError < StandardError; end
  class ApiError < StandardError; end

  BASE_URL = 'https://pokeapi.co/api/v2/pokemon/'
  PokemonData = Struct.new(:name, :hp, :sprite, keyword_init: true)

  def self.fetch(pokemon_name)
    return nil if pokemon_name.blank?

    name_clean = normalize_name(pokemon_name)
    uri = URI("#{BASE_URL}#{name_clean}")

    response = Net::HTTP.get_response(uri)

    case response.code
    when '200'
      parse_pokemon_data(response.body)
    when '404'
      raise PokemonNotFoundError, "Pokémon '#{pokemon_name}' não foi encontrado."
    else
      raise ApiError, "Falha na API externa. Código: #{response.code}"
    end
  end

  # Método privado criado para limpar a string
  private

  def self.normalize_name(name)
    name.to_s
        .unicode_normalize(:nfd) # Separa os acentos das letras (ex: 'á' vira 'a' + '´')
        .gsub(/\p{M}/, '')       # Remove todos os acentos que foram separados
        .strip                   # Remove espaços em branco nas pontas
        .downcase                # Transforma tudo em minúsculo
        .gsub(/\s+/, '-')        # Substitui espaços internos por hífens (ex: "tapu koko" -> "tapu-koko")
  end

  def self.parse_pokemon_data(body)
    data = JSON.parse(body)
    
    # Procura no array de stats o item onde stat -> name seja igual a 'hp'
    hp_stat = data['stats'].find { |s| s.dig('stat', 'name') == 'hp' }
    
    # Se achar o stat de hp, pega o base_stat. Se não achar por algum motivo, assume 0.
    hp = hp_stat ? hp_stat['base_stat'] : 0

    # Retorna o objeto limpo, capitalizando o nome para ficar bonito na tela (ex: "Pikachu")
    PokemonData.new(
      name: data["name"].capitalize,
      hp: hp_stat["base_stat"],
      sprite: data.dig("sprites", "front_default")
    )
  end
  
end