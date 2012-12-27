from functools import wraps

from django.conf import settings
from django.contrib.auth import login, authenticate
from django.utils.decorators import available_attrs

from localshop.http import HttpResponseUnauthorized

credential_check_needed = (
    'localshop.apps.permissions.backend.CredentialBackend' in
    settings.AUTHENTICATION_BACKENDS
)


def decode_credentials(auth):
    auth = auth.strip().decode('base64')
    return auth.split(':', 1)


def split_auth(request):
    auth = request.META.get('HTTP_AUTHORIZATION')
    if auth:
        method, identity = auth.split(' ', 1)
    else:
        method, identity = None, None
    return method, identity


def authenticate_user(request):
    method, identity = split_auth(request)
    print credential_check_needed, method, identity
    if method is not None and method.lower() == 'basic':
        key, secret = decode_credentials(identity)
        if credential_check_needed:
            return authenticate(access_key=key, secret_key=secret)
        else:
            return authenticate(username=key, password=secret)


def credentials_required(view_func):
    """
    This decorator should be used with views that need simple authentication
    against Django's authentication framework.
    """
    @wraps(view_func, assigned=available_attrs(view_func))
    def decorator(request, *args, **kwargs):
        # Just return the original view because already logged in
        if request.user.is_authenticated():
            return view_func(request, *args, **kwargs)

        user = authenticate_user(request)
        if user is not None:
            login(request, user)
            return view_func(request, *args, **kwargs)

        return HttpResponseUnauthorized(content='Authorization Required')
    return decorator