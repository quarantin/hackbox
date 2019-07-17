from django.core.management.base import BaseCommand, CommandError

import os, subprocess

class Command(BaseCommand):

	help = 'Run Metasploit Framework .'

	def check_bdf_resource_file():
		return os.path.exists('/home/hx/bdfproxy/bdfproxy_msf_resource.rc')

	def handle(self, *args, **options):

		if not check_bdf_resource_file():
			print('You need to start BDF Proxy first: python3 manage.py bdf_proxy')
			return

		os.chdir('/opt/msf')
		subprocess.run([ 'msfconsole', '-r', '/home/hx/bdfproxy/bdfproxy_msf_resource.rc' ])
