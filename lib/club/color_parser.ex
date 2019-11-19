defmodule Club.ColorParser do
  @moduledoc """
  Wikipedia color names/hex values parser.

  All the colors data itself has [Wikipedia copyrights](https://en.wikipedia.org/wiki/Wikipedia:Copyrights)
  and distributed under the [Creative Commons Attribution-ShareAlike 3.0 Unported License](https://en.wikipedia.org/wiki/Wikipedia:Text_of_Creative_Commons_Attribution-ShareAlike_3.0_Unported_License).
  """

  @urls [
    "https://en.wikipedia.org/wiki/List_of_colors:_A%E2%80%93F",
    "https://en.wikipedia.org/wiki/List_of_colors:_G%E2%80%93M",
    "https://en.wikipedia.org/wiki/List_of_colors:_N%E2%80%93Z"
  ]

  @filename "colors.json"

  def parse_and_save(filename \\ @filename) do
    parse()
    |> Jason.encode!()
    |> Jason.Formatter.pretty_print()
    |> save(filename)
  end

  def parse do
    []
    |> get_colors_from_urls(@urls)
    |> Enum.map(fn
      {color, hex} ->
        %{uuid: UUID.uuid4(), name: color, hex: String.trim(hex, "#")}
    end)
    |> Enum.reverse()
  end

  defp save(colors_text, filename) do
    File.write!(filename, colors_text)
  end

  defp get_colors_from_urls(parsed_colors, [url | rest]) do
    charurl = String.to_charlist(url)
    {:ok, {_, _, body}} = :httpc.request(charurl)

    rows =
      body
      |> List.to_string()
      |> Floki.find("#mw-content-text > div.mw-parser-output > table > tbody > tr")

    parsed_colors
    |> parse_rows(rows)
    |> get_colors_from_urls(rest)
  end

  defp get_colors_from_urls(parsed_colors, []), do: parsed_colors

  defp parse_rows(parsed_colors, [
         {"tr", _,
          [
            {"th", _, _},
            {"th", _, _},
            {"th", _, _},
            {"th", _, _},
            {"th", _, _},
            {"th", _, _},
            {"th", _, _},
            {"th", _, _},
            {"th", _, _},
            {"th", _, _}
          ]}
         | rest
       ]),
       do: parse_rows(parsed_colors, rest)

  defp parse_rows(parsed_colors, [{"tr", _, children} | rest]) do
    [parse_row(children) | parsed_colors]
    |> parse_rows(rest)
  end

  defp parse_rows(parsed_colors, []), do: parsed_colors

  defp parse_row([color, hex, _, _, _, _, _, _, _, _]),
    do: {Floki.text(color), Floki.text(hex) |> String.trim()}
end
