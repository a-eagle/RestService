axios.interceptors.request.use(function (config) {
	var auth = localStorage.getItem('Auth');
	config.headers.Auth = auth;
	return config;
});