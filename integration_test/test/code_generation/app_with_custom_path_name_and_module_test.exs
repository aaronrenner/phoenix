defmodule Phoenix.Integration.CodeGeneration.AppWithCustomPathNameAndModuleTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_custom_path_name_and_module", fn tmp_dir ->
      {app_root_path, _} = generate_phoenix_app(tmp_dir, "custom_path", ["--app", "phx_blog", "--module", "PhoteuxBlog"])

      assert Path.basename(app_root_path) == "custom_path"
      assert_file Path.join(app_root_path, ".gitignore")
      assert_file Path.join(app_root_path, ".gitignore"), ~r/\n$/
      assert_file Path.join(app_root_path, "mix.exs"), ~r/app: :phx_blog/
      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), ~r/app: :phx_blog/
      assert_file Path.join(app_root_path, "config/config.exs"), ~r/namespace: PhoteuxBlog/
      assert_file Path.join(app_root_path, "lib/phx_blog_web.ex"), ~r/use Phoenix.Controller, namespace: PhoteuxBlogWeb/

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
