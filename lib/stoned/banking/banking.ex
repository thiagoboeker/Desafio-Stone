defmodule Stoned.Banking do
  @moduledoc """
  Serviço de Banking do projeto Stoned.

  Em `Stoned.Banking.Account` estao implementados todos os serviços da conta Stoned.

  Em `Stoned.Banking.Aggregate` encontrasse as regras de negocio e comportamento do servico.

  Em `Stoned.Banking.AccountAPI` esta definido a interface de acesso aos servicos da conta.

  ## Linguagem

  Entende-se como 'withdraw' ou 'saque' operaçoes de dedução de valores, muta-se o estado
  e qualquer outra operação que envolva esse tipo de mutação no final deve se reduzir a ela.

  Entende-se como 'deposit' ou 'deposito' operaçoes de acrescimo do saldo do cliente. No final
  qualquer operacao com essa finalidade deve ser encarada como um deposito.

  Credito ou `:credit` é o campo que regula o saldo do cliente.

  O padrão adotado é aquele mais visto em projetos que utilizam Event Sourcing.

  >     f(State, Command) => Event
  >     g(State, Event) => State
  """
end
