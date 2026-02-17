FROM alpine:3.23.3 AS build
LABEL version="0.4.1"
LABEL release="pipetools"
LABEL maintainer="marcinbojko"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
COPY entrypoint.sh /entrypoint.sh
# additions
COPY --from=hashicorp/terraform:1.14.5 /bin/terraform /bin/terraform
COPY --from=ghcr.io/opentofu/opentofu:1.11.5-minimal /usr/local/bin/tofu /bin/tofu
COPY --from=anchore/syft:v1.42.0 /syft /bin/syft
COPY --from=hadolint/hadolint:v2.14.0 /bin/hadolint /bin/hadolint
COPY --from=ghcr.io/terraform-linters/tflint:v0.61.0 /usr/local/bin/tflint /bin/tflint
COPY --from=axiomhq/cli:0.14.1 /usr/bin/axiom /bin/axiom
COPY --from=infisical/cli:0.43.56 /bin/infisical /bin/infisical

# shellcheck disable=SC2169
RUN apk update && apk add --no-cache --update -t deps ca-certificates curl bash gettext tar gzip openssl openssh rsync python3 python3-dev py3-pip py3-wheel tzdata git httpie sshfs shellcheck jq npm dos2unix gcc musl-dev linux-headers docker git-lfs sshpass
ENV VIRTUAL_ENV=/home/pipetools
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python3 -m venv /home/pipetools;. /home/pipetools/bin/activate \
  && pip3 install --no-cache-dir --upgrade jsonlint yamllint azure-cli \
  && npm install -g dockerfilelint \
  && mkdir -p ~/.ssh \
  && eval "$(ssh-agent -s)" \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config \
  && chmod -R 700 ~/.ssh \
  && chmod 700 /entrypoint.sh && chmod +x /entrypoint.sh \
  && apk upgrade
# checkov:skip=CKV_DOCKER_2
# Reason: Healthcheck is not required for this image
# checkov:skip=CKV_DOCKER_3
# Reason: User root is required for this image
ENTRYPOINT ["/entrypoint.sh"]
