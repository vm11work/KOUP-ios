////////////////////
// jutil offline code  

var stub_item_head = '<div class="n_checkbox_t1"><label class="check_st01"><input type="checkbox" name="all" onclick="offlineToggleAll ();">전체선택<span class="checkmark"></span></label></div>';
var stub_item_data = '<li id="#NAME#"><a href="javascript:offlineEditData(\'#NAME#\');"><div class="thum_img"><img src="#THUMB#" #THUMBSTYLE#/><span class="i-day" #DEADLINESTYLE#>D-#DEADLINE#</span></div><div class="rit_list_txt n_ty01"><ul><li><strong>#MENU#</strong><span>#CONTENT#</span></li><li><strong>요청일</strong><span>#DATE#</span></li><li><button id="status_voice_#NAME#" type="button" class="n_ui_btn1" onclick="offlineVoiceToggleList (\'status_voice_#NAME#\', \'#VOICE#\'); return false;" #VOICESTYLE#>음성녹음듣기</button></li></ul></div><label class="check_st01"><input type="checkbox" id="#NAME#" name="delete" value="#NAME#" onclick="offlineFreeAll ();"><span class="checkmark"></span></label></a></li>';
var stub_item_nodata = '<li><a href="javascript:void(0);"><div class="rit_list_txt n_ty01" style="width: 100%; text-align: center;">등록된 데이터가 없습니다.</div></a></li>';

var stub_item_head_20200820 = '<li class="head no_bg"><label class="check_st01"><input type="checkbox" name="all" onclick="offlineToggleAll ();">전체선택<span class="checkmark"></span></label></li>';
var stub_item_data_20200820 = '<li id="#NAME#"><label class="check_st01 list_front"><input type="checkbox" id="#NAME#" name="delete" value="#NAME#" onclick="offlineFreeAll ();"><span class="checkmark"></span></label><a href="javascript:offlineEditData(\'#NAME#\');"><div class="notice_date"><div class="lef_date"><strong>#MENU#</strong><span>#DATE#</span></div><h3 class="multi_line mt10">#CONTENT#</h3></div></a></li>';
var stub_item_nodata_20200820 = '<li style="border-bottom-style: none;"><div class="notice_date" style="text-align: center;"><h3 class="multi_line mt10">등록된 데이터가 없습니다.</h3></div></li>';

var stub_save_data = '<li><a href="javascript:void(0);"><div class="thum_img"><img id="img#NAME#" src="img/thum_default_img.jpg" alt="썸네일 이미지"><span class="i-day">D-11</span></div><div class="rit_list_txt"><ul><li><strong>등록일</strong><span>#DATE#</span></li></ul><p>#CONTENT#</p></div></a></li>';
var stub_save_nodata = '<li style="border-bottom: none !important;"><a href="javascript:void(0);"><div class="rit_list_txt"><p>등록된 데이터가 없습니다.</p></div></a></li>';
var stub_info_voice = '<button id="delete_voice" type="button" class="btn_tbl_del_2" title="삭제" onclick="offlineVoiceDelete ();"></button>';

var voice_status_previous = "VOICE-STATUS-NONE-";

function offlineToggleAll ()
{
	try
	{
		$("input[name='delete']").prop ("checked", false);
		if (true == $("input[name='all']").prop ("checked"))
		{
			$("input[name='delete']").prop ("checked", true);
		}
	} catch (e) { console.log (e); }
}

function offlineFreeAll ()
{
	try
	{
		$("input[name='all']").prop ("checked", false);
	} catch (e) { console.log (e); }
}

function offlineTogglePopup ()
{
	try
	{
		$("#popup").toggle ();
	} catch (e) { console.log (e); }
}

function offlineVoiceRecord ()
{
	try
	{
	    JVoice.record ({
	        error: function (response) 
	        {
                console.log ("error => " + response);
	        },
	        success: function (response) 
	        {
        	    var json = JSON.parse (response);
        	    JUtil.set ("voice", json ["name"]);

                if (JUtil.get ("voice"))
				{
	                $("#voice_toggle").css ("opacity", 1);
	                $("#voice_toggle").attr ("disabled", false);
	                
	        		$('#info_voice').show ();
	        		JUtil.set ("info_voice", json ["name"] + " " + stub_info_voice);
				}
        	    
                console.log ("success => " + response);
	        }
	    });
	} catch (e) { console.log (e); }	
}

function offlineDataSet ()
{
	try
	{
		var menu = JUtil.get ("offline_menu");
		var name = JUtil.get ("offline_name");
		// name 기본값은 일시
		if (!name) 
		{
			name = JUtil.date ();
			JUtil.set ("offline_name", name);
		}

		if (!JData.validate ("frm_offline_data"))
		{
			alert ("데이터를 입력해주세요!");
			return;
		}
		
	    // form 패러미터 설정 예시 
		var data = JData.elements ("frm_offline_data");

		console.log ("menu : " + menu + " name : " + name + " => " + JSON.stringify (data));

	    JData.set ({
	        menu : menu,
	        name : name,
	        data : data, 
	        error: function (response) 
	        {
                console.log ("error => " + response);
	        },
	        success: function (response) 
	        {
        		var forword = JUtil.get ("offline_done");
        		if (forword) JNative.go (forword);
                console.log ("success forword => " + forword);
	        }
	    });
	} catch (e) { console.log (e); }
}

