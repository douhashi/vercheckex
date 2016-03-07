defmodule VercheckEx do
  require HTTPoison
  require Floki
  require Timex
  use Timex

  def fetch_content( url, type ) do
    ret = HTTPoison.get!( url )
    %HTTPoison.Response { status_code: 200, body: body } = ret

    { _, _, n } = Floki.find( body, "[itemprop=title]" ) |> List.first
    { _, date } = Floki.find( body, "time" ) |> Floki.attribute( "datetime" )
                                           |> List.first
                                           |> Timex.DateFormat.parse( "{ISOz}" )

    if( type == :type1 ) do
      { _, _, x } = Floki.find( body, ".tag-name span" ) |> List.first
    else
      { _, _, x } = Floki.find( body, ".css-truncate-target span" ) |> List.first
    end

    date |> Timex.Date.Convert.to_erlang_datetime
         |> Timex.Date.from "Asia/Tokyo"

    { hd( n ), hd(x), date }
  end

  def put_a_formatted_line( val ) do
    { title, ver, date } = val
    l = title
    if String.length( title ) < 8 do
      l = l <> "\t"
    end
    l = l <> "\t" <> ver
    if String.length( ver ) < 8 do
      l = l <> "\t"
    end
    l = l <> "\t" <> Timex.DateFormat.format!( date, "%Y.%m.%d", :strftime )
    now = Timex.Date.now( "JST" )
    diff  Timex.Date.diff( date, now, days )
    if diff < 14 do
      l = l <> "\t<<<<< updated at " <> Integer.to_string( diff ) <> " day(s) ago."
    end

    IO.puts( l )
  end
end

urls = [
  {"https://github.com/jquery/jquery/releases", :type1},
  {"https://github.com/angular/angular/releases", :type1},
  {"https://github.com/facebook/react/releases", :type2},
  {"https://github.com/PuerkitoBio/goquery/releases", :type1},
  {"https://github.com/revel/revel/releases", :type2},
  {"https://github.com/lhorie/mithril.js/releases", :type1},
  {"https://github.com/riot/riot/releases", :type1},
  {"https://github.com/atom/atom/releases", :type2},
  {"https://github.com/Microsoft/TypeScript/releases", :type2},
  {"https://github.com/docker/docker/releases", :type1},
  {"https://github.com/JuliaLang/julia/releases", :type2},
  {"https://github.com/nim-lang/Nim/releases", :type1},
  {"https://github.com/elixir-lang/elixir/releases", :type2},
  {"https://github.com/philss/floki/releases", :type1},
  {"https://github.com/takscape/elixir-array/releases", :type2},
]

Enum.each( urls, fn( i ) ->
  { u, t } = i
  res = VercheckEx.fetch_content( u, t )
  VercheckEx.put_a_formatted_line res
end)
