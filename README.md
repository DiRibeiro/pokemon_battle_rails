# Pokémon Battle Rails

Aplicação Rails estruturada para simular uma batalha entre dois Pokémon utilizando dados reais consumidos da [PokéAPI](https://pokeapi.co/). A regra de negócio principal dita que vence o Pokémon com maior `base_stat` de HP. Em casos de valores idênticos, o resultado é computado como empate.

## 🚀 Tecnologias e Premissas

* **Ruby 3.2.3**
* **Rails 8.1.3**
* **Minitest** (Suíte nativa, sem dependências de frameworks de mock externos)
* **Net::HTTP e JSON** (Componentes da biblioteca padrão do Ruby)

### Decisões de Arquitetura

A aplicação foi desenhada seguindo o princípio de **Responsabilidade Única (SRP)** e não utiliza banco de dados (`ActiveRecord` foi desabilitado na inicialização), eliminando overheads de IO e persistência desnecessários para o escopo do desafio.

* `PokemonApiClient`: Centraliza a higienização de inputs, comunicação HTTP externa e tratamento de falhas na rede. Transforma respostas brutas em objetos de valor simples (`Struct`).
* `PokemonBattle`: Um Objeto Ruby Puro (PORO) que encapsula estritamente as regras de negócio da luta, totalmente isolado de conceitos de infraestrutura HTTP ou Rails.
* `BattlesController`: Atua estritamente como um orquestrador (Skinny Controller), validando inputs básicos, gerenciando o fluxo de sucesso e capturando exceções para mapear os status HTTP corretos na resposta (`200`, `404`, `422`, `502`).

---

## 🛠️ Instalação e Execução

Instale as dependências do projeto:

```bash
bundle install

```

Inicie o servidor de desenvolvimento:

```bash
bin/rails server

```

Acesse a interface no seu navegador:

```text
http://localhost:3000

```

---

## 🧪 Testes Unitários e de Integração

A suíte de testes foi construída de forma isolada. Os testes que envolvem o cliente HTTP utilizam metaprogramação para interceptar chamadas de rede dinamicamente, garantindo estabilidade, execução em milissegundos e total independência da disponibilidade da PokéAPI externa.

Para rodar a suíte inteira em modo verboso:

```bash
bin/rails test -v

```

### O que está sendo coberto:

* **Camada de Serviços (`test/services/`):**
* Normalização estrita de strings (remoção de acentos, capitalização, conversão de espaços para hífens).
* Comportamento do parser perante payloads da PokéAPI.
* Lógica matemática de vitória por maior HP e cenários de empate.
* Lançamento de exceções customizadas perante erros de API (como 404).


* **Camada de Controladores (`test/controllers/`):**
* Garantia de renderização e integridade da rota principal.



---

## 💻 Validação Manual (Sem Interface)

Se desejar avaliar o comportamento interno das engrenagens do ecossistema do projeto de forma isolada, utilize os dois métodos abaixo:

### 1. Via Rails Console (`bin/rails c`)

Permite instanciar os objetos de negócio dentro do ambiente da aplicação e interagir diretamente com o Ruby no terminal:

```ruby
bin/rails console

# Buscar dados reais diretamente da API externa
p1 = PokemonApiClient.fetch("Charizard")
p2 = PokemonApiClient.fetch("  Pikachu ")

# Executar o motor de batalha
batalha = PokemonBattle.new(p1, p2).execute!

# Avaliar propriedades resultantes
puts batalha.result_message
batalha.winner.name
batalha.draw?

```

### 2. Via cURL (Simulação de requisições ao Controller)

Com o servidor rodando (`bin/rails s`), abra uma nova aba do terminal e envie requisições simulando o comportamento de um client HTTP para validar as respostas e os cabeçalhos de status do controlador:

**Cenário Sucesso (Retorna HTTP 200):**

```bash
curl -i -X POST http://localhost:3000/battle -d "pokemon1=mewtwo" -d "pokemon2=mew"

```

**Cenário de Erro - Pokémon Não Encontrado (Retorna HTTP 404):**

```bash
curl -i -X POST http://localhost:3000/battle -d "pokemon1=invalid-name" -d "pokemon2=pikachu"

```

**Cenário de Erro - Parâmetros Ausentes (Retorna HTTP 422):**

```bash
curl -i -X POST http://localhost:3000/battle -d "pokemon1=" -d "pokemon2=pikachu"

```

---

## 🛑 Endpoint Consumido

A aplicação integra-se nativamente com a seguinte rota externa:

```text
GET https://pokeapi.co/api/v2/pokemon/{nome_higienizado}

```

A propriedade `hp` é extraída dinamicamente varrendo a coleção contida na chave `stats` onde o valor correspondente de `stat.name` seja estritamente `"hp"`, capturando seu respectivo `base_stat`.