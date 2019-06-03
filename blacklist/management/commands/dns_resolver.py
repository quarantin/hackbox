from django.core.management.base import BaseCommand, CommandError
from blacklist.models import *

from scapy.all import *
from socket import AF_INET, SOCK_DGRAM, socket
from traceback import print_exc

class CustomResolved:
	def resolve(self, request, handler):
		reply = request.reply()
		reply.add_answer()
		return reply
class Command(BaseCommand):

	help = 'Create DNS blackhole configuration file for dnsmasq.'

	def handle(self, *args, **options):
		fin = open('/etc/dnsmasq.d/dnsmasq-blackhole.conf', 'w')
		blacklist = BlacklistedDomain.objects.all()
		for domain in blacklist:
			fin.write('address=/%s/127.0.0.1\n' % domain)
		fin.close()
