defmodule StoryTeller.Music.Player do
  @moduledoc false
  use GenServer
  require Logger

  @default_dir Path.expand("~/Music/ambient")
  @default_cmd System.find_executable("mpv") || System.find_executable("cvlc")

  ## Public API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop, do: GenServer.call(__MODULE__, :stop)
  def playing?, do: GenServer.call(__MODULE__, :playing?)
  def play(opts \\ []), do: GenServer.call(__MODULE__, {:play, opts})

  ## GenServer callbacks

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)

    cmd =
      Keyword.get(opts, :cmd, @default_cmd) ||
        raise "No audio player found in PATH (tried mpv, cvlc)."

    dir = Keyword.get(opts, :dir, @default_dir) |> Path.expand()
    autostart = Keyword.get(opts, :autostart, true)

    File.dir?(dir) || Logger.warning("Music dir #{dir} not found; player may exit.")

    args = args_for(cmd, dir)
    port = if autostart, do: open_player(cmd, args), else: nil

    {:ok, %{cmd: cmd, args: args, dir: dir, port: port}}
  end

  @impl true
  def handle_call(:stop, _from, state) do
    safe_close(state.port)
    {:reply, :ok, %{state | port: nil}}
  end

  def handle_call(:playing?, _from, state) do
    {:reply, is_port_alive?(state.port), state}
  end

  # NEW: play / restart logic
  def handle_call({:play, opts}, _from, state) do
    new_cmd = Keyword.get(opts, :cmd, state.cmd)
    new_dir = Keyword.get(opts, :dir, state.dir)
    new_args = args_for(new_cmd, new_dir)

    cond do
      is_port_alive?(state.port) and new_cmd == state.cmd and new_dir == state.dir ->
        {:reply, :already_playing, state}

      true ->
        safe_close(state.port)
        port = open_player(new_cmd, new_args)
        {:reply, :ok, %{state | cmd: new_cmd, dir: new_dir, args: new_args, port: port}}
    end
  end

  @impl true
  def handle_info({_port, {:data, _bin}}, state), do: {:noreply, state}

  def handle_info({:exit_status, status}, state) do
    Logger.warning("Music player exited with status #{status}; restarting in 1s")
    Process.send_after(self(), :restart, 1000)
    {:noreply, %{state | port: nil}}
  end

  def handle_info(:restart, %{cmd: cmd, args: args} = state) do
    port = open_player(cmd, args)
    {:noreply, %{state | port: port}}
  end

  @impl true
  def terminate(_reason, state) do
    safe_close(state.port)
    :ok
  end

  ## Helpers

  defp args_for(cmd, dir) do
    case Path.basename(cmd) do
      "mpv" -> ["--no-video", "--shuffle", "--loop-playlist=inf", "--quiet", dir]
      "cvlc" -> ["--intf", "dummy", "--loop", "--random", dir]
      _ -> ["--no-video", "--shuffle", "--loop-playlist=inf", dir]
    end
  end

  defp open_player(cmd, args) do
    Logger.info("Starting background music: #{cmd} #{Enum.join(args, " ")}")

    Port.open({:spawn_executable, "scripts/x/safe_open.sh"}, [
      :binary,
      :exit_status,
      :use_stdio,
      :stderr_to_stdout,
      {:args, [cmd | args]}
    ])
  end

  defp safe_close(nil), do: :ok

  defp safe_close(port) do
    try do
      Port.close(port)
    rescue
      _ -> :ok
    end
  end

  defp is_port_alive?(nil), do: false

  defp is_port_alive?(port) do
    case :erlang.port_info(port) do
      :undefined -> false
      _ -> true
    end
  end
end
