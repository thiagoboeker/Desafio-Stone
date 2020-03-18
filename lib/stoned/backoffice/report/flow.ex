defmodule Stoned.Backoffice.Report.DataFlow do
  @moduledoc """
    Modulo responsavel por processar eventos para gerar relatorio

    Esse modulo constroi um `Flow` para processar os eventos e gerar um relatorio
    backoffice. Primariamente ele utiliza `Stoned.Backoffice.Report.DataProducer`
    como Source
  """

  alias Stoned.Backoffice.Report.DataProducer

  @doc """
    Gera as chaves para criar o objeto reposta como relatorio

    dia = d_17_03_2020

    mes = m_03_2020

    ano = y_2020
  """
  def generate_keys(date) do
    day = "d_#{date.day}_#{date.month}_#{date.year}"
    month = "m_#{date.month}_#{date.year}"
    year = "y_#{date.year}"
    {day, month, year}
  end

  @doc """
  Funcao que processa os eventos

  Ao receber `:empty` significa que ja esta no final e apenas retorna o acumulador

  Atualiza a chave do acumulador com o valor do evento ou se a chave ja existir faz a soma.
  """
  def process_data(:empty, acc), do: acc
  def process_data(event, acc) do
    {day, month, year} = generate_keys(event.date)
    acc
    |> Map.update(day, Map.get(acc, day, event.value), &(&1 + event.value))
    |> Map.update(month, Map.get(acc, month, event.value), &(&1 + event.value))
    |> Map.update(year, Map.get(acc, year, event.value), &(&1 + event.value))
  end

  @doc """
  Cria o flow de processamento de eventos para gerar o Relatorio

  Utiliza `Flow.from_specs/1` para utilizar um produtor GenStage como Source e inicia-lo
  como processo filho.
  """
  def start_flow(start_date) do
    producer = [{DataProducer, %{from: start_date}}]
    producer
    |> Flow.from_specs()
    |> Flow.reduce(fn -> %{} end, &process_data/2)
  end
end
