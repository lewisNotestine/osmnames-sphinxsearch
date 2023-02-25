FROM ubuntu:16.04

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
    unixodbc \
    uwsgi

RUN echo exit 0 > /usr/bin/policy-rc.d
RUN curl -s \
    http://sphinxsearch.com/files/sphinxsearch_2.3.2-beta-1~xenial_amd64.deb \
    -o /tmp/sphinxsearch.deb \
&& RUNLEVEL=1 dpkg -i /tmp/sphinxsearch.deb \
&& rm /tmp/sphinxsearch.deb \
&& mkdir -p /var/log/sphinxsearch \
&& mkdir -p /var/log/supervisord

VOLUME ["/data/"]

COPY requirements.txt requirements.txt

RUN curl "https://bootstrap.pypa.io/pip/3.5/get-pip.py" -o "get-pip.py"
RUN python3 get-pip.py
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
