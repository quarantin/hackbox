from django.contrib import admin
from .models import BlacklistedDomain, WhitelistedDomain

class BlacklistedDomainAdmin(admin.ModelAdmin):
	pass

class WhitelistedDomainAdmin(admin.ModelAdmin):
	pass

admin.site.register(BlacklistedDomain, BlacklistedDomainAdmin)
admin.site.register(WhitelistedDomain, WhitelistedDomainAdmin)
