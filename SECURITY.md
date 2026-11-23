# Security policy

## Supported versions

Only `latest` is supported. A fix is released as a new `<version>-dockerupdate-N` tag (for example `6.8-dockerupdate-1`), and `latest` is moved to it. Version tags are never rebuilt.

## Reporting a vulnerability

Please report vulnerabilities privately through GitHub: [open a private report](https://github.com/Erikvl87/docker-languagetool/security/advisories/new). Do not open a public issue, pull request, or discussion for a vulnerability that is not public yet.

A useful report includes:

- the image tag or digest you used (`docker inspect --format '{{index .RepoDigests 0}}' erikvl87/languagetool:<tag>`)
- the steps to reproduce the problem
- what an attacker can do with it

A CVE that a scanner reports in a published tag, for a package that is already fixed upstream, is public information. You can open a normal issue for those.

## What to expect

I maintain this image in my spare time, so handling reports is best effort and there is no fixed response time. That effort covers the Docker packaging of LanguageTool only, as described under scope below.

When I confirm a report, I fix it in a new release and publish a GitHub security advisory for it. I credit the reporter in the advisory unless they prefer not to be named.

## Scope

In scope:

- the `Dockerfile` and the build process, including the arm64 workaround in `arm64-workaround/`
- `start.sh` and the default configuration the image starts LanguageTool with
- the choice and versions of the base images and the Alpine packages installed in the image
- the GitHub Actions workflows in this repository that build, test, and publish the image
- the example configurations in this repository, such as `docker-compose.yml` and `cors-workaround/`

Out of scope:

- LanguageTool itself and the Java libraries it ships with (the files in `/LanguageTool` in the image, including `/LanguageTool/libs`). Please report these to the LanguageTool project: [languagetool-org/languagetool](https://github.com/languagetool-org/languagetool). As of November 2026 that project does not publish a security policy or a private reporting channel on GitHub, so contact its maintainers directly.
- Vulnerabilities in Alpine, Debian, or OpenJDK packages that are not fixed upstream yet. Report those to the distribution. I pick up the fix in a new release once it is available.

## Expected behavior

The image starts the LanguageTool HTTP server with `--public` and `--allow-origin '*'`, so it listens on all interfaces, accepts cross-origin requests from any site, and has no authentication. That is intended for a self-hosted grammar checker and is not treated as a vulnerability. Do not expose the container directly to an untrusted network. Put it behind a reverse proxy with access control, or bind the port to `127.0.0.1` (`-p 127.0.0.1:8010:8010`).
