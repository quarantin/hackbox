from django.core.management.base import BaseCommand, CommandError

import os, subprocess

class Command(BaseCommand):

	help = 'Run BDF Proxy.'

	def handle(self, *args, **options):
		os.chdir('/bdfproxy')
		stderrlog = open('bdfproxy-stderr.log', 'w')
		stdoutlog = open('bdfproxy-stdout.log', 'w')
		subprocess.run([ './bdf_proxy.py' ], stdout=stdoutlog, stderr=stderrlog)
