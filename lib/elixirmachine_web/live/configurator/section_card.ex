defmodule ElixirmachineWeb.Configurator.SectionCard do
  @moduledoc false
  use Phoenix.Component

  attr :title, :string, required: true
  attr :open, :boolean, default: false
  attr :section_id, :string, required: true
  slot :inner_block, required: true

  def section_card(assigns) do
    ~H"""
    <div class="collapse collapse-arrow card bg-base-100 border border-base-300 shadow-sm">
      <input type="checkbox" checked={@open} />
      <div class="collapse-title font-semibold text-base-content">{@title}</div>
      <div class="collapse-content space-y-3 pt-2">{render_slot(@inner_block)}</div>
    </div>
    """
  end

  attr :packages, :list, required: true
  attr :features, :list, required: true

  def package_checkboxes(assigns) do
    packages = Enum.reject(assigns.packages, &Map.get(&1, :locked, false))
    assigns = assign(assigns, :selectable_packages, packages)

    ~H"""
    <div class="grid gap-2">
      <%= for package <- @selectable_packages do %>
        <label class={[
          "package-row flex items-start gap-3 rounded-[var(--rounded-btn)] border border-base-300 p-3 card-interactive",
          package.selectable && "cursor-pointer",
          not package.selectable && "opacity-60 cursor-not-allowed"
        ]}>
          <input
            type="checkbox"
            name="generation[features][]"
            value={package.id}
            checked={package.id in @features}
            disabled={not package.selectable}
            class="checkbox checkbox-primary mt-1"
          />
          <span class="flex-1">
            <span class="font-medium">{package.label}</span>
            <span :if={package.coming_soon} class="badge badge-ghost badge-sm ml-2">Coming soon</span>
            <span
              :if={package.disabled_reason && not package.coming_soon}
              class="badge badge-ghost badge-sm ml-2"
            >
              {package.disabled_reason}
            </span>
            <span :if={package.mix_deps != []} class="ml-2 flex flex-wrap gap-1 inline-flex">
              <span :for={dep <- package.mix_deps} class="badge badge-outline badge-xs">{dep}</span>
            </span>
            <span class="block text-sm text-base-content/70 mt-1">{package.description}</span>
          </span>
        </label>
      <% end %>
    </div>
    """
  end

  attr :packages, :list, required: true

  def locked_packages(assigns) do
    packages = Enum.filter(assigns.packages, &Map.get(&1, :locked, false))
    assigns = assign(assigns, :locked_packages, packages)

    ~H"""
    <div :if={@locked_packages != []} class="space-y-2">
      <span class="text-sm font-medium text-base-content/70">Included</span>
      <div class="grid gap-2">
        <%= for package <- @locked_packages do %>
          <input type="hidden" name="generation[features][]" value={package.id} />
          <div class="flex items-start gap-3 rounded-[var(--rounded-btn)] border border-base-300 bg-base-200/40 p-3">
            <span class="badge badge-neutral badge-sm mt-1">included</span>
            <span class="flex-1">
              <span class="font-medium">{package.label}</span>
              <span :if={package.mix_deps != []} class="ml-2 flex flex-wrap gap-1 inline-flex">
                <span :for={dep <- package.mix_deps} class="badge badge-outline badge-xs">{dep}</span>
              </span>
              <span class="block text-sm text-base-content/70 mt-1">{package.description}</span>
            </span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  attr :badges, :list, required: true

  def implicit_badges(assigns) do
    ~H"""
    <div :if={@badges != []} class="flex flex-wrap gap-2">
      <span :for={badge <- @badges} class="badge badge-neutral badge-sm border border-base-300">
        {badge}
      </span>
    </div>
    """
  end
end
