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
	HTTP Method : GET  enable (OK)
	HTTP Method : HEAD  enable (OK)
	HTTP Method : OPTIONS  enable (OK)
	HTTP Method : DELETE  disable (OK)
	HTTP Method : PUT  disable (OK)
	HTTP Method : CONNECT  disable (OK)
	HTTP Method : TRACE  disable (OK)
	HTTP Method : TRACK  disable (OK)
	HTTP Method : CUSTOM  disable (OK)

