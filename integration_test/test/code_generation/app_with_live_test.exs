defmodule Phoenix.Integration.CodeGeneration.AppWithLiveTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_live", fn tmp_dir ->
      {app_root_path, _} =
        generate_phoenix_app(tmp_dir, "phx_blog", [
              "--live"
            ])

      assert_file Path.join(app_root_path, "mix.exs"), &assert(&1 =~ ~r":phoenix_live_view")
      assert_file Path.join(app_root_path, "mix.exs"), &assert(&1 =~ ~r":floki")

      refute_file Path.join(app_root_path, "lib/phx_blog_web/controllers/page_controller.ex")

      assert_file Path.join(app_root_path, "lib/phx_blog_web/live/page_live.ex"), fn file ->
        assert file =~ "defmodule PhxBlogWeb.PageLive do"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/templates/layout/root.html.leex"), fn file ->
        assert file =~ ~s|<%= live_title_tag assigns[:page_title]|
        assert file =~ ~s|<%= link "LiveDashboard", to: Routes.live_dashboard_path(@conn, :home)|
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/live/page_live.html.leex"), fn file ->
        assert file =~ ~s[Welcome]
      end

      assert_file Path.join(app_root_path, "assets/package.json"),
                  ~s["phoenix_live_view": "file:../deps/phoenix_live_view"]

      assert_file Path.join(app_root_path, "assets/js/app.js"), fn file ->
        assert file =~ ~s[import {LiveSocket} from "phoenix_live_view"]
      end

      assert_file Path.join(app_root_path, "assets/css/app.scss"), fn file ->
        assert file =~ ~s[@import "../node_modules/nprogress/nprogress.css";]
        assert file =~ ~s[.phx-click-loading]
      end

      assert_file Path.join(app_root_path, "config/config.exs"), fn file ->
        assert file =~ "live_view:"
        assert file =~ "signing_salt:"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web.ex"), fn file ->
        assert file =~ "import Phoenix.LiveView.Helpers"
        assert file =~ "def live_view do"
        assert file =~ "def live_component do"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), ~s[socket "/live", Phoenix.LiveView.Socket]
      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), fn file ->
        assert file =~ ~s[plug :fetch_live_flash]
        assert file =~ ~s[plug :put_root_layout, {PhxBlogWeb.LayoutView, :root}]
        assert file =~ ~s[live "/", PageLive]
        refute file =~ ~s[plug :fetch_flash]
        refute file =~ ~s[PageController]
      end

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
