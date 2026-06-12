defmodule ElixirmachineWeb.ConfiguratorLiveTest do
  use ElixirmachineWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders wizard step indicator", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "Project configurator"
    assert html =~ "Project"
    assert html =~ "Storage"
    assert html =~ "Review"
  end

  test "shows project step first without accordion sections", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    html = render(view)

    assert html =~ "Project metadata"
    refute html =~ "Code quality"
  end

  test "wizard next moves to storage step", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("standalone_otp")

    view
    |> form("#configurator-form", %{"generation" => generation})
    |> render_change()

    html = submit_wizard_next(view, generation)

    assert html =~ "Storage backend"
    assert html =~ "PostgreSQL"
    assert html =~ "ETS"
  end

  test "next without output path shows validation error", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("standalone_otp", %{"output_path" => ""})

    html = submit_wizard_next(view, generation)

    assert html =~ "Output path is required"
  end

  test "next with invalid project name shows validation error", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("standalone_otp", %{"project_name" => "MyApp"})

    html = submit_wizard_next(view, generation)

    assert html =~
             "Must start with a letter and contain only lowercase letters, numbers, and underscores"
  end

  test "next with valid project fields advances without prior render_change", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("standalone_otp")

    html = submit_wizard_next(view, generation)

    assert html =~ "Storage backend"
  end

  test "storage step shows locked postgres on phoenix api", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("phoenix_api")

    view
    |> form("#configurator-form", %{"generation" => generation})
    |> render_change()

    html = submit_wizard_next(view, generation)

    assert html =~ "included"
    assert html =~ "Ecto + PostgreSQL"
  end

  test "liveview ui checkboxes on frontend step", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("phoenix_liveview")

    view
    |> form("#configurator-form", %{"generation" => generation})
    |> render_change()

    html = advance_to_step(view, 3, "phoenix_liveview")

    assert html =~ "Petal Components"
    assert html =~ ~s'name="generation[features][]" value="daisy_ui"'
  end

  test "validate with empty features target does not crash", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("phoenix_liveview")

    view
    |> form("#configurator-form", %{"generation" => generation})
    |> render_change()

    view = advance_to_addons(view, generation)

    html =
      render_change(view, "validate", %{"_target" => ["generation", "features"]})

    refute html =~ "Project metadata"
    assert html =~ "Add-ons"
  end

  test "next on addons step with wizard_action only advances to review", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("phoenix_liveview")

    view
    |> form("#configurator-form", %{"generation" => generation})
    |> render_change()

    view = advance_to_addons(view, generation)

    html = submit_wizard_next(view)

    assert html =~ "Review"
    assert html =~ "Confirm your selection"
  end

  test "wizard state preserved after uncheck all addons", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    generation = project_generation("phoenix_liveview", %{"project_name" => "test_app"})

    view
    |> form("#configurator-form", %{"generation" => generation})
    |> render_change()

    view = advance_to_addons(view, generation)

    view
    |> element("button[phx-value-tab=code_quality]")
    |> render_click()

    view
    |> form("#configurator-form", %{"generation" => %{"features" => ["credo"]}})
    |> render_change()

    render_change(view, "validate", %{"_target" => ["generation", "features"]})

    html = submit_wizard_next(view)

    assert html =~ "Review"
    assert html =~ "test_app"
  end

  test "step indicator renders heroicons", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "hero-cube"
    assert html =~ "hero-check-badge"
  end

  defp project_generation(project_type, overrides \\ %{}) do
    Map.merge(
      %{
        "project_name" => "my_app",
        "project_type" => project_type,
        "target_os" => "macos",
        "output_path" => "/tmp/my_app"
      },
      overrides
    )
  end

  defp submit_wizard_next(view, generation \\ nil) do
    case generation do
      nil ->
        view
        |> form("#configurator-form", %{})
        |> render_submit(%{"wizard_action" => "next"})

      gen ->
        view
        |> form("#configurator-form", %{"generation" => gen})
        |> render_submit(%{"generation" => gen, "wizard_action" => "next"})
    end
  end

  defp advance_to_step(view, 0, _project_type), do: render(view)

  defp advance_to_step(view, steps, project_type) do
    generation = project_generation(project_type)

    1..steps
    |> Enum.reduce(view, fn step, v ->
      if step == 1, do: submit_wizard_next(v, generation), else: submit_wizard_next(v)
      v
    end)
    |> render()
  end

  defp advance_to_addons(view, generation) do
    # project → storage → http → frontend → addons (4 next clicks after project sync)
    1..4
    |> Enum.reduce(view, fn step, v ->
      if step == 1, do: submit_wizard_next(v, generation), else: submit_wizard_next(v)
      v
    end)
  end
end
