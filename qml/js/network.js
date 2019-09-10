.pragma library

var idNetwork = function(u, m, p, t)
{
    var DBG_NONE = 0;
    var DBG_REQ = 1;
    var DBG_RESP = (1 << 1);
    var DBG_HEADER = (1 << 2);
    var DBG_ALL = (~0);

    this.url = u;
    this.method = m && m.toUpperCase() === "POST" ? "POST" : "GET";
    this.params = p;
		this.type = typeof(t) === "string" ? t.toUpperCase() : "JSON";

    this._DBG = DBG_REQ;

    function Print_r(obj)
    {
        if(!obj) return;
        console.log(obj);
        for(var i in obj)
            console.log(i, obj[i]);
    }

    function ParseHeaders(headers)
    {
        if(!headers) return null;
        var arr = headers.split("\r\n");
        var r = ({});
        for(var i in arr)
        {
            var start = arr[i].indexOf(": ");
            var name = (start !== -1) ? arr[i].substring(0, start) : arr[i];
            var value = (start !== -1) ? arr[i].substr(start + 2) : "";
            r[name] = value;
        }
        return r;
    }

    this.MakeParams = function(ps, enc){
             if(!ps) return false;

             var arr = [];
						 var ne = enc === undefined ? true : enc;

             switch(typeof(ps))
             {
                 case "string":
                     return ps.trim();
                 case "object":
                     if(Array.isArray(ps))
                         arr = ps;
                     else
                     {
                         for(var k in ps)
                             arr.push(k + "=" + (ne ? encodeURIComponent(ps[k].toString()) : ps[k].toString()));
                     }
                     return arr.join("&");
                 default:
                     return false;
             }

         };

    this.Request = function(suc_func, fail_func){
             var self = this;
             var xhr = new XMLHttpRequest();
             xhr.onreadystatechange = function(){
                         if(xhr.readyState == 4)
                         {
                             if(xhr.status == 200)
                             {
                                 try
                                 {
                                     var headers = ParseHeaders(xhr.getAllResponseHeaders());
                                     if(self._DBG & DBG_RESP)
                                         console.log(xhr.responseText);
                                     if(self._DBG & DBG_HEADER)
                                         Print_r(headers);
																		 if(self.type === "JSON")
																		 {
																			 var json = JSON.parse(xhr.responseText);
																			 if(typeof(suc_func) === "function") suc_func(json, headers);
																		 }
																		 else if(self.type === "XML")
																		 {
																			 var xml = xhr.responseXML;
																			 if(typeof(suc_func) === "function") suc_func(xml, headers);
																		 }
																		 else
																		 {
																			 if(typeof(suc_func) === "function") suc_func(xhr.responseText, headers);
																		 }
                                 }
                                 catch(e)
                                 {
                                     if(typeof(fail_func) === "function") fail_func(JSON.stringify(e));
                                 }
                             }
                             else
                             {
                                 if(typeof(fail_func) === "function") fail_func(xhr.status);
                             }
                         }
                     };


             var p = this.MakeParams(this.params);
             var u = this.method === "POST" ? this.url : this.url + (p ? "?" + p : "");
             if(this._DBG & DBG_REQ)
                 console.log("[" + this.method + "]: " + this.type + " ->\n" + this.url + (p ? "?" + p : ""));
             xhr.open(this.method, u);
             if(this.method === "POST")
             {
							 if(p)
							 {
								 if(self.type === "TEXT")
									 xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
								 else
									 xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8");
								 xhr.setRequestHeader("Content-Length", p.length);
								 xhr.send(p);
							 }
							 else
                 xhr.send();
             }
             else
                xhr.send();
         };
}
