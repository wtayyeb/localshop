FROM python:2.7

MAINTAINER  Michael van Tellingen <michaelvantellingen@gmail.com>

# Create localshop user and group
RUN useradd -r -U -m -m -d /opt/localshop -s /sbin/nologin localshop

ENV DJANGO_STATIC_ROOT /opt/localshop/static

# Install localshop
RUN pip install https://github.com/mvantellingen/localshop/archive/develop.zip#egg=localshop

# Install uWSGI / Honcho
run pip install psycopg2==2.6.0
run pip install uwsgi==2.0.10
run pip install honcho==0.6.6


# Initialize the app
RUN DJANGO_SECRET_KEY=tmp localshop collectstatic --noinput


# Switch to user
USER localshop

EXPOSE 8000

CMD uwsgi --http 0.0.0.0:8000 --module localshop.wsgi --master --die-on-term
