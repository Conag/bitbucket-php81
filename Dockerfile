FROM ubuntu:22.04

# Set environment variables
ENV HOME /root

# MySQL root password
ARG MYSQL_ROOT_PASS=root

# Cloudflare DNS
RUN echo "nameserver 1.1.1.1" | tee /etc/resolv.conf > /dev/null

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common && \
    DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:ondrej/php && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    git \
    ca-certificates \
    unzip \
    mcrypt \
    wget \
    openssl \
    ssh \
    locales \
    less \
    vim \
    sudo \
    mariadb-server \
    curl \
    gnupg \
    make \
    php8.1-mysql php8.1-zip php8.1-xml php8.1-mbstring php8.1-curl php8.1-pdo php8.1-tokenizer php8.1-cli php8.1-imap php8.1-intl php8.1-gd php8.1-xdebug php8.1-soap php8.1-apcu php8.1-redis php8.1-bcmath \
    apache2 libapache2-mod-php8.1 \
    supervisor \
    --no-install-recommends && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -f /var/lib/mysql/ib_logfile*

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# Ensure UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN locale-gen en_US.UTF-8

# Timezone & memory limit
RUN echo "date.timezone=Europe/Paris" > /etc/php/8.1/cli/conf.d/date_timezone.ini
RUN echo "memory_limit=1G" >> /etc/php/8.1/apache2/php.ini
RUN service mariadb start && mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY ''; FLUSH PRIVILEGES;"

# Install nodejs from nodesource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt install -y nodejs

# Goto temporary directory.
WORKDIR /tmp
