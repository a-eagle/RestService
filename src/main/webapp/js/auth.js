axios.interceptors.request.use(function (config) {
	var auth = localStorage.getItem('Auth');
	config.headers.Auth = auth;
	console.log(config);
	return config;
});

axios.interceptors.response.use(function (response) {
		// 2xx 范围内的状态码都会触发该函数。
		// 对响应数据做点什么
		console.log(response);
		return response;
	}, function (error) {
		// 超出 2xx 范围的状态码都会触发该函数。
		// 对响应错误做点什么
		console.log(error);
		// return Promise.reject(error);
		return error;
});