load("render.star", "render")
load("cache.star", "cache")
load("time.star", "time")
load("humanize.star", "humanize")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("schema.star", "schema")
load("secret.star", "secret")

FORECAST_URL = "https://api.rainparrot.com/v1/ios_device"
RADAR_URL = "https://api.rainparrot.com/v1/radar_image"

ENCRYPTED_API_KEY = "AV6+xWcE3l18+UJsEVHYxaLF4QTnQx+zATuU0H0bAKpPhtlTwcrZ2RCsguFb69tHtW6RAB6EAo2+L3LbSQbGtA8bJs2byRFX9n4LNzUr6pJ5YIyJsqqUIFedInwfF5b3uHjRWzQKRkXyGPsSfwg7DuzFMwdT3W5ooLNx9yUtE3h+Z7AO7TFTAE+qr23LbanCT4+8kqI2Rxd2avx/97ifidycJwgCog=="
DEFAULT_LOCATION = """
{
    "lat": "-27.718",
    "lng": "153.24",
    "description": "Brisbane, QLD, AU",
    "locality": "Brisbane",
    "place_id": "",
    "timezone": "Australia/Brisbane"
}
"""

ERROR_ICON = base64.decode("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")
def get_rp_headers(config):
    return {
        "Host": "api.rainparrot.com",
        "X-API-Token": secret.decrypt(ENCRYPTED_API_KEY) or config.get('rp_api'),
        "User-Agent": "Rain%20Parrot/112 CFNetwork/1329 Darwin/21.3.0",
    }

def get_forecast(config):

    deviceId = config.get('device_id')

    forecast = cache.get(deviceId)
    radars = cache.get(deviceId + '_radars')

    location = json.decode(config.get("location", DEFAULT_LOCATION));
    accuracy = "###.###"

    if forecast == None:
        params = {
            "id": deviceId,
            "view_lat": humanize.float(accuracy, float(location["lat"])),
            "view_long": humanize.float(accuracy, float(location["lng"])),
        }

        resp = http.get(FORECAST_URL, params = params, headers = get_rp_headers(config))

        if resp.status_code == 403:
            print(resp)
            return {'error': 'Unable to Auth with RainParrot'}
        elif resp.status_code != 200:
            print(resp)
            return {'error': 'Unable to connect to RainParrot'}

        forecast = resp.json()

        # print('Loaded forecast')
        cache.set(deviceId, json.encode(forecast), ttl_seconds = 60)
        # print(forecast)
    else:
        # print('Got cached forecast')
        forecast = json.decode(forecast)

    if radars == None:
        # print('No radar data')

        radar_id = forecast['radar_info']['location']['location_views'][3]['code'];
        resp = http.get(RADAR_URL, params = {'id': radar_id, 'count': '20'}, headers = {"Host": "api.rainparrot.com"})
        if resp.status_code != 200:
            print(resp)
            return {'error': 'Unable get radar'}

        radars = resp.json()
        cache.set(deviceId + '_radars', json.encode(radars), ttl_seconds = 120)

    else:
        # print('got cached radars')
        radars = json.decode(radars)

    forecast['radars'] = radars

    return forecast

def render_frame(image, config):
    # print('render frame')
    imgTime = time.parse_time(image['date'])
    time_str = imgTime.in_location("Australia/Brisbane").format('03:04PM')

    show_time = True if config.get('show_time') == "true" else False

    # print('Show time?')
    # print(config.get('show_time', False))

    return render.Stack(children = [
        render.Padding(
            pad = (0, -16, 0, 0),
            child = render.Image(
                src = base64.decode(image['image_data']),
                width = 64,
                height = 64
            ),
        ),
        render.Column(
            expanded=True,
            main_align="end",
            children = [ 
                render.Row(
                    expanded=True,
                    main_align="center",
                    children = [ 
                        render.Padding(
                            child=render.Text(time_str, font="CG-pixel-3x5-mono"),
                            pad=(36,1,1,1)
                        )
                    ]
                )
            ]
        ) if show_time else None,
    ])

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

    apiKey = secret.decrypt(ENCRYPTED_API_KEY) or config.get('rp_api')
    if config.get('device_id') == None:
        return render_error('You must set a Device ID')
    if apiKey == None:
        return render_error('You must set an API Key')

    forecast = get_forecast(config)
    if forecast.get('error'):
        return render_error(forecast['error'])




    FC_MAP = base64.decode(forecast['images'][0]['image_data'])

    LOCATION_X = (forecast['offset']['x'] / 4) - 16
    LOCATION_Y = (forecast['offset']['y'] / 4) - 16

    FRAME_DELAY = 18

    bg_images = [render_frame(image, config) for image in forecast['radars']['images']]
    bg_frames = []
    for i, h in enumerate(bg_images):
        bg_frames.extend([h] * FRAME_DELAY)

    # print('Loading frames')
    # print(bg_frames)

    reversed_frames = bg_frames[::-1]

    return render.Root(
        # delay = 200,
        child = render.Stack(
            children=[
                render.Animation(children = reversed_frames),
                # render.Padding(
                #     render.Image(src=FC_MAP, width=64, height=64),
                #     pad = (0,-16,0,0),
                # ),
                render.Padding(
                    render.Circle(
                         color="#651e3e",
                         diameter=4,
                         child=render.Circle(color="#f9caa7", diameter=2),
                    ),
                    pad = (int(LOCATION_X) - 1, int(LOCATION_Y) - 1, 0,0),
                ),
                render.Padding(
                    pad = (14,6,2,2),
                    child = render.Text(content = forecast['minutely_weather']['header'], font="CG-pixel-4x5-mono")
                ),
                render.Padding(
                    pad = (4,14,0,0),
                    child=render.Marquee(
                        height=16,
                        child = render.WrappedText(
                         width=58,
                         font="tb-8",
                         content=forecast['minutely_weather']['message']
                        ),
                        scroll_direction="vertical"
                    )
                )
                # render.Padding(
                #     pad = (4,14,0,0),
                #     child = render.Marquee(
                #      scroll_direction='horizontal',
                #      width=57,
                #      height=16,
                #      child=render.Text(forecast['minutely_weather']['message'])
                #     ),
                # )
            ],
        )
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "device_id",
                name = "Device ID",
                desc = "Rain Parrot Device ID.",
                icon = "mobile",
            ),
            schema.Text(
                id = "rp_api",
                name = "API Key",
                desc = "Rain Parrot API Key.",
                icon = "key",
            ),
            schema.Location(
                id = "location",
                name = "Location",
                desc = "Location for which to display radar",
                icon = "place",
            ),
            schema.Toggle(
                id = "show_time",
                name = "Show Time",
                desc = "Show time of displayed radar",
                icon = "clock",
                default = False,
            )
        ],
    )