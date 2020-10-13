Code.require_file "mix_helper.exs", __DIR__

defmodule Mix.Tasks.Phx.NewTest do
  use ExUnit.Case, async: false
  import MixHelper
  import ExUnit.CaptureIO

  @app_name "phx_blog"

  setup do
    # The shell asks to install deps.
    # We will politely say not.
    send self(), {:mix_shell_input, :yes?, false}
    :ok
  end

  test "returns the version" do
    Mix.Tasks.Phx.New.run(["-v"])
    assert_received {:mix_shell, :info, ["Phoenix v" <> _]}
  end

  test "new inside umbrella" do
    in_tmp "new inside umbrella", fn ->
      File.write! "mix.exs", MixHelper.umbrella_mixfile_contents()
      File.mkdir! "apps"
      File.cd! "apps", fn ->
        Mix.Tasks.Phx.New.run([@app_name])

        assert_file "phx_blog/mix.exs", fn file ->
          assert file =~ "deps_path: \"../../deps\""
          assert file =~ "lockfile: \"../../mix.lock\""
        end

        assert_file "phx_blog/assets/package.json", fn file ->
          assert file =~ ~s["file:../../../deps/phoenix"]
          assert file =~ ~s["file:../../../deps/phoenix_html"]
        end
      end
    end
  end

  test "new with --no-install" do
    in_tmp "new with no install", fn ->
      Mix.Tasks.Phx.New.run([@app_name, "--no-install"])

      # Does not prompt to install dependencies
      refute_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

      # Instructions
      assert_received {:mix_shell, :info, ["\nWe are almost there" <> _ = msg]}
      assert msg =~ "$ cd phx_blog"
      assert msg =~ "$ mix deps.get"

      assert_received {:mix_shell, :info, ["Then configure your database in config/dev.exs" <> _]}
      assert_received {:mix_shell, :info, ["Start your Phoenix app" <> _]}
    end
  end

  test "new with invalid database adapter" do
    in_tmp "new with invalid database adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      assert_raise Mix.Error, ~s(Unknown database "invalid"), fn ->
        Mix.Tasks.Phx.New.run([project_path, "--database", "invalid"])
      end
    end
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Phx.New.run ["007invalid"]
    end

    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Phx.New.run ["valid", "--app", "007invalid"]
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Phx.New.run ["valid", "--module", "not.valid"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phx.New.run ["string"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phx.New.run ["valid", "--app", "mix"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phx.New.run ["valid", "--module", "String"]
    end
  end

  test "invalid options" do
    assert_raise Mix.Error, ~r/Invalid option: -d/, fn ->
      Mix.Tasks.Phx.New.run(["valid", "-database", "mysql"])
    end
  end

  test "new without args" do
    in_tmp "new without args", fn ->
      assert capture_io(fn -> Mix.Tasks.Phx.New.run([]) end) =~
             "Creates a new Phoenix project."
    end
  end
end
