Rails.application.routes.draw do
  # Define a página inicial como o formulário de batalha
  root "battles#index"

  # Rota para onde o formulário será enviado
  post "battle", to: "battles#create"
end