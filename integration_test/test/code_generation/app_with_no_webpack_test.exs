defmodule Phoenix.Integration.CodeGeneration.AppWithNoWebpackTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_no_webpack", fn tmp_dir ->
      {app_root_path, _} =
        generate_phoenix_app(tmp_dir, "phx_blog", [
          "--no-webpack"
        ])

      assert_file Path.join(app_root_path, ".gitignore")
      assert_file Path.join(app_root_path, ".gitignore"), ~r/\n$/
      assert_file Path.join(app_root_path, "priv/static/css/app.css")
      assert_file Path.join(app_root_path, "priv/static/css/phoenix.css")
      assert_file Path.join(app_root_path, "priv/static/favicon.ico")
      assert_file Path.join(app_root_path, "priv/static/images/phoenix.png")
      assert_file Path.join(app_root_path, "priv/static/js/phoenix.js")
      assert_file Path.join(app_root_path, "priv/static/js/app.js")

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
