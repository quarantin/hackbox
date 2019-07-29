import os, sys

import django
from django.conf import settings

sys.path.append('.')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hackbox.settings')
django.setup()
