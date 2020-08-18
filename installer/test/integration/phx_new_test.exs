defmodule Mix.Tasks.Phx.New.IntegrationTest do
  use Phx.New.CodeGeneratorCase, async: false

  test "new with defaults" do
    in_installer_tmp "new with defaults", fn ->
      generate_phoenix_app("phx_blog")

      mix_deps_get("phx_blog")

      assert_passes_formatter_check("phx_blog")
    end
  end

  test "new without defaults" do
    in_installer_tmp "new without defaults", fn ->
      generate_phoenix_app("phx_blog", ["--no-html", "--no-webpack", "--no-ecto", "--no-gettext", "--no-dashboard"])

      mix_deps_get("phx_blog")

      assert_passes_formatter_check("phx_blog")
    end
  end
end
