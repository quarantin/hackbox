from django.core.management.base import BaseCommand, CommandError

import os, sys, subprocess

class Command(BaseCommand):

	help = 'Run BDF Proxy.'

	def check_ip_forward(self):
		fin = open('/proc/sys/net/ipv4/ip_forward', 'r')
		status = int(fin.read())
		if status != 1:
			print('You have to enable IPv4 forwarding. Please run the following command before proceeding:\nFor Linux:\n\tsudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"\n\nFor Mac OSX as root:\n\tsysctl -w net.inet.ip.forwarding=1\n\n')
			sys.exit()

	def handle(self, *args, **options):
		self.check_ip_forward()
		os.chdir('/home/hx/bdfproxy.git')
		stderrlog = open('bdfproxy-stderr.log', 'w')
		stdoutlog = open('bdfproxy-stdout.log', 'w')
		subprocess.run([ './bdf_proxy.py' ], stdout=stdoutlog, stderr=stderrlog)
