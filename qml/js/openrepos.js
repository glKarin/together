.pragma library

var idOpenRepos = {
	VERSION: "v1",
	URL: "https://openrepos.net/api/",

	APP_DETAIL: "apps/%1",



	__HandleNameString: function(s){
		return s.replace(/_/g, "").toLowerCase();
	},

	MakeAPIUrl: function(call_url){
		var api = this;
    var url = api.URL + api.VERSION + "/" + call_url;
		return url;
	},

	MakeAppDetailUrl: function(user_name, title){
		if(!user_name || !title)
			return false;
		var APP_DETAIL_URL = "https://openrepos.net/content/%1/%2";
		var un = this.__HandleNameString(user_name);
		var t = this.__HandleNameString(title);
		return APP_DETAIL_URL.arg(un).arg(t);
	},

	MakeUserHomeUrl: function(user_name){
		if(!user_name)
			return false;
		var USER_HOME_URL = "https://openrepos.net/users/%1";
		var un = this.__HandleNameString(user_name);
		return USER_HOME_URL.arg(un);
	},

	LoadApplication: function(data, obj){
		if(Array.isArray(data)) // ["Application not found"]
		{
			return data[0];
		}

		var r = obj ? obj : {};

		r.appid = data.appid;
		r.title = data.title;
		r.updated = parseInt(data.updated);
		r.changelog = data.changelog;
		r.download = data.download;
		r.package_name = data["package"] ? data["package"].name : "";
		r.package_version = data["package"] ? data["package"].version : "";
		r.icon = data.icon ? data.icon.url : "";
		r.body = data.body;
		r.user_name = data.user ? data.user.name : "";
		r._url = this.MakeAppDetailUrl(r.user_name, r.title);

		return obj ? true : r;
	},
};
