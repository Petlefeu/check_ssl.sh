# CheckSSL.sh

This script can check the SSL/TLS parameters of a web server.

## Usage

	check_ssl.sh [-hv] -f <fqdn>


## Example

	$ bash check_ssl.sh -f www.leboncoin.fr
	HSTS   header present (OK), Strict-Transport-Security: max-age=15768000
	ETAG   header not present (OK)
	ALPN   not present (NOT ok)
	NPN    not present (NOT ok)
	HTTP Method : GET  joignable (OK)
	HTTP Method : HEAD  joignable (OK)
	HTTP Method : OPTIONS  joignable (OK)
	HTTP Method : DELETE  injoignable (OK)
	HTTP Method : PUT  injoignable (OK)
	HTTP Method : CONNECT  injoignable (OK)
	HTTP Method : TRACK  injoignable (OK)
	HTTP Method : CUSTOM  injoignable (OK)
