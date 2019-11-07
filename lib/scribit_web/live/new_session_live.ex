defmodule ScribitWeb.NewSessionLive do
  use Phoenix.LiveView
  use PhoenixInlineSvg.Helpers, otp_app: :scribit
  use Phoenix.HTML

  def mount(%{provider_paths: provider_paths} = _session, socket) do
    socket =
      socket
      |> assign(:persist_session, false)
      |> assign(:provider_paths, provider_paths)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="pv4 ph2 tc-l">
      <input type="checkbox" <%= if @persist_session do %>checked<% end %> phx-click="persist_session">
        Remember me for 30 days
      </input>
    </div>

    <div class="pv4 ph2 tc-l">
      <%=
        for {provider, path} <- @provider_paths do # PowAssent.Phoenix.ViewHelpers.provider_links(@conn),
          provider_str = provider |> Atom.to_string()

          img = svg_image(provider_str, "social", class: "social-login dib h2 w2", fill: "currentColor" )

          caption = content_tag(:span, String.capitalize(provider_str), class: "f6 ml3 pr2")

          [img, caption]
          |> link(to: build_auth_path(path, @persist_session), title: provider_str, class: "no-underline near-white bg-animate bg-near-black hover-bg-gray inline-flex items-center ma2 tc br2 pa2")
        end
      %>
    </div>
    """
  end

  def handle_event("persist_session", _, %{assigns: %{persist_session: true}} = socket) do
    {:noreply, assign(socket, :persist_session, false)}
  end

  def handle_event("persist_session", _, %{assigns: %{persist_session: false}} = socket) do
    {:noreply, assign(socket, :persist_session, true)}
  end

  defp build_auth_path(path, persist?),  do: "#{path}?user[persistent_session]=#{persist?}"

end
