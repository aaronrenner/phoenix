defmodule Phoenix.Integration.CodeGeneration.AppWithNoOptionsTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("app_with_no_options", fn tmp_dir ->
      {app_root_path, _} = generate_phoenix_app(tmp_dir, "phx_blog", [
            "--no-html",
            "--no-webpack",
            "--no-ecto",
            "--no-gettext",
            "--no-dashboard"
          ])

      # No webpack
      assert_file Path.join(app_root_path, ".gitignore"), fn file ->
        refute String.contains?(file, "/assets/node_modules/")
        assert file =~ ~r/\n$/
      end
      assert_file Path.join(app_root_path,"config/dev.exs"), ~r/watchers: \[\]/

      # No webpack & No HTML
      refute_file Path.join(app_root_path, "priv/static/css/app.css")
      refute_file Path.join(app_root_path, "priv/static/css/phoenix.css")
      refute_file Path.join(app_root_path, "priv/static/favicon.ico")
      refute_file Path.join(app_root_path, "priv/static/images/phoenix.png")
      refute_file Path.join(app_root_path, "priv/static/js/phoenix.js")
      refute_file Path.join(app_root_path, "priv/static/js/app.js")

      # No Ecto
      config = ~r/config :phx_blog, PhxBlog.Repo,/
      refute_file Path.join(app_root_path, "lib/phx_blog/repo.ex")
      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), fn file ->
        refute file =~ "plug Phoenix.Ecto.CheckRepoStatus, otp_app: :phx_blog"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/telemetry.ex"), fn file ->
        refute file =~ "# Database Metrics"
        refute file =~ "summary(\"phx_blog.repo.query.total_time\","
      end

      assert_file Path.join(app_root_path, ".formatter.exs"), fn file ->
        assert file =~ "import_deps: [:phoenix]"
        assert file =~ "inputs: [\"*.{ex,exs}\", \"{config,lib,test}/**/*.{ex,exs}\"]"
        refute file =~ "subdirectories:"
      end

      assert_file Path.join(app_root_path, "mix.exs"), &refute(&1 =~ ~r":phoenix_ecto")

      assert_file Path.join(app_root_path, "config/config.exs"), fn file ->
        refute file =~ "config :phx_blog, :generators"
        refute file =~ "ecto_repos:"
      end

      assert_file Path.join(app_root_path, "config/dev.exs"), fn file ->
        refute file =~ config
        assert file =~ "config :phoenix, :plug_init_mode, :runtime"
      end
      assert_file Path.join(app_root_path, "config/test.exs"), &refute(&1 =~ config)
      assert_file Path.join(app_root_path, "config/prod.secret.exs"), &refute(&1 =~ config)
      assert_file Path.join(app_root_path, "lib/phx_blog_web.ex"), &refute(&1 =~ ~r"alias PhxBlog.Repo")

      # No gettext
      refute_file Path.join(app_root_path, "lib/phx_blog_web/gettext.ex")
      refute_file Path.join(app_root_path, "priv/gettext/en/LC_MESSAGES/errors.po")
      refute_file Path.join(app_root_path, "priv/gettext/errors.pot")
      assert_file Path.join(app_root_path, "mix.exs"), &refute(&1 =~ ~r":gettext")
      assert_file Path.join(app_root_path, "lib/phx_blog_web.ex"), &refute(&1 =~ ~r"import AmsMockWeb.Gettext")
      assert_file Path.join(app_root_path, "lib/phx_blog_web/views/error_helpers.ex"), &refute(&1 =~ ~r"gettext")
      assert_file Path.join(app_root_path, "config/dev.exs"), &refute(&1 =~ ~r"gettext")

      # No HTML
      assert_dir Path.join(app_root_path, "test/phx_blog_web/controllers")

      assert_dir Path.join(app_root_path, "lib/phx_blog_web/controllers")
      assert_dir Path.join(app_root_path, "lib/phx_blog_web/views")

      refute_file Path.join(app_root_path, "test/web/controllers/pager_controller_test.exs")
      refute_file Path.join(app_root_path, "test/views/layout_view_test.exs")
      refute_file Path.join(app_root_path, "test/views/page_view_test.exs")
      refute_file Path.join(app_root_path, "lib/phx_blog_web/controllers/page_controller.ex")
      refute_file Path.join(app_root_path, "lib/phx_blog_web/templates/layout/app.html.eex")
      refute_file Path.join(app_root_path, "lib/phx_blog_web/templates/page/index.html.eex")
      refute_file Path.join(app_root_path, "lib/phx_blog_web/views/layout_view.ex")
      refute_file Path.join(app_root_path, "lib/phx_blog_web/views/page_view.ex")

      assert_file Path.join(app_root_path, "mix.exs"), &refute(&1 =~ ~r":phoenix_html")
      assert_file Path.join(app_root_path, "mix.exs"), &refute(&1 =~ ~r":phoenix_live_reload")
      assert_file Path.join(app_root_path, "lib/phx_blog_web.ex"),
                  &assert(&1 =~ "defp view_helpers do")
      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"),
                  &refute(&1 =~ ~r"Phoenix.LiveReloader")
      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"),
                  &refute(&1 =~ ~r"Phoenix.LiveReloader.Socket")
      assert_file Path.join(app_root_path, "lib/phx_blog_web/views/error_view.ex"), ~r".json"
      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), &refute(&1 =~ ~r"pipeline :browser")

      # No Dashboard
      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), fn file ->
        refute file =~ ~s|socket "/live"|
        refute file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), fn file ->
        refute file =~ "live_dashboard"
        refute file =~ "import Phoenix.LiveDashboard.Router"
      end

      assert_tests_pass(app_root_path)
      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
