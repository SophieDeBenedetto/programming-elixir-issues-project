defmodule Issues.GithubIssues do 
  @user_agent [{"User-agent", "ElixirProject sophie.debenedetto@gmail.com"}]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_reponse 
  end

  def issues_url(user, project) do 
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_reponse({:ok, %{status_code: 200, body: body}}) do 
    {:ok, Poison.Parser.parse!(body)}
  end

  def handle_reponse({__, %{status_code: __, body: body}}) do
    {:error, Poison.Parser.parse!(body)}
  end
end