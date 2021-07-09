defmodule VernemqMadsPlugin do
  alias VernemqMadsPlugin.Account

  def auth_on_register(_, {_, clientid}, _, password, _) do
    Account.is_authenticated(clientid, password)
  end

  def on_register(_, {_, clientid}, username) do
    IO.puts("*** on_register #{clientid} / #{username}")
    :ok
  end

  def on_client_wakeup({_, clientid}) do
    IO.puts("*** on_client_wakeup #{clientid}")
    :ok
  end

  def on_client_offline({_, clientid}) do
    IO.puts("*** on_client_offline #{clientid}")
    :ok
  end

  def on_client_gone({_, clientid}) do
    IO.puts("*** on_client_gone #{clientid}")
    :ok
  end

  # Subscribe flow
  def auth_on_subscribe(_, {_, clientid}, topics) do
    IO.puts("*** auth_on_subscribe #{clientid}")
    {:ok, topics}
  end

  def on_subscribe(_, {_, clientid}, _) do
    IO.puts("*** on_subscribe #{clientid}")
    :ok
  end

  def on_unsubscribe(_, {_, clientid}, _) do
    IO.puts("*** on_unsubscribe #{clientid}")
    :ok
  end

  # Publish flow
  def auth_on_publish(_, {_, clientid}, _, topic, payload, _) do
    IO.puts("*** auth_on_publish #{clientid} / #{topic} / #{payload}")
    {:ok, payload}
  end

  def on_publish(_, {_, clientid}, _, topic, payload, _) do
    IO.puts("*** on_publish #{clientid} / #{topic} / #{payload}")
    :ok
  end

  def on_deliver(_, {_, clientid}, topic, payload) do
    IO.puts("*** on_deliver #{clientid} / #{topic} / #{payload}")
    :ok
  end

  def on_offline_message({_, clientid}, _, topic, payload, _) do
    IO.puts("*** on_offline_message #{clientid} / #{topic} / #{payload}")
    :ok
  end
end
