FROM python:2.7

MAINTAINER  Michael van Tellingen <michaelvantellingen@gmail.com>

# Create localshop user and group
RUN useradd -r -U -m -m -d /opt/localshop -s /sbin/nologin localshop


# Create virtualenv
ENV VENV /opt/localshop/venv

RUN virtualenv ${VENV}


# Install docker related requirements
RUN . ${VENV}/bin/activate; \
    pip install psycopg2~=2.6.0 \
                uwsgi~=2.0.10 \
                honcho~=0.6.6



ENV DJANGO_STATIC_ROOT /opt/localshop/static


# Install localshop
ADD . /opt/localshop
WORKDIR /opt/localshop

RUN . ${VENV}/bin/activate; \
    pip install -r requirements.txt


# Initialize the app
RUN DJANGO_SECRET_KEY=tmp \
    /opt/localshop/venv/bin/localshop collectstatic --noinput


# Switch to user
USER localshop

EXPOSE 8000

CMD /opt/localshop/venv/bin/uwsgi \
    --http 0.0.0.0:8000 --module localshop.wsgi --master --die-on-term
