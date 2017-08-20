FROM python:2.7
MAINTAINER  w.tayyeb <w.tayyeb@gmail.com>

RUN apt update \
        && apt install -y --no-install-recommends supervisor \
    && rm -rf /var/lib/apt/lists/*

ENV LOCALSHOP_HOME=/opt/localshop \
    DJANGO_STATIC_ROOT=${LOCALSHOP_HOME}/static

# Create user / env
RUN useradd -r localshop -d ${LOCALSHOP_HOME} \
    && virtualenv ${LOCALSHOP_HOME}/venv \
    && mkdir -p ${LOCALSHOP_HOME}/var \
    && chown -R localshop:localshop ${LOCALSHOP_HOME}/

# Switch to user
# USER localshop:localshop

EXPOSE 8000

#ENTRYPOINT ["/home/localshop/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

COPY supervisord.conf /etc/supervisord

# install localshop itself
RUN ${LOCALSHOP_HOME}/venv/bin/pip install --no-cache-dir https://github.com/wtayyeb/localshop/archive/develop.zip#egg=localshop
RUN DJANGO_SECRET_KEY='dummy' ${LOCALSHOP_HOME}/venv/bin/localshop collectstatic --noinput

