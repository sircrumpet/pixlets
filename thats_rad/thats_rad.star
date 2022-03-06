"""
Applet: That's Rad
Summary: Now Playing for Radio Broadcasts 
Description: Display the currently playing track for your selected Radio Station
Author: Nick Penree
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("cache.star", "cache")


ERROR_ICON = base64.decode("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") 
RADIO_ICON = base64.decode("iVBORw0KGgoAAAANSUhEUgAAACEAAAAgCAYAAACcuBHKAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAIaADAAQAAAABAAAAIAAAAAArIKmwAAAAkUlEQVRYCe2VQQ6AIAwEreH/X1Y4zK0FSzDpYbmsIaVZZ6vYdXg9fWVaWl935sBftTIB2cZDpNmMoz6zfcUBnRIkljOB2686vvtZrTdjJUjIBLGlZ2KVOY0zqjigJRIiAQG0xEyk/xO4j9S7G6Ja9kuQkAniaDsZcnhHvbtHcUCyBAlbzYSXIW9wSkuQkAnifAHYERhFfS1+bwAAAABJRU5ErkJggg==")

def get_station_details(station):
    if station == "double-j":
        return {
            'station': 'double-j',
            'url': 'https://music.abcradio.net.au/api/v1/plays/search.json',
            'params': {
                'station': 'doublej',
                'limit': '1'
            },
            'icon': "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"

        }
    elif station == "fip":
        return {
            'station': 'fip',
            'url': 'https://api.radiofrance.fr/livemeta/live/7/fip_player',
            'params': {
                'preset': '64x64'
            },
            'icon': "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"
        }

def map_station_response(station_details,response):
    station = station_details['station']
    if station == "double-j":
        cover = response['items'][0]['release']['artwork'][0]['sizes'][0]['url']
        if cover:
            cover_req = http.get(cover)
            if cover_req.status_code == 200:
                cover_data = http.get(cover).body() or None
                cover_encoded = base64.encode(cover_data)
            else:
                cover_encoded = station_details['icon']
        else:
            cover_encoded = station_details['icon']



        return {
            'title': response['items'][0]['recording']['title'] or "Title",
            'artist': response['items'][0]['recording']['artists'][0]['name'] or "Artist",
            'album': response['items'][0]['release']['title'] or "Album",
            'cover': cover_encoded or None
        } 

    elif station == "fip":
        cover = response['now']['cover']

        if cover:
            cover_req = http.get(cover)
            if cover_req.status_code == 200:
                cover_data = http.get(cover).body() or None
                cover_encoded = base64.encode(cover_data)
            else:
                cover_encoded = station_details['icon']
        else:
            cover_encoded = station_details['icon']


        return {
            'title': response['now']['secondLine'],
            'artist': response['now']['thirdLine'],
            'album': response['now']['firstLine'],
            'cover': cover_encoded or None
        }


def now_playing(station):

    station_details = get_station_details(station)

    resp = http.get(station_details['url'], params = station_details['params'])
    if resp.status_code != 200:
        print(resp)
        return None

    resp = resp.json()

    now_playing = map_station_response(station_details, resp)

    return now_playing


def do_render(title, artist, cover):
    return render.Root(
        render.Column(
            main_align = "space_around",
            cross_align = "center",
            expanded = True,
            children = [
                render.Padding(
                    pad = (2,3,0,0),
                    child = render.Row(
                        children = [
                            render.Padding(
                                pad = (0,0,2,0),
                                child =  render.Image(
                                    src = RADIO_ICON,
                                    height = 8,
                                    width = 6,
                                ),
                            ),
                            render.Marquee(
                                width = 61,
                                child = render.Text(
                                    content = title,
                                    # color = '#0a0',
                                    font = "tb-8",
                                ),
                            )
                        ]
                    ),
                ),
                render.Row(
                    main_align = "start",
                    cross_align = "center",
                    expanded = True,
                    children = [
                        render.Box(
                            child = render.Image(
                                src = base64.decode(cover),
                                height = 22,
                                width = 22,
                            ),
                            width = 22,
                            height = 22,
                            padding = 2,
                        ),
                        render.Marquee(
                            width = 42,
                            child = render.Text(
                                content = artist,
                                font = "tb-8",
                            ),
                        ),
                    ],
                )
            ],
        ),
    )


def render_error(error = "Error :("):
    print('!!! Rendering Error: ' + error)
    return render.Root(
        child = render.Box(
            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [
                    render.Image(src = ERROR_ICON, width=16, height=16),
                    render.Marquee(child = render.Text(error), width = 32),
                ],
            ),
        ),
    )


def main(config):
    station = config.get("station", "fip")

    np = now_playing(station)

    if np == None:
        render_error()

    print('got now playing')
    print(np)


    return do_render(np['title'], np['artist'], np['cover'])

    # return render.Root(
    #     child = render.Image(
    #         width = 32,
    #         height = 32,
    #         src =  base64.decode(np['cover']),
    #     ),
    # )


def get_schema():
    options = [
        schema.Option(
            display = "Double J",
            value = "double-j",
        ),
        schema.Option(
            display = "FIP",
            value = "fip",
        ),
    ]
    return schema.Schema(
        version = "1",
        fields = [
              schema.Dropdown(
                  id = "station",
                  name = "Radio Station",
                  desc = "The radio station you're listening to.",
                  icon = "radio",
                  default = options[0].value,
                  options = options,
              )
        ],
    )