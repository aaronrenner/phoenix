defmodule Phoenix.Integration.CodeGeneration.AppWithNoHTMLTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_no_html", fn tmp_dir ->
      {app_root_path, _} =
        generate_phoenix_app(tmp_dir, "phx_blog", [
          "--no-html"
        ])

      assert_file Path.join(app_root_path, "mix.exs"), fn file ->
        refute file =~ ~s|:phoenix_live_view|
        assert file =~ ~s|:phoenix_live_dashboard|
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), fn file ->
        assert file =~ ~s|defmodule PhxBlogWeb.Endpoint|
        assert file =~ ~s|socket "/live"|
        assert file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), fn file ->
        refute file =~ ~s|pipeline :browser|
        assert file =~ ~s|pipe_through [:fetch_session, :protect_from_forgery]|
      end

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