function offlineDataGet ()
{
	try
	{
		var name = JUtil.get ("offline_name");

	    JData.get ({
	        name : name,
	        error: function (response) 
	        {
                console.log ("error => " + response);
	        },
	        success: function (response) 
	        {
        	    var json = JSON.parse (response); var value = json ["response"];
        	    if (0 < json.response.length) 
        	    {
            	    var data = JSON.parse (json ["response"][0]["data"]);
	                JUtil.set ("deadline", data ["deadline"]);
	                JUtil.set ("title", data ["title"]);
	                JUtil.set ("content", data ["content"]);
	                JUtil.set ("image", data ["image"]);
	                JUtil.set ("voice", data ["voice"]);
        	    }
                console.log ("success => " + response);
	        }
	    });
	} catch (e) { console.log (e); }
}

function offlineDataDel ()
{
	try
	{
		var name = JUtil.get ("offline_name");

	    JData.del ({
	        name : name,
	        error: function (response) 
	        {
                console.log ("error => " + response);
	        },
	        success: function (response) 
	        {
                console.log ("success => " + response);
	        }
	    });
	} catch (e) { console.log (e); }
}

function offlineDataList ()
{
	try
	{
		var menu = JUtil.get ("offline_menu");
		var last = 0; var limit = 0;

	    JData.list ({
	        menu : menu,
	        last : last,
	        limit : limit, 
	        error: function (response) 
	        {
                console.log ("error => " + response);
	        },
	        success: function (response) 
	        {
        	    var json = JSON.parse (response); var value = json ["response"];
        	    if (0 < json.response.length) 
        	    {
        		    for (var each in json.response) 
        			{
                	    var data = JSON.parse (json ["response"][each]["data"]);
    	                console.log ("title" + " : " + data ["title"]); 
    	                console.log ("content" + " : " + data ["content"]); 
    	                console.log ("image" + " : " + data ["image"]); 
    	                console.log ("voice" + " : " + data ["voice"]); 
        		    }
        	    }
        	    console.log ("success => " + response);
	        }
	    });
	} catch (e) { console.log (e); }
}

function offlineVoiceToggleList (each, name)
{
	try
	{
		var status = JUtil.get (each);
		if ("음성녹음듣기" == status)
		{
			var previous = voice_status_previous;
			JUtil.set (previous, "음성녹음듣기");
            console.log ("voice_status_previous => " + voice_status_previous);
			
			JUtil.set (each, "음성듣기중단");
			voice_status_previous = each;

		    JVoice.play ({
		    	list: name,
		        error: function (response) 
		        {
					JUtil.set (each, "음성녹음듣기");
	                console.log ("error => " + response);
		        },
		        success: function (response) 
		        {
					JUtil.set (each, "음성녹음듣기");
	                console.log ("success => " + response);
		        }
		    });
		}
		else 
		{
			JUtil.set (each, "음성녹음듣기");
		    JVoice.stop ({
		        error: function (response) 
		        {
	                console.log ("error => " + response);
		        },
		        success: function (response) 
		        {
	                console.log ("success => " + response);
		        }
		    });
		}
	} catch (e) { console.log (e); }	
}

function offlineVoiceToggleWrite ()
{
	try
	{
		var status = JUtil.get ("status_voice");
		if ("녹음 듣기" == status)
		{
			JUtil.set ("status_voice", "듣기 중단");
			var list = JUtil.get ("voice");
			
		    JVoice.play ({
		    	list: list,
		        error: function (response) 
		        {
					JUtil.set ("status_voice", "녹음 듣기");
	                console.log ("error => " + response);
		        },
		        success: function (response) 
		        {
					JUtil.set ("status_voice", "녹음 듣기");
	                console.log ("success => " + response);
		        }
		    });
		}
		else 
		{
			JUtil.set ("status_voice", "녹음 듣기");
		    JVoice.stop ({
		        error: function (response) 
		        {
	                console.log ("error => " + response);
		        },
		        success: function (response) 
		        {
	                console.log ("success => " + response);
		        }
		    });
		}
	} catch (e) { console.log (e); }	
}

function offlineImageDelete ()
{
	try
	{
        console.log ("offlineImageDelete");
        
		$('#delete_image').hide ();
		JUtil.set ("image", "");
        $("#thumb").hide ();
        $("#thumb").attr ("src", "");
	} catch (e) { console.log (e); }	
}

function offlineVoiceDelete ()
{
	try
	{
        console.log ("offlineVoiceDelete");

		$('#info_voice').hide ();
        JUtil.set ("voice", "");
		JUtil.set ("info_voice", "");

        $("#voice_toggle").css ("opacity", 0.3);
        $("#voice_toggle").attr ("disabled", true);
	} catch (e) { console.log (e); }	
}

function offlineImagePhoto ()
{
	try
	{
	    JImage.photo ({
	        error: function (response) 
	        {
                console.log ("error => " + response);
	        },
	        success: function (response) 
	        {
        	    var json = JSON.parse (response);
        	    JUtil.set ("image", json ["name"]);

                $("#thumb").show ();
        	    $("#thumb").attr ("src", json ["thumb"]);
        	    $('#delete_image').show ();
                
        	    console.log ("success => " + response);
        	    console.log ("check thumb!");
	        }
	    });
	} catch (e) { console.log (e); }
}

function offlineImageCamera ()
{
	try
	{
		JImage.camera ({
	        error: function (response) 
	        {
                console.log ("error => " + response);
	        },
	        success: function (response) 
	        {
        	    var json = JSON.parse (response);
        	    JUtil.set ("image", json ["name"]);

        	    $('#delete_image').show ();
                $("#thumb").show ();
        	    $("#thumb").attr ("src", json ["thumb"]);

                console.log ("success => " + response);
        	    console.log ("check thumb!");
	        }
	    });
	} catch (e) { console.log (e); }
}

////////////////////