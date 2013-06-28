from django.contrib.auth.middleware import RemoteUserMiddleware
from django.contrib.auth.backends import RemoteUserBackend

class ProxyRemoteUserMiddleware(RemoteUserMiddleware):
    header = 'HTTP_REMOTE_USER'

class ProxyRemoteUserBackend(RemoteUserBackend):
    def configure_user(self, user):
        user.email = user.username
        user.is_active = True
        user.save()
