defmodule SabiaWeb.MyComponents do
  use Phoenix.Component

  attr :email, :string, required: true
  attr :size, :integer, default: 32
  attr :alt, :string, default: ""

  def gravatar(assigns) do
    email = String.downcase(String.trim(assigns.email))
    email_hash = Base.encode16(:crypto.hash(:sha256, email), case: :lower)

    assigns = assign(assigns, :email_hash, email_hash)

    ~H"""
    <img
      src={"https://gravatar.com/avatar/#{@email_hash}?s=#{@size}&d=mp"}
      class="rounded-full"
      width={@size}
      alt={@alt}
    />
    """
  end
end
