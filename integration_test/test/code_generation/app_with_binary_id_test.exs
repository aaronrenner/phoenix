defmodule Phoenix.Integration.CodeGeneration.AppWithBinaryIdTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_binary_id", fn tmp_dir ->
      {app_root_path, _} =
        generate_phoenix_app(tmp_dir, "phx_blog", [
          "--binary-id"
        ])

      assert_file Path.join(app_root_path, "config/config.exs"), ~r/generators: \[binary_id: true\]/

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
