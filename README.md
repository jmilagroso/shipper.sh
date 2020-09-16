# shipper.sh
Ships Kafka topics and latest offsets to GCP Storage using Linkedin Burrow


### Usage
```sh
# Manual
$ shipper.sh -h <BURROW HOST> -s <OAUTH2 CLIENT SECRET> -r <OAUTH2 REFRESH TOKEN> -i <OAUTH2 CLIENT ID> -b <GCP BUCKET> -f <JSON FILENAME>
```

```sh
# Crontab (Everyday at 5pm)
0 17 * * * shipper.sh -h <BURROW HOST> -s <OAUTH2 CLIENT SECRET> -r <OAUTH2 REFRESH TOKEN> -i <OAUTH2 CLIENT ID> -b <GCP BUCKET> -f <JSON FILENAME>
```


### Dependencies
- [Linkedin/Burrow](https://github.com/linkedin/Burrow) - is a monitoring companion for Apache Kafka that provides consumer lag checking as a service without the need for specifying thresholds.
- [GCP Cloud Storage](https://cloud.google.com/storage) - Globally unified, scalable, and highly durable object storage for developers and enterprises.
- [GCP Oauth2.0](https://developers.google.com/identity/protocols/oauth2) - Google APIs use the OAuth 2.0 protocol for authentication and authorization. Google supports common OAuth 2.0 scenarios such as those for web server, client-side, installed, and limited-input device applications.

### References
- https://github.com/linkedin/Burrow
- https://developers.google.com/oauthplayground/
