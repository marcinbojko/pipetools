FROM alpine:3.19.0 AS build
LABEL version="0.2.1"
LABEL release="pipetools"
LABEL maintainer="marcinbojko"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
COPY entrypoint.sh /entrypoint.sh
# additions

COPY --from=hashicorp/terraform:1.9.3 /bin/terraform /bin/terraform
COPY --from=anchore/syft:v1.9.0 /syft /bin/syft
COPY --from=hadolint/hadolint:v2.12.0 /bin/hadolint /bin/hadolint
COPY --from=ghcr.io/terraform-linters/tflint:v0.52.0 /usr/local/bin/tflint /bin/tflint

# shellcheck disable=SC2169
RUN apk update && apk add --no-cache --update -t deps ca-certificates curl bash gettext tar gzip openssl openssh rsync python3 python3-dev py3-pip py3-wheel tzdata git httpie sshfs shellcheck jq npm dos2unix
RUN python3 -m venv /home/pipetools;. /home/pipetools/bin/activate \
  && pip3 install --no-cache-dir --upgrade jsonlint yamllint \
  && npm install -g dockerfilelint \
  && mkdir -p ~/.ssh \
  && eval "$(ssh-agent -s)" \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config \
  && chmod -R 700 ~/.ssh \
  && chmod 700 /entrypoint.sh && chmod +x /entrypoint.sh \
  && apk upgrade
ENTRYPOINT ["/entrypoint.sh"]