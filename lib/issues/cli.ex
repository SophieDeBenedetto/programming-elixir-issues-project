require IEx;
defmodule Issues.CLI do 
  @default_count 4
  @id_col_width 12
  @created_at_col_width 20
  @title_col_width 30

  @moduledoc """
  Handle the command line parsing and the dispatch to the various functions that end up generating a table of the last _n_ isses in a github project.
  """
  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be iether -h or --help, which returns :help

  Otherwise, it is a github user name, project name and (optionally) the number of entries to format

  Return a tuple of `{user, project, count}` or `:help` if help was given.
  """

  def parse_args(argv) do 
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases: [h: :help])
    # IEx.pry
    # iex -S mix test
    case parse do 
      {[help: true], _, _} -> :help
      {_, [user, project, count], _} -> {user, project, String.to_integer count}
      {_, [user, project], _} -> {user, project, @default_count}
      _ -> :help
    end
  end

  def process(:help) do 
    IO.puts """
    Usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> convert_to_list_of_maps
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> output_in_table
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, body}) do 
    {_, message} = List.keyfind(body, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def convert_to_list_of_maps(list) do 
    list
    |> Enum.map(&Enum.into(&1, Map.new))
  end

  def sort_into_ascending_order(list_of_issues) do 
    Enum.sort list_of_issues, &(&1["created_at"] <= &2["created_at"])
  end

  def output_in_table(list_of_issues) do 
    IO.puts "#           | created_at         | title                         "
    IO.puts "------------|--------------------|------------------------------|"
    list_of_issues
    |> Enum.each(&(IO.puts format_table_row(&1)))
  end

  def format_table_row(issue) do 
    id(issue) <> created_at(issue) <> title(issue)
  end

  def id(issue), do: whitespace(["id", @id_col_width, issue])
  def created_at(issue), do: whitespace(["created_at", @created_at_col_width, issue])
  def title(issue), do: whitespace(["title", @title_col_width, issue])


  def whitespace(["id", width, issue]) do 
    String.length(Integer.to_string issue["id"])
    |> calculate_whitespace(width)
    |> generate_cell(issue["id"])
  end

  def whitespace([col_name, width, issue]) do 
    String.length(issue[col_name])
    |> calculate_whitespace(width)
    |> generate_cell(issue[col_name])
  end

  def calculate_whitespace(length_of_word, width) do
    width - length_of_word
  end

  def generate_cell(width, data) when width > 0, do: "#{data} #{String.duplicate(" ", width)}"
  
  def generate_cell(width, data), do: String.slice(data, 0..-4) <> "...  "  







end