FROM ubuntu:22.04

RUN apt-get -qq update && apt-get install -qq -y --no-install-recommends \
    ca-certificates \
    curl \
    gawk \
    libexpat1 \
    libpq5 \
    mysql-client \
    nginx \
    python3 \
    python3-dev \
    libmysqlclient-dev \
    build-essential \
    manpages-dev \
    # python-setuptools \
    pip \
    # python-crypto \
    #Flask \
    # python-flask \
    # python-pil \
    # python-mysqldb \
    unixodbc \
    uwsgi
    # uwsgi-plugin-python

RUN curl -s \
    http://sphinxsearch.com/files/sphinx-3.5.1-82c60cb-linux-amd64.tar.gz \
    -o /tmp/sphinxsearch.tar.gz \
# && dpkg -i /tmp/sphinxsearch.deb \
# && rm /tmp/sphinxsearch.deb \
# && easy_install -q flask-cache \
#&& pip install -q supervisor \
&& tar -xzf /tmp/sphinxsearch.tar.gz \
&& cp sphinx-3.5.1/bin/* /usr/bin/ \
&& cp sphinx-3.5.1/etc/* /etc/ \
&& mkdir -p /var/log/sphinxsearch \
&& mkdir -p /var/log/supervisord

VOLUME ["/data/"]


COPY requirements.txt requirements.txt
RUN pip install -r ./requirements.txt


COPY conf/sphinx/*.conf /etc/sphinxsearch/
COPY conf/nginx/nginx.conf /etc/nginx/sites-available/default
COPY supervisor/*.conf /etc/supervisor/conf.d/
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY web /usr/local/src/websearch
COPY sphinx-reindex.sh /
COPY tests/* /tests/

ENV SPHINX_PORT=9312 \
    SEARCH_MAX_COUNT=100 \
    SEARCH_DEFAULT_COUNT=20

EXPOSE 80
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
