## 0.0.1

First release version

## 0.0.2

Updating documentation

## 0.0.3

- Apikey is deprecated, change it to use PAT instead. See [here](https://api.gandi.net/docs/authentication/).
- Use simpler architecture, with a simple script copied in the docker image and a config.yaml file, following the [custom addon tutorial](https://developers.home-assistant.io/docs/add-ons/tutorial/#the-runsh-file)
- Add better documentation and a button to install the repo on homeassistant with a simple click (taken from the [custom addon example](https://github.com/home-assistant/addons-example))
- Change the script to be simply run once, since by default it runs at boot. For regular updating, a scheduler can be used, similar to Let's Encrypt

## 0.0.4

- Force IPv4 when detecting the public IP (`curl -s4`). On a dual-stack network, curl was connecting over IPv6 and the add-on pushed an IPv6 address into an `A` record, which the Gandi LiveDNS API rejects with a 400 error (reported as a PAT permission issue).
- Add a 10s timeout to the public IP detection request.
- Make the Gandi API response parsing robust to error objects: instead of crashing with `jq: error: Cannot index string with string "rrset_values"`, the raw response is now logged as an error.

## 0.0.5

- Restore an explicit `build.yaml`. Recent Supervisor versions no longer provide a default `BUILD_FROM`, so the add-on failed to install with `base name (${BUILD_FROM}) should not be blank`. The base images are pinned to `ghcr.io/home-assistant/{arch}-base:3.21`, which ships bashio, curl and jq.
