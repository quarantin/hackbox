from django.db import models

class BlacklistedDomain(models.Model):

	BLACKLIST_CHOICES = (
		('malware', 'Malware'),
		('porn',    'Porn'),
		('p2p',     'Pear-to-pear'),
	)

	domain = models.CharField(max_length=255)
	reason = models.CharField(max_length=32, choices=BLACKLIST_CHOICES)

	def is_blacklisted_domain(domain):
		tokens = domain.split('.')
		if len(tokens) > 1:
			domain = '.'.join(tokens[-2:-1])

		return len(list(BlacklistedDomain.objects.filter(domain=domain))) > 0

	def __str__(self):
		return self.domain

class WhitelistedDomain(models.Model):

	WHITELIST_CHOICES = (
		('mail',         'Mail'),
		('productivity', 'Productivity'),
		('social',       'Social Network'),
	)

	domain = models.CharField(max_length=255)
	reason = models.CharField(max_length=32, choices=WHITELIST_CHOICES)

	def is_whitelisted_domain(domain):
		tokens = domain.split('.')
		if len(tokens) > 1:
			domain = '.'.join(tokens[-2:-1])

		return len(list(WhitelistedDomain.objects.filter(domain=domain))) > 0

	def __str__(self):
		return self.domain
