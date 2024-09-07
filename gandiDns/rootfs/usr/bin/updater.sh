#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: GandiDns
#
# GandiDNS add-on for Hass.io.
# This add-on update public IP on Gandi API.
# ==============================================================================

get_current_ip() {
    echo "$(curl -s ifconfig.me)"
}

get_gandi_ip() {
    domain=$1
    reccord=$2
    token=$3
    
    bashio::log.debug "[Gandi] - Get data for - ${domain} - ${reccord}"
    echo "$(curl -s -H "Authorization: Bearer ${token}" https://api.gandi.net/v5/livedns/domains/${domain}/records/${reccord} | jq -r 'try .[].rrset_values[0] catch "Invalid response"')"
}

update_gandi_ip() {
    domain=$1
    reccord=$2
    token=$3
    ip=$4
    payload='{"items": [{"rrset_type": "A","rrset_values": ["'"${ip}"'"],"rrset_ttl": 300}]}'
    bashio::log.debug "[Gandi] - Update reccord - ${domain} - ${reccord}"
    echo "$(curl -s -g -X PUT -H "Content-Type: application/json" -d "${payload}" -H "Authorization: Bearer ${token}" https://api.gandi.net/v5/livedns/domains/${domain}/records/${reccord})"

}
# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
    local domain
    local reccords
    local token
    local current_ip
    local gandi_ip


    domain=$(bashio::config 'domain')
    reccords=$(bashio::config 'reccords')
    token=$(bashio::config 'token')

    bashio::log.trace "${FUNCNAME[0]}"
    bashio::log.info "Updater Started"
    while true; do
        current_ip=$(get_current_ip)
        bashio::log.debug "Current ip is ${current_ip}"

        gandi_ip=$(get_gandi_ip "${domain}" "${reccords[0]}" "${token}")
        bashio::log.debug "Gandi ip is ${gandi_ip}"

        if [ "${gandi_ip} = 'Invalid response'"]; then
            bashio::log.error "Could not get response from API, make sure your PAT is working"
        elif [ "${current_ip}" = "${gandi_ip}" ]; then
            bashio::log.debug "Ip is correct"
        else
            bashio::log.debug "Ip did not match, need an update"
            for reccord in ${reccords}
            do
                bashio::log.debug "Updating reccord ${reccord}"
                res=$(update_gandi_ip "${domain}" "${reccord}" "${token}" "${current_ip}")
                bashio::log.debug "Reccord ${res}"
                bashio::log.info "[GandiDns] - Domain ${reccord}.${domain} updated with IP ${current_ip}"
            done
        sleep 600
        fi
    done
    
}
main "$@"
