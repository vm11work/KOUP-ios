(function (window, undefined) {
	JRole = {
			init : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JRole.error = config ["error"];
						JRole.success = config ["success"];
				    	var request = "app://action/role";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},
			delegate : function (status, response) 
			{
				try
				{
					var check = false;
					if (true == status) check = true; if ("true" === status) check = true;
					if (check) 
					{
						if ("function" === typeof (JRole.success)) JRole.success (response);
					} else { if ("function" === typeof (JRole.error)) JRole.error (response); }
				} catch (e) { console.log (e); }
			}
	};
	
	JExec = {
			init : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JExec.link = config ["link"];
						JExec.data = config ["data"]; // scheme or package
				    	var request = "app://action/exec";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			kosmo : function ()
			{
				try
				{
					if (JNative.isIos ())
					{
						JExec.init ({
							data : "kosmo",
							link : "https://kosmo.kccworld.net/down/page"
						});
					}
					if (JNative.isAndroid ())
					{
						JExec.init ({
							data : "com.kccworld.kosmo",
							link : "https://kosmo.kccworld.net/down/page"
						});
					}
				} catch (e) { console.log (e); }
				
			},
			evaluate : function ()
			{
				var result = { link : "", data : "" };

				try
				{
					var link = new URL (document.baseURI).href;
					if (JExec.link) link = new URL (JExec.link, document.baseURI).href;
					var data = JExec.data;
					result = { link : link, data : data };
				} catch (e) { console.log (e); }
		
				return JSON.stringify (result);
			},
			delegate : function (status, response) 
			{
				try
				{
					var check = false;
					if (true == status) check = true; if ("true" === status) check = true;
					if (check) 
					{
						if ("function" === typeof (JExec.success)) JExec.success (response);
					} else { if ("function" === typeof (JExec.error)) JExec.error (response); }
				} catch (e) { console.log (e); }
			}
	};
	
	JUtil = {
			get : function (name)
			{
		        var check; var value = "";
				try
				{
				    check = document.querySelector ("input[id='" + name + "']"); if (check) value = check.value;
				    check = document.querySelector ("input[name='" + name + "']"); if (check) value = check.value;
				    check = document.querySelector ("textarea[id='" + name + "']"); if (check) value = check.value;
				    check = document.querySelector ("textarea[name='" + name + "']"); if (check) value = check.value;
			        check = document.querySelector ("select[id='" + name + "']"); if (check) value = check.value;
			        check = document.querySelector ("select[name='" + name + "']"); if (check) value = check.value;
			        check = document.querySelector ("span[id='" + name + "']"); if (check) value = check.innerHTML;
			        check = document.querySelector ("span[name='" + name + "']"); if (check) value = check.innerHTML;
			        check = document.querySelector ("button[id='" + name + "']"); if (check) value = check.innerHTML;
			        check = document.querySelector ("button[name='" + name + "']"); if (check) value = check.innerHTML;
				} catch (e) { console.log (e); }
			    return value;
			},
			set : function (name, value)
			{
		        var check;
				try
				{
				    check = document.querySelector ("input[id='" + name + "']"); if (check) check.value = value;
				    check = document.querySelector ("input[name='" + name + "']"); if (check) check.value = value;
				    check = document.querySelector ("textarea[id='" + name + "']"); if (check) check.value = value;
				    check = document.querySelector ("textarea[name='" + name + "']"); if (check) check.value = value;
				    check = document.querySelector ("select[id='" + name + "']"); if (check) check.value = value;
				    check = document.querySelector ("select[name='" + name + "']"); if (check) check.value = value;
			        check = document.querySelector ("span[id='" + name + "']"); if (check) check.innerHTML = value;
			        check = document.querySelector ("span[name='" + name + "']"); if (check) check.innerHTML = value;
			        check = document.querySelector ("button[id='" + name + "']"); if (check) check.innerHTML = value;
			        check = document.querySelector ("button[name='" + name + "']"); if (check) check.innerHTML = value;
				} catch (e) { console.log (e); }
			},
			date : function ()
			{
			    var date = new Date (),
		        month = "" + (date.getMonth () + 1),
		        day = "" + date.getDate (),
		        year = date.getFullYear ();
		        hours = date.getHours ();
		        minutes = date.getMinutes ();
		        seconds = date.getSeconds ();
			    if (month.length < 2) month = "0" + month;
			    if (day.length < 2)  day = "0" + day;
			    return [year, month, day, hours, minutes, seconds].join ("");
			},
			scrollY : function ()
			{
				var y = window.scrollY; 
				if (null != $('.LayerWebContent').scrollTop ()) y = $('.LayerWebContent').scrollTop ();
				return y;
			}
	};
	
	JData = {
			get : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JData.name = config ["name"];
						JData.error = config ["error"];
						JData.success = config ["success"];
				    	var request = "app://action/data/get";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}
				} catch (e) { console.log (e); }
			},	
			del : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JData.list = config ["list"];
						JData.error = config ["error"];
						JData.success = config ["success"];
				    	var request = "app://action/data/del";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}
				} catch (e) { console.log (e); }
			},	
			set : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JData.menu = config ["menu"];
						JData.name = config ["name"];
						JData.data = config ["data"];
						JData.error = config ["error"];
						JData.success = config ["success"];
				    	var request = "app://action/data/set";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			all : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JData.menu = config ["menu"];
						JData.error = config ["error"];
						JData.success = config ["success"];
				    	var request = "app://action/data/all";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			submit : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JData.url = config ["url"];
						JData.image = config ["image"];
						JData.voice = config ["voice"];
						JData.params = config ["params"];
						JData.error = config ["error"];
						JData.success = config ["success"];
				    	var request = "app://action/data/submit";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			evaluate : function ()
			{
				var result = { url : "", menu : "", name : "", list : "", data : {}, params : {}, image : "", voice : "" };
		
				try
				{
					var url = new URL (document.baseURI).href;
					if (JData.url) url = new URL (JData.url, document.baseURI).href;
					var menu = JData.menu;
					var name = JData.name;
					var list = JData.list;
					var data = JData.data;
					var image = JData.image;
					var voice = JData.voice;
					var params = JData.params;
					result = { url : url, menu : menu, name : name, list : list, data : data, params : params, image : image, voice : voice };
				} catch (e) { console.log (e); }
		
				return JSON.stringify (result);
			},
			validate : function (target)
			{
				var result = new Map ();
				var exclude = "deadline, title"; // 제외 목록 필요시 "," 구분하여 추가요
				
				try
				{
					if (document.querySelector ("form[id='" + target + "']")) 
					{
						var list = document.querySelector ("form[id='" + target + "']");
						for (i = 0; i < list.length; i++)
						{
							var key = ""; var value = ""; var status = true;
							if ("radio" === list.elements [i].type || "checkbox" === list.elements [i].type)
							{
								status = list.elements [i].checked;
							}											
							if (list.elements [i].name) key = list.elements [i].name; 
							if (key) 
							{
								value = list.elements [i].value;
								if (status) result.set (key, value); 
							}
						}
					}
					if (document.querySelector ("form[name='" + target + "']")) 
					{
						var list = document.querySelector ("form[name='" + target + "']");
						for (i = 0; i < list.length; i++)
						{
							var key = ""; var value = ""; var status = true;
							if ("radio" === list.elements [i].type || "checkbox" === list.elements [i].type)
							{
								status = list.elements [i].checked;
							}											
							if (list.elements [i].name) key = list.elements [i].name; 
							if (key) 
							{
								value = list.elements [i].value;
								if (status) result.set (key, value); 
							}
						}
					}
				} catch (e) { console.log (e); }
				
			    var status = false;
			    var check = exclude.split (",").map (each => each.trim ());
				for (var key of result.keys ())
				{
					console.log ("check prepage : [" + key + "] => [" + result.get (key) + "]");
					if (check.includes (key)) 
					{
						console.log ("check.includes (key) : [" + exclude + "] => [" + key + "]");
						continue;
					}
					if (0 < result.get (key).length) status = true;
				}
				
				return status;
			},			
			elements : function (target)
			{
				var result = new Map ();
		
				try
				{
					if (document.querySelector ("form[id='" + target + "']")) 
					{
						var list = document.querySelector ("form[id='" + target + "']");
						for (i = 0; i < list.length; i++)
						{
							var key = ""; var value = ""; var status = true;
							if ("radio" === list.elements [i].type || "checkbox" === list.elements [i].type)
							{
								status = list.elements [i].checked;
							}											
							if (list.elements [i].name) key = list.elements [i].name; 
							if (key) 
							{
								value = list.elements [i].value;
								if (status) result.set (key, value); 
							}
						}
					}
					if (document.querySelector ("form[name='" + target + "']")) 
					{
						var list = document.querySelector ("form[name='" + target + "']");
						for (i = 0; i < list.length; i++)
						{
							var key = ""; var value = ""; var status = true;
							if ("radio" === list.elements [i].type || "checkbox" === list.elements [i].type)
							{
								status = list.elements [i].checked;
							}											
							if (list.elements [i].name) key = list.elements [i].name; 
							if (key) 
							{
								value = list.elements [i].value;
								if (status) result.set (key, value); 
							}
						}
					}
				} catch (e) { console.log (e); }
				
				return Object.fromEntries (result);
			},
			delegate : function (status, response) 
			{
				try
				{
					var check = false;
					if (true == status) check = true; if ("true" === status) check = true;
					if (check) 
					{
						if ("function" === typeof (JData.success)) JData.success (response);
					} else { if ("function" === typeof (JData.error)) JData.error (response); }
				} catch (e) { console.log (e); }
			}
	};
	
	JMedia = {
			play : function (config)
			{
				try
				{
					var url = new URL (document.baseURI).href;
					if (config) url = new URL (config, document.baseURI).href;
					if (JMedia.audio) JMedia.stop ();
					JMedia.audio = new Audio (url);
					JMedia.audio.play ();
				} catch (e) { console.log (e); }
			},
			stop : function ()
			{
				try
				{
					if (JMedia.audio)
					{
						JMedia.audio.pause (); 
						JMedia.audio = null;
					}
				} catch (e) { console.log (e); }
			}
	};

	JVoice = {
			play : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JVoice.list = config ["list"];
						JVoice.error = config ["error"];
						JVoice.success = config ["success"];
				    	var request = "app://action/voice/play";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},
			stop : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JVoice.error = config ["error"];
						JVoice.success = config ["success"];
				    	var request = "app://action/voice/stop";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},
			record : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JVoice.error = config ["error"];
						JVoice.success = config ["success"];
				    	var request = "app://action/voice/record";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},
			submit : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JVoice.url = config ["url"];
						JVoice.name = config ["name"]; // upload name 
						JVoice.list = config ["list"]; // upload file name list
						JVoice.params = config ["params"]; // 필요시 추가 패러미터 
						JVoice.error = config ["error"];
						JVoice.success = config ["success"];
				    	var request = "app://action/voice/submit";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			evaluate : function ()
			{
				var result = { url : "", name : "", list : "", params : {} };

				try
				{
					var url = new URL (document.baseURI).href;
					if (JVoice.url) url = new URL (JVoice.url, document.baseURI).href;
					var name = JVoice.name;
					var list = JVoice.list;
					var params = JVoice.params;
					result = { url : url, name : name, list : list, params : params };
				} catch (e) { console.log (e); }
		
				return JSON.stringify (result);
			},
			elements : function (target)
			{
				var result = new Map ();

				try
				{
					if (document.querySelector ("form[id='" + target + "']")) 
					{
						var list = document.querySelector ("form[id='" + target + "']");
						for (i = 0; i < list.length; i++)
						{
							var key = ""; var value = ""; var status = true;
							if ("radio" === list.elements [i].type || "checkbox" === list.elements [i].type)
							{
								status = list.elements [i].checked;
							}											
							if (list.elements [i].name) key = list.elements [i].name; 
							if (key) 
							{
								value = list.elements [i].value;
								if (status) result.set (key, value); 
							}
						}
					}
					if (document.querySelector ("form[name='" + target + "']")) 
					{
						var list = document.querySelector ("form[name='" + target + "']");
						for (i = 0; i < list.length; i++)
						{
							var key = ""; var value = ""; var status = true;
							if ("radio" === list.elements [i].type || "checkbox" === list.elements [i].type)
							{
								status = list.elements [i].checked;
							}											
							if (list.elements [i].name) key = list.elements [i].name; 
							if (key) 
							{
								value = list.elements [i].value;
								if (status) result.set (key, value); 
							}
						}
					}
				} catch (e) { console.log (e); }
				
				return Object.fromEntries (result);
			},
			delegate : function (status, response) 
			{
				try
				{
					var check = false;
					if (true == status) check = true; if ("true" === status) check = true;
					if (check) 
					{
						if ("function" === typeof (JVoice.success)) JVoice.success (response);
					} else { if ("function" === typeof (JVoice.error)) JVoice.error (response); }
				} catch (e) { console.log (e); }
			}
	};
	
	JImage = {
			photo : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JImage.error = config ["error"];
						JImage.success = config ["success"];
				    	var request = "app://action/image/photo";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			camera : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JImage.error = config ["error"];
						JImage.success = config ["success"];
				    	var request = "app://action/image/camera";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			thumb : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JImage.list = config ["list"];
						JImage.error = config ["error"];
						JImage.success = config ["success"];
				    	var request = "app://action/image/thumb";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			submit : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JImage.url = config ["url"];
						JImage.name = config ["name"]; // upload name 
						JImage.list = config ["list"]; // upload file name list
						JImage.params = config ["params"]; // 필요시 추가 패러미터 
						JImage.error = config ["error"];
						JImage.success = config ["success"];
				    	var request = "app://action/image/submit";
						window.location.href = request;
						console.log ("request [" + request + "]");
					}			
				} catch (e) { console.log (e); }
			},	
			evaluate : function ()
			{
				var result = { url : "", name : "", list : "", params : {} };
		
				try
				{
					var url = new URL (document.baseURI).href;
					if (JImage.url) url = new URL (JImage.url, document.baseURI).href;
					var name = JImage.name;
					var list = JImage.list;
					var params = JImage.params;
					result = { url : url, name : name, list : list, params : params };
				} catch (e) { console.log (e); }
		
				return JSON.stringify (result);
			},
			elements : function (target)
			{
				var result = new Map ();
		
				try
				{
					if (document.querySelector ("form[id='" + target + "']")) 
					{
						var list = document.querySelector ("form[id='" + target + "']");
						for (i = 0; i < list.length; i++)
						{
							var key = ""; var value = ""; var status = true;
							if ("radio" === list.elements [i].type || "checkbox" === list.elements [i].type)
							{
								status = list.elements [i].checked;
							}											
							if (list.elements [i].name) key = list.elements [i].name; 
							if (key) 
							{
								value = list.elements [i].value;
								if (status) result.set (key, value); 
							}
						}
					}
					if (document.querySelector ("form[name='" + target + "']")) 
					{
						var list = document.querySelector ("form[name='" + target + "']");
						for (i = 0; i < list.length; i++)
						{
							var key = ""; var value = ""; var status = true;
							if ("radio" === list.elements [i].type || "checkbox" === list.elements [i].type)
							{
								status = list.elements [i].checked;
							}											
							if (list.elements [i].name) key = list.elements [i].name; 
							if (key) 
							{
								value = list.elements [i].value;
								if (status) result.set (key, value); 
							}
						}
					}
				} catch (e) { console.log (e); }
				
				return Object.fromEntries (result);
			},
			delegate : function (status, response) 
			{
				try
				{
					var check = false;
					if (true == status) check = true; if ("true" === status) check = true;
					if (check) 
					{
						if ("function" === typeof (JImage.success)) JImage.success (response);
					} else { if ("function" === typeof (JImage.error)) JImage.error (response); }
				} catch (e) { console.log (e); }
			}
	};
	
	JNative = {
			mode: true,
			bounce: true, 
			init : function (config)
			{
				try
				{
					if ("object" === typeof (config))
					{
						JNative.mode = config ["mode"];
						JNative.apps = config ["apps"];
						JNative.type = config ["type"];
						JNative.guid = config ["guid"];
						JNative.user = config ["user"];
					}			
				} catch (e) { console.log (e); }
			},	
			go : function (url)
			{
				window.location.href = url;
				console.log ("request [" + url + "]");
			},
			open : function (url)
			{
		    	var request = "app://action/open?" + url;
				window.location.href = request;
				console.log ("request [" + request + "]");
			},
			exec : function (scheme)
			{
		    	var request = "app://action/exec/" + scheme;
				window.location.href = request;
				console.log ("request [" + request + "]");
			},
			online : function ()
			{
				JNative.mode = true;
		    	var request = "app://action/online";
				window.location.href = request;
				console.log ("request [" + request + "]");
			},
			offline : function ()
			{
				JNative.mode = false;
		    	var request = "app://action/offline";
				window.location.href = request;
				console.log ("request [" + request + "]");
			},
			isMode : function ()
			{
				return JNative.mode;
			},
			isBounce : function ()
			{
				return JNative.bounce;
			},
			isOnline : function ()
			{
		    	var request = "app://action/check";
				window.location.href = request;
				console.log ("request [" + request + "]");
				return window.navigator.onLine;
			},
			isApp : function ()
			{
				var status = false;
				if ("o" == JNative.getCookie ("global-apps")) status = true;
				return status;
			},
			isIos : function ()
			{
				var status = false;
				if ("i" == JNative.getCookie ("global-type")) status = true;
				return status;
			},
			isAndroid : function ()
			{
				var status = false;
				if ("a" == JNative.getCookie ("global-type")) status = true;
				return status;
			},
			getGuid : function ()
			{
				var value = JNative.getCookie ("global-guid");
				return value;
			},
			getUser : function ()
			{
				var value = JNative.getCookie ("write");
				return value;
			},
			getBuild : function ()
			{
				var value = JNative.getCookie ("global-build");
				return value;
			},
			getVersion : function ()
			{
				var value = JNative.getCookie ("global-version");
				return value;
			},
			setBounce : function (status)
			{
				JNative.bounce = status;
			},
			getCookie : function (name)
			{
				var cookies = {}; if (document.cookie) cookies = document.cookie.split (";");
			    var key = ""; var value = "";
				for (cookie in cookies) 
				{
					key = ""; value = "";
			        swap = cookies [cookie].split ("=");
			        if (swap [0]) key = swap [0].trim (); 
			        if (name === key) 
			        {
			        	if (swap [1]) value = swap [1].trim (); break;
			        }
				}
				return value;
			},
			getCookies : function () { return document.cookie; }			
	};
})(window); 
