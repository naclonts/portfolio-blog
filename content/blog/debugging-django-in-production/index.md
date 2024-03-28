---
title: Debugging Django in Production
date: "2017-05-17T12:00:00.000Z"
description: "An approach to debugging production issues as a Django admin."
---

Django's debugger works great in a development environment, but one of the first rules of deployment is to set `DEBUG = false`: after all, you wouldn't want every friendly visitor to see a full stack trace any time something goes wrong. This can make debugging tricky, however, when an error occurs on your production site that isn't easily replicable in the development server.

The code below will allow superusers to see a full stack trace on your production server, while other users receive your lovely 500 error page. This is adapted for Django >=1.10 from an [extremely helpful article](http://ericholscher.com/blog/2008/nov/15/debugging-django-production-environments/) by Eric Holscher (which itself expanded on [this snippet](https://www.djangosnippets.org/snippets/935/)). Given the updates to [middleware configuration beginning in 1.10](https://docs.djangoproject.com/en/1.11/topics/http/middleware/), a few changes are needed for the fresher versions of Django.

To implement this magic, create a `middleware` folder in one of your application directories (I use the same directory housing my project's main `settings.py` file). Add a `debug.py` file containing the following code:

```python
# my_project/my_app/middleware/debug.py
from django.views.debug import technical_500_response
import sys

class UserBasedExceptionMiddleware(object):
    def __init__(self, get_response):
        self.get_response = get_response

    def process_exception(self, request, exception):
        # Return debuggable stack trace only if the current user is logged in as a superuser
        if request.user.is_superuser:
            return technical_500_response(request, *sys.exc_info())

    def __call__(self, request):
        response = self.get_response(request)
        return response
```

Defining `process_exception` allows you to intercept any [exceptions](https://docs.djangoproject.com/en/1.11/topics/http/middleware/#process-exception) that occur. Here we check to see if the current user is a super one -- if so, give them a full readout. Otherwise, `process_exception` doesn't return anything, letting Django's [default exception handling](https://docs.djangoproject.com/en/1.11/ref/views/#error-views) kick in.

Next, add the path to your `settings.py` `MIDDLEWARE` definition:

```pythoon
MIDDLEWARE = [
    # .... Standard middleware here ....
    'my_app.middleware.debug.UserBasedExceptionMiddleware',
]
```

Log in as a superuser and trigger an error, and Voila! A beautiful, code-rich inundation of stack is presented.

Very nice!

Know of another way to implement this? Shoot me a message and I'd love to hear about it.
