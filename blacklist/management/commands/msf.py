from django.core.management.base import BaseCommand, CommandError

import os, subprocess

class Command(BaseCommand):

	help = 'Run Metasploit Framework .'

	def handle(self, *args, **options):
		subprocess.run([ 'msfconsole', '-r', '/home/hx/bdfproxy/bdfproxy_msf_resource.rc' ])
