defmodule Phoenix.Integration.CodeGeneration.AppWithLiveNoDashboardTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_live_no_dashboard", fn tmp_dir ->
      {app_root_path, _} =
        generate_phoenix_app(tmp_dir, "phx_blog", [
              "--live", "--no-dashboard"
            ])

      assert_file Path.join(app_root_path, "mix.exs"), &refute(&1 =~ ~r":phoenix_live_dashboard")

      assert_file Path.join(app_root_path, "lib/phx_blog_web/templates/layout/root.html.leex"), fn file ->
        refute file =~ ~s|<%= link "LiveDashboard", to: Routes.live_dashboard_path(@conn, :home)|
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), fn file ->
        assert file =~ ~s|defmodule PhxBlogWeb.Endpoint|
        assert file =~ ~s|socket "/live"|
        refute file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
