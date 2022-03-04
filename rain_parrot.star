load("render.star", "render")
load("cache.star", "cache")
load("time.star", "time")
load("humanize.star", "humanize")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("schema.star", "schema")
load("secret.star", "secret")

url = "https://api.rainparrot.com/v1/ios_device"

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

def get_rp_headers(config):
    return {
        "Host": "api.rainparrot.com",
        "X-API-Token": secret.decrypt(ENCRYPTED_API_KEY) or config.get('rp_api'),
        "User-Agent": "Rain%20Parrot/112 CFNetwork/1329 Darwin/21.3.0",
    }

def get_forecast(config):
    deviceId = config.get('device_id')

    forecast = cache.get(deviceId)
    location = json.decode(config.get("location", DEFAULT_LOCATION));
    accuracy = "###.###"

    if forecast == None:
        params = {
            "id": deviceId,
            "view_lat": humanize.float(accuracy, float(location["lat"])),
            "view_long": humanize.float(accuracy, float(location["lng"])),
        }

        resp = http.get(url, params = params, headers = get_rp_headers(config))
        if resp.status_code != 200:
            print(resp)
            return None

        forecast = resp.json()

        print('Loaded forecast')
        cache.set(deviceId, json.encode(forecast), ttl_seconds = 60)
        # print(forecast)
        return forecast
    else:
        print('Got cached forecast')
        forecast = json.decode(forecast)
        return forecast

def main(config):

    apiKey = secret.decrypt(ENCRYPTED_API_KEY) or config.get('rp_api')
    if config.get('device_id') == None:
        fail('You must set a Device ID')
    if apiKey == None:
        fail('You must set an API Key')

    forecast = get_forecast(config)
    FC_MAP = base64.decode(forecast['images'][0]['image_data'])

    LOCATION_X = (forecast['offset']['x'] / 4) - 16
    LOCATION_Y = (forecast['offset']['y'] / 4) - 16

    return render.Root(
        child = render.Stack(
            children=[
                render.Padding(
                    render.Image(src=FC_MAP, width=64, height=64),
                    pad = (0,-16,0,0),
                ),
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
                    child = render.Marquee(
                     width=54,
                     child=render.Text(forecast['minutely_weather']['message'])
                    ),
                )
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
        ],
    )