# SQL Server Command Line Tools - custom image
# From Alpine 3.11 (~5 MBs)
FROM alpine:3.11

# * ##################################
# * CHANGES
# * wrap RUNs into a single RUN command, this avoids multiple layers, reduce it from ~40MB to 17.7MB (so basically we added 12MB on top of alpine)
# * Allows you to change MSSQL_VERSION by passing `--build-arg MSSQL_VERSION=<new version>` during  docker build.

ARG MSSQL_VERSION=17.5.2.1-1
ENV MSSQL_VERSION=${MSSQL_VERSION}
# Adding custom MS repository for mssql-tools and msodbcsql
WORKDIR /tmp
RUN apk add --no-cache curl gnupg --virtual .build-dependencies -- && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSQL_VERSION}_amd64.apk && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQL_VERSION}_amd64.apk && \
    # Verifying signature
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSQL_VERSION}_amd64.sig && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQL_VERSION}_amd64.sig && \
    # Importing gpg key
    curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - && \
    gpg --verify msodbcsql17_${MSSQL_VERSION}_amd64.sig msodbcsql17_${MSSQL_VERSION}_amd64.apk && gpg --verify mssql-tools_${MSSQL_VERSION}_amd64.sig mssql-tools_${MSSQL_VERSION}_amd64.apk && \
    # Installing packages
    echo y | apk add --allow-untrusted msodbcsql17_${MSSQL_VERSION}_amd64.apk mssql-tools_${MSSQL_VERSION}_amd64.apk && \
    #! probably we dont need these build-deps, remove line otherwise
    apk del .build-dependencies && rm -f msodbcsql*.sig mssql-tools*.apk

WORKDIR /
# Adding SQL Server tools to $PATH
ENV PATH=$PATH:/opt/mssql-tools/bin
CMD /bin/sh

# feel free to modify these labels, use label-schema if needed
LABEL   maintainer="@dbamastery" \
        mssql_version=${MSSQL_VERSION}}
