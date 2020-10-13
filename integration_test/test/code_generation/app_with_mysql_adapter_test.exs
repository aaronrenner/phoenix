defmodule Phoenix.Integration.CodeGeneration.AppWithMySqlAdapterTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_mysql_adapter", fn tmp_dir ->
      {app_root_path, _} =
        generate_phoenix_app(tmp_dir, "custom_path", [
              "--database",
              "mysql"
            ])

      assert Path.basename(app_root_path) == "custom_path"
      assert_file Path.join(app_root_path, "mix.exs"), ":myxql"
      assert_file Path.join(app_root_path, "config/dev.exs"), [~r/username: "root"/, ~r/password: ""/]
      assert_file Path.join(app_root_path, "config/test.exs"), [~r/username: "root"/, ~r/password: ""/]
      assert_file Path.join(app_root_path, "config/prod.secret.exs"), [~r/url: database_url/]
      assert_file Path.join(app_root_path, "lib/custom_path/repo.ex"), "Ecto.Adapters.MyXQL"

      assert_file Path.join(app_root_path, "test/support/conn_case.ex"), "Ecto.Adapters.SQL.Sandbox.start_owner"
      assert_file Path.join(app_root_path, "test/support/channel_case.ex"), "Ecto.Adapters.SQL.Sandbox.start_owner"
      assert_file Path.join(app_root_path, "test/support/data_case.ex"), "Ecto.Adapters.SQL.Sandbox.start_owner"

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
