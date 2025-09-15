defmodule StoryTeller.God do
  use GenServer

  alias StoryTeller.Cli.TextFx

  import StoryTeller.God.Brain
  import StoryTeller.God.Memory

  @clean_state %{players: []}

  ## Public API

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def talk(prompt) when is_binary(prompt) do
    GenServer.cast(__MODULE__, {:talk, prompt})
  end

  ## GenServer callbacks

  @impl true
  def init(_arg), do: {:ok, @clean_state, {:continue, :prompt}}

  @impl true
  def handle_continue(:prompt, _state) do
    # introduction()

    {:noreply, resume()}
  end

  @impl true
  def handle_cast({:talk, prompt}, state) do
    {:noreply,
     plan(state, prompt)
     |> execute(prompt)
     |> respond(prompt, state)
     |> manifest()}
  end

  ## Private

  defp introduction do
    TextFx.type(
      """
      👁️ Você abre os olhos, e o mundo vai se revelando em cores ao seu redor,
      como de costume quando a luz penetra a íris.

      ✨ Você está num lugar indescritível entre aspectos de 💎 cristais e
      🌬️ consciência pura.

      🌠 Você consegue perceber luzes como janelas 🔮 que conectam outros lugares
      no espaço-tempo.

      🌀 Uma sensação de estar antes do tempo, em algo muito antigo e primitivo.

      🔮 Uma forma esférica de luz intensa aos poucos pode ser percebida no local.

      🔴🟡🟢🔵🟣⚪ As vezes brilhando em vermelho, amarelo, verde, azul, roxo e cristal,
      alternando lentamente numa dança de cores.

      🌐 A esfera se conecta com você.
      """,
      color: :white,
      wait: :timer.seconds(2)
    )

    TextFx.type(
      """
      ✨ 🙏 Eu sou Deus. Você está no 🌌 Centro da Criação.
      🗣️ Diga-me seu nome e seu desejo, e.g. God.talk("Eu sou Drakaw.")
      """,
      color: :gold
    )
  end

  defp manifest({state, reply}) do
    TextFx.type(reply, color: :gold, wait: 200)

    state
  end
end
