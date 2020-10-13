defmodule Phoenix.Integration.CodeGeneration.AppWithDefaultsTest do
  use Phoenix.Integration.CodeGeneratorCase, async: true

  test "newly generated app has no warnings or errors" do
    with_installer_tmp("new with defaults", fn tmp_dir ->
      {app_root_path, output} = generate_phoenix_app(tmp_dir, "phx_blog")

      assert_file Path.join(app_root_path, "README.md")

      assert_file Path.join(app_root_path, ".formatter.exs"), fn file ->
        assert file =~ "import_deps: [:ecto, :phoenix]"
        assert file =~ "inputs: [\"*.{ex,exs}\", \"priv/*/seeds.exs\", \"{config,lib,test}/**/*.{ex,exs}\"]"
        assert file =~ "subdirectories: [\"priv/*/migrations\"]"
      end

      assert_file Path.join(app_root_path, "mix.exs"), fn file ->
        assert file =~ "app: :phx_blog"
        refute file =~ "deps_path: \"../../deps\""
        refute file =~ "lockfile: \"../../mix.lock\""
      end

      assert_file Path.join(app_root_path, "config/config.exs"), fn file ->
        assert file =~ "ecto_repos: [PhxBlog.Repo]"
        assert file =~ "config :phoenix, :json_library, Jason"
        refute file =~ "namespace: PhxBlog"
        refute file =~ "config :phx_blog, :generators"
      end

      assert_file Path.join(app_root_path, "config/prod.exs"), fn file ->
        assert file =~ "port: 80"
        assert file =~ ":inet6"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog/application.ex"), ~r/defmodule PhxBlog.Application do/
      assert_file Path.join(app_root_path, "lib/phx_blog.ex"), ~r/defmodule PhxBlog do/
      assert_file Path.join(app_root_path, "mix.exs"), fn file ->
        assert file =~ "mod: {PhxBlog.Application, []}"
        assert file =~ "{:jason, \"~> 1.0\"}"
        assert file =~ "{:phoenix_live_dashboard,"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web.ex"), fn file ->
        assert file =~ "defmodule PhxBlogWeb do"
        assert file =~ "use Phoenix.View,\n        root: \"lib/phx_blog_web/templates\""
      end

      assert_file Path.join(app_root_path, "test/phx_blog_web/controllers/page_controller_test.exs")
      assert_file Path.join(app_root_path, "test/phx_blog_web/views/page_view_test.exs")
      assert_file Path.join(app_root_path, "test/phx_blog_web/views/error_view_test.exs")
      assert_file Path.join(app_root_path, "test/phx_blog_web/views/layout_view_test.exs")
      assert_file Path.join(app_root_path, "test/support/conn_case.ex")
      assert_file Path.join(app_root_path, "test/test_helper.exs")

      assert_file Path.join(app_root_path, "lib/phx_blog_web/controllers/page_controller.ex"),
                  ~r/defmodule PhxBlogWeb.PageController/

      assert_file Path.join(app_root_path, "lib/phx_blog_web/views/page_view.ex"),
                  ~r/defmodule PhxBlogWeb.PageView/

      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), fn file ->
        assert file =~ "defmodule PhxBlogWeb.Router"
        assert file =~ "live_dashboard"
        assert file =~ "import Phoenix.LiveDashboard.Router"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), fn file ->
        assert file =~ ~s|defmodule PhxBlogWeb.Endpoint|
        assert file =~ ~s|socket "/live"|
        assert file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/templates/layout/app.html.eex"),
                  "<title>PhxBlog · Phoenix Framework</title>"
      assert_file Path.join(app_root_path, "lib/phx_blog_web/templates/page/index.html.eex"), fn file ->
        version = Application.spec(:phx_new, :vsn) |> to_string() |> Version.parse!()
        changelog_vsn = "v#{version.major}.#{version.minor}"
        assert file =~
          "https://github.com/phoenixframework/phoenix/blob/#{changelog_vsn}/CHANGELOG.md"
      end

      # webpack
      assert_file Path.join(app_root_path, ".gitignore"), "/assets/node_modules/"
      assert_file Path.join(app_root_path, ".gitignore"), "phx_blog-*.tar"
      assert_file Path.join(app_root_path, ".gitignore"), ~r/\n$/
      assert_file Path.join(app_root_path, "assets/webpack.config.js"), "js/app.js"
      assert_file Path.join(app_root_path, "assets/.babelrc"), "env"
      assert_file Path.join(app_root_path, "config/dev.exs"), fn file ->
        assert file =~ "watchers: [\n    node:"
        assert file =~ "lib/phx_blog_web/(live|views)/.*(ex)"
        assert file =~ "lib/phx_blog_web/templates/.*(eex)"
      end
      assert_file Path.join(app_root_path, "assets/static/favicon.ico")
      assert_file Path.join(app_root_path, "assets/static/images/phoenix.png")
      assert_file Path.join(app_root_path, "assets/css/app.scss")
      assert_file Path.join(app_root_path, "assets/css/phoenix.css")
      assert_file Path.join(app_root_path, "assets/js/app.js"),
                  ~s[import socket from "./socket"]
      assert_file Path.join(app_root_path, "assets/js/socket.js"),
                  ~s[import {Socket} from "phoenix"]

      assert_file Path.join(app_root_path, "assets/package.json"), fn file ->
        assert file =~ ~s["file:../../../"]
        assert file =~ ~s["file:../deps/phoenix_html"]
      end

      refute_file Path.join(app_root_path, "priv/static/css/app.scss")
      refute_file Path.join(app_root_path, "priv/static/css/phoenix.css")
      refute_file Path.join(app_root_path, "priv/static/js/phoenix.js")
      refute_file Path.join(app_root_path, "priv/static/js/app.js")

      assert_dir Path.join(app_root_path, "assets/vendor")

      # Ecto (defaults to pg adapter)
      assert_file Path.join(app_root_path, "mix.exs"), fn file ->
        assert file =~ "{:phoenix_ecto,"
        assert file =~ "{:postgrex,"
        assert file =~ "aliases: aliases()"
        assert file =~ "ecto.setup"
        assert file =~ "ecto.reset"
      end

      assert_file Path.join(app_root_path, "config/dev.exs"), fn file ->
        assert file =~ ~s|config :phx_blog, PhxBlog.Repo,|
        assert file =~ ~s|username: "postgres"|
        assert file =~ ~s|password: "postgres"|
        assert file =~ ~s|hostname: "localhost"|
      end

      assert_file Path.join(app_root_path, "config/test.exs"), fn file ->
        assert file =~ ~s|config :phx_blog, PhxBlog.Repo,|
        assert file =~ ~s|username: "postgres"|
        assert file =~ ~s|password: "postgres"|
        assert file =~ ~s|hostname: "localhost"|
        assert file =~ ~S|database: "phx_blog_test#{System.get_env("MIX_TEST_PARTITION")}"|
      end

      assert_file Path.join(app_root_path, "config/prod.secret.exs"), fn file ->
        assert file =~ ~s|config :phx_blog, PhxBlog.Repo,|
        assert file =~ ~s|url: database_url|
      end

      assert_file Path.join(app_root_path, "lib/phx_blog/repo.ex"), fn file ->
        assert file =~ "defmodule PhxBlog.Repo"
        assert file =~ "Ecto.Adapters.Postgres"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web.ex"), ~r"defmodule PhxBlogWeb"
      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), ~r"plug Phoenix.Ecto.CheckRepoStatus, otp_app: :phx_blog"
      assert_file Path.join(app_root_path, "priv/repo/seeds.exs"), ~r"PhxBlog.Repo.insert!"
      assert_file Path.join(app_root_path, "test/support/conn_case.ex"), "Ecto.Adapters.SQL.Sandbox.start_owner"
      assert_file Path.join(app_root_path, "test/support/channel_case.ex"), "Ecto.Adapters.SQL.Sandbox.start_owner"

      assert_file Path.join(app_root_path, "test/support/data_case.ex"), fn file ->
        assert file =~ "defmodule PhxBlog.DataCase"
        assert file =~ "Ecto.Adapters.SQL.Sandbox.start_owner"
      end
      assert_file Path.join(app_root_path, "priv/repo/migrations/.formatter.exs"), ~r"import_deps: \[:ecto_sql\]"

      # LiveView (disabled by default)
      refute_file "phx_blog/lib/phx_blog_web/live/page_live_view.ex"
      refute_file "phx_blog/assets/js/live.js"
      assert_file Path.join(app_root_path, "mix.exs"), &refute(&1 =~ ~r":phoenix_live_view")
      assert_file Path.join(app_root_path, "mix.exs"), &refute(&1 =~ ~r":floki")
      assert_file Path.join(app_root_path, "assets/package.json"),
                  &refute(&1 =~ ~s["phoenix_live_view": "file:../deps/phoenix_live_view"])

      assert_file Path.join(app_root_path, "assets/js/app.js"), fn file -> refute file =~ "LiveSocket" end

      assert_file Path.join(app_root_path, "lib/phx_blog_web.ex"), fn file ->
        refute file =~ "Phoenix.LiveView"
      end
      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), &refute(&1 =~ ~s[plug :fetch_live_flash])
      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), &refute(&1 =~ ~s[plug :put_root_layout])
      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), &refute(&1 =~ ~s[HomeLive])
      assert_file Path.join(app_root_path, "lib/phx_blog_web/router.ex"), &assert(&1 =~ ~s[PageController])

      # Telemetry
      assert_file Path.join(app_root_path, "mix.exs"), fn file ->
        assert file =~ "{:telemetry_metrics, \"~> 0.4\"}"
        assert file =~ "{:telemetry_poller, \"~> 0.4\"}"
      end

      assert_file Path.join(app_root_path, "lib/phx_blog_web/telemetry.ex"), fn file ->
        assert file =~ "defmodule PhxBlogWeb.Telemetry do"
        assert file =~ "{:telemetry_poller, measurements: periodic_measurements()"
        assert file =~ "defp periodic_measurements do"
        assert file =~ "# {PhxBlogWeb, :count_users, []}"
        assert file =~ "def metrics do"
        assert file =~ "summary(\"phoenix.endpoint.stop.duration\","
        assert file =~ "summary(\"phoenix.router_dispatch.stop.duration\","
        assert file =~ "# Database Metrics"
        assert file =~ "summary(\"phx_blog.repo.query.total_time\","
      end


      # Install dependencies is skipped for integration tests
      refute output =~ "\nFetch and install dependencies?"

      # Instructions
      assert output =~ "\nWe are almost there"
      assert output =~ "$ cd phx_blog"
      assert output =~ "$ mix deps.get"

      assert output =~ "Then configure your database in config/dev.exs"
      assert output=~ "Start your Phoenix app"

      # Channels
      assert_dir Path.join(app_root_path, "lib/phx_blog_web/channels")
      assert_file Path.join(app_root_path, "lib/phx_blog_web/channels/user_socket.ex"), ~r"defmodule PhxBlogWeb.UserSocket"
      assert_file Path.join(app_root_path, "lib/phx_blog_web/endpoint.ex"), ~r"socket \"/socket\", PhxBlogWeb.UserSocket"
      assert_dir Path.join(app_root_path, "test/phx_blog_web/channels")

      # Gettext
      assert_file Path.join(app_root_path, "lib/phx_blog_web/gettext.ex"), ~r"defmodule PhxBlogWeb.Gettext"
      assert_file Path.join(app_root_path, "priv/gettext/errors.pot")
      assert_file Path.join(app_root_path, "priv/gettext/en/LC_MESSAGES/errors.po")

      assert_no_compilation_warnings(app_root_path)
      assert_passes_formatter_check(app_root_path)
    end)
  end
end
