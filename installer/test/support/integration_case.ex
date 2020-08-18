defmodule Phx.New.CodeGeneratorCase do
  @moduledoc """
  Test case template for Phoenix code generator
  tests
  """
  use ExUnit.CaseTemplate

  alias Phx.New.TestSupport.MixTaskRunner

  using do
    quote do
      setup_all do
        # Get Mix output sent to the current
        # process to avoid polluting tests.
        Mix.shell(Mix.Shell.Process)
      end

      import unquote(__MODULE__)
    end
  end

  def generate_phoenix_app(app_name, opts \\ []) when is_binary(app_name) and is_list(opts) do
    app_path = Path.expand(app_name)
    installer_root = Path.expand("../../", __DIR__)

    File.cd!(installer_root, fn ->
      File.cwd!()

      # The shell asks to install deps.
      # We will politely say not.
      send self(), {:mix_shell_input, :yes?, false}

      Mix.Tasks.Phx.New.run([app_path, "--dev"] ++ opts)
    end)
  end

  def mix_deps_get(app_path) do
    MixTaskRunner.run!(~w(deps.get), cd: app_path)
  end

  def assert_passes_formatter_check(app_path) do
    MixTaskRunner.run!(~w(format --check-formatted), cd: app_path)
  end

  def in_installer_tmp(which, opts \\ [], function) when is_list(opts) and is_function(function, 0) do
    autoremove? = Keyword.get(opts, :autoremove?, true)
    path = Path.join([installer_tmp_path(), random_string(10), to_string(which)])

    try do
      File.rm_rf!(path)
      File.mkdir_p!(path)
      File.cd!(path, function)
    after
      if autoremove?, do: File.rm_rf!(path)
    end
  end

  defp installer_tmp_path do
    Path.expand("../../tmp", __DIR__)
  end

  defp random_string(len) do
    len |> :crypto.strong_rand_bytes() |> Base.encode64() |> binary_part(0, len)
  end
end
