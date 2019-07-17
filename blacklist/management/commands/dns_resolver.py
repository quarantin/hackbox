from django.core.management.base import BaseCommand, CommandError
from blacklist.models import *

import subprocess

class Command(BaseCommand):

	help = 'Create DNS blackhole configuration file for dnsmasq.'

	def handle(self, *args, **options):
		blacklist = BlacklistedDomain.objects.all()
		fin = open('/etc/dnsmasq.d/dnsmasq-blackhole.conf', 'w')
		for domain in blacklist:
			fin.write('address=/%s/127.0.0.1\n' % domain)
		fin.close()

		subprocess.run([ 'sudo', '/etc/init.d/avahi-daemon', 'restart' ])
