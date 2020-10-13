defmodule Phoenix.Integration.CodeGeneration.AppWithUppercaseTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_uppercase", fn tmp_dir ->
      {app_root_path, _} = generate_phoenix_app(tmp_dir, "phxBlog")

      assert_file Path.join(app_root_path, "README.md")

      assert_file Path.join(app_root_path, "mix.exs"), fn file ->
        assert file =~ "app: :phxBlog"
      end

      assert_file Path.join(app_root_path, "config/dev.exs"), fn file ->
        assert file =~ ~r/config :phxBlog, PhxBlog.Repo,/
        assert file =~ "database: \"phxblog_dev\""
      end

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
