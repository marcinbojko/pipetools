FROM alpine:3.15.4 AS build
LABEL version="v0.1.2"
LABEL release="pipetools"
LABEL maintainer="marcinbojko"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# additions
COPY --from=hashicorp/terraform:1.2.2 /bin/terraform /bin/terraform
COPY --from=aquasec/tfsec:v1.22.0 /usr/bin/tfsec /bin/tfsec
COPY --from=anchore/syft:v0.46.3 /syft /bin/syft
COPY --from=hadolint/hadolint:v2.10.0 /bin/hadolint /bin/hadolint
COPY --from=ghcr.io/terraform-linters/tflint:v0.37.0 /usr/local/bin/tflint /bin/tflint

# shellcheck disable=SC2169
RUN apk update && apk add --no-cache --update -t deps ca-certificates curl bash gettext tar gzip openssl openssh rsync python3 python3-dev py3-pip py3-wheel tzdata git httpie sshfs shellcheck jq npm && pip3 install --no-cache-dir --upgrade wheel pip yamllint jsonlint dos2unix \
  && npm install -g dockerfilelint \
  && mkdir -p ~/.ssh \
  && eval "$(ssh-agent -s)" \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config \
  && chmod -R 700 ~/.ssh \
  && apk upgrade
CMD ["busybox"]
